# GeoServer DataDir Sync

Modern automatic GeoServer datadir synchronization using [git-sync](https://github.com/simonthum/git-sync).

This Docker image provides automated, bi-directional Git synchronization for GeoServer configuration directories with intelligent conflict resolution, webhook monitoring, and robust error handling.

## Features

✨ **Based on proven git-sync technology**
- Safe automatic conflict resolution
- Intelligent rebase handling for diverged histories
- Graceful degradation on conflicts requiring manual intervention

🔔 **Built-in webhook monitoring** (required)
- GET requests for simple monitoring (UptimeRobot, etc.)
- POST requests with JSON payloads for advanced integrations
- Notifications on sync success and failure

📁 **inotify + periodic sync**
- Instant sync on file changes via inotify
- Fallback periodic sync (works with NFS)
- Configurable sync interval

🔒 **Branch protection**
- Configure which branch to sync (prevents accidents)
- Repository must be explicitly configured for sync
- Automatic sync configuration for new repos only

## Quick Start

```yaml
version: '3.8'
services:
  datadir-sync:
    image: ghcr.io/camptocamp/georchestra-docker-images/geoserver-datadir-sync:latest
    environment:
      # Git configuration
      GIT_USERNAME: "geoserver-sync"
      GIT_EMAIL: "geoserver@example.com"
      
      # Remote repository
      REMOTE_NAME: origin
      REMOTE_URL: git@github.com:your-org/geoserver-datadir.git
      REMOTE_BRANCH: master
      
      # File to watch for changes
      WATCH_FILE: global.xml
      
      # Webhook (required)
      WEBHOOK_URL: https://your-monitoring-service.com/webhook
      
      # SSH key for git authentication
      GIT_RSA_DEPLOY_KEY: |
        -----BEGIN RSA PRIVATE KEY-----
        your-private-key-here
        -----END RSA PRIVATE KEY-----
    volumes:
      - geoserver_datadir:/var/local/data:rw

volumes:
  geoserver_datadir:
```

## Environment Variables

### Required Variables

| Variable | Description |
|----------|-------------|
| `WATCH_FILE` | File to watch for changes (relative to datadir root). Set this to enable continuous sync. |
| `WEBHOOK_URL` | Webhook URL for monitoring notifications (required when `WATCH_FILE` is set). |
| `GIT_USERNAME` | Git username for commits. |
| `GIT_EMAIL` | Git email for commits. |

### Remote Repository Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `REMOTE_NAME` | Name of the git remote (e.g., `origin`). | - |
| `REMOTE_URL` | Git repository URL. | - |
| `REMOTE_BRANCH` | Branch to synchronize. | `master` |

### SSH Authentication

Choose one of:

| Variable | Description |
|----------|-------------|
| `GIT_RSA_DEPLOY_KEY` | Private RSA key content (multiline). |
| `GIT_RSA_DEPLOY_KEY_FILE` | Path to file containing private RSA key. |

### Optional Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `GIT_SYNC_INTERVAL` | Sync interval in milliseconds (inotify timeout). | `500` |
| `GIT_SYNC_DIRECTORY` | Directory to synchronize. | `/var/local/data` |
| `FORCE_CLONE` | Force cleanup of directory before cloning (`yes`/`no`). | `no` |
| `NO_RESET` | Skip reset to remote state for existing repos (`true`/`false`). | `false` |
| `GIT_COMMIT_MESSAGE` | Custom commit message (can be a shell command). | Auto-generated |
| `WEBHOOK_METHOD` | HTTP method for webhook (`GET`/`POST`). | `GET` |
| `USERID` | User ID for the sync user. | `999` |
| `GROUPID` | Group ID for the sync user. | `999` |

## Webhook Configuration

### Simple GET (UptimeRobot, etc.)

```yaml
environment:
  WEBHOOK_URL: https://heartbeat.uptimerobot.com/your-monitor-id
  WEBHOOK_METHOD: GET
```

### POST with JSON payload

```yaml
environment:
  WEBHOOK_URL: https://your-service.com/api/webhook
  WEBHOOK_METHOD: POST
```

POST requests send JSON:
```json
{
  "status": "success",
  "message": "Sync completed: file change: global.xml",
  "timestamp": "2025-12-02T10:30:00Z",
  "hostname": "datadir-sync-container"
}
```

## Migration from Old Version

The new version is **mostly backward compatible** with environment variables from `geoserver-datadir-sync-old`.

### Key Differences

1. **Webhook is now required**: Set `WEBHOOK_URL` when using `WATCH_FILE`
2. **Automatic configuration**: Only applies to new repos, not existing ones
3. **Better conflict handling**: Sync stops on unresolvable conflicts instead of forcing

### Migration Steps

1. **Update your docker-compose.yml**:
   ```yaml
   services:
     sync:
       image: ghcr.io/camptocamp/georchestra-docker-images/geoserver-datadir-sync:latest
       environment:
         # Add webhook URL (required)
         WEBHOOK_URL: https://your-monitoring.com/webhook
         
         # Keep existing variables
         WATCH_FILE: global.xml
         GIT_USERNAME: your-username
         # ... other variables
   ```

2. **For existing repositories**: The image will detect and use your existing git configuration. If you need to enable sync:
   ```bash
   docker exec -it your-container bash
   git config --bool branch.master.sync true
   git config --bool branch.master.syncNewFiles true
   ```

3. **Test the migration**:
   - Start the container
   - Check logs for successful initialization
   - Verify webhook is being called
   - Make a test change to trigger sync

## How It Works

### On Container Start

1. **Initialization**:
   - Configures git username/email
   - Sets up SSH keys if provided
   - Adds git host to known_hosts

2. **Repository Setup**:
   - **If no .git directory**: Clones from remote OR initializes local repo
   - **If .git exists**: Updates remote configuration, optionally fetches/resets
   - **New repos only**: Automatically configures git-sync settings

3. **Continuous Sync** (if `WATCH_FILE` is set):
   - Validates `WEBHOOK_URL` is configured
   - Starts file watcher with inotify
   - Performs periodic sync on timeout
   - Sends webhook notifications

### Sync Behavior

The underlying [git-sync](https://github.com/simonthum/git-sync) handles:

- **Local changes**: Auto-commits with timestamp
- **Behind remote**: Fast-forward merge
- **Ahead of remote**: Push
- **Diverged**: Rebase and push
- **Conflicts**: Stop sync, require manual intervention

### Error Handling

- **Exit code 1** (conflicts): Container stops, requires manual fix
- **Exit code 3** (network issues): Logs error, continues (retries on next sync)
- **Other errors**: Logged with webhook notification

## Advanced Examples

### Custom Commit Messages

```yaml
environment:
  GIT_COMMIT_MESSAGE: 'printf "updateSequence "; grep updateSequence global.xml | sed -e "s#.*ce>\(.*\)</up.*#\1#"'
```

### Local Repository Only (No Remote)

```yaml
environment:
  GIT_USERNAME: local-user
  GIT_EMAIL: local@example.com
  WATCH_FILE: global.xml
  WEBHOOK_URL: http://localhost:8080/health
  # No REMOTE_NAME or REMOTE_URL
```

### Initialization Only (No Continuous Sync)

```yaml
environment:
  GIT_USERNAME: init-user
  GIT_EMAIL: init@example.com
  REMOTE_NAME: origin
  REMOTE_URL: git@github.com:org/repo.git
  # No WATCH_FILE - exits after clone/init
```

## Troubleshooting

### Container exits immediately

Check if `WATCH_FILE` is set. Without it, the container performs initialization only and exits.

### "ERROR: WEBHOOK_URL is not configured"

Webhook is required for continuous sync. Set `WEBHOOK_URL` environment variable.

### "Manual intervention required"

Git-sync detected a conflict it cannot resolve automatically:

```bash
# Connect to container
docker exec -it your-container bash

# Check git status
git status

# Resolve conflicts manually
git rebase --continue
# or
git rebase --abort

# Restart container
```

### Sync not working

1. Check container logs: `docker logs your-container`
2. Verify git-sync configuration:
   ```bash
   docker exec -it your-container bash
   git config --get branch.master.sync
   git config --get branch.master.syncNewFiles
   ```
3. Test git-sync manually:
   ```bash
   docker exec -it your-container git-sync -n -s
   ```

### SSH Authentication Issues

Ensure your deploy key is properly formatted:
```yaml
GIT_RSA_DEPLOY_KEY: |
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA...
  -----END RSA PRIVATE KEY-----
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│ Container: geoserver-datadir-sync               │
│                                                 │
│  ┌──────────────┐         ┌─────────────────┐  │
│  │ entrypoint.sh│────────▶│ git-sync-on-    │  │
│  │              │         │ inotify-webhook │  │
│  └──────────────┘         └─────────────────┘  │
│         │                          │            │
│         ▼                          ▼            │
│  ┌──────────────┐         ┌─────────────────┐  │
│  │ Git repo     │────────▶│ git-sync        │  │
│  │ setup & init │         │ (from upstream) │  │
│  └──────────────┘         └─────────────────┘  │
│                                   │             │
└───────────────────────────────────┼─────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                    ▼                               ▼
            ┌──────────────┐              ┌──────────────┐
            │ Remote Git   │              │ Webhook      │
            │ Repository   │              │ Monitoring   │
            └──────────────┘              └──────────────┘
```

## License

- **git-sync**: [CC0 1.0 Universal](https://github.com/simonthum/git-sync/blob/master/LICENSE) by Simon Thum and contributors
- **This image**: Maintained by [Camptocamp](https://github.com/camptocamp)

## Contributing

Issues and pull requests welcome at the [georchestra-docker-images](https://github.com/camptocamp/georchestra-docker-images) repository.
