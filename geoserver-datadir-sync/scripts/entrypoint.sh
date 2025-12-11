#!/bin/bash
set -e

echo "======================================="
echo "GeoServer DataDir Sync (git-sync based)"
echo "======================================="

# Map old environment variables to git-sync compatible ones
# This ensures backward compatibility with the old geoserver-datadir-sync

# Set git user configuration
if [ -n "$GIT_EMAIL" ]; then
    git config --global user.email "$GIT_EMAIL"
    echo "Git email: $GIT_EMAIL"
fi

if [ -n "$GIT_USERNAME" ]; then
    git config --global user.name "$GIT_USERNAME"
    echo "Git username: $GIT_USERNAME"
fi

# Configure SSH for git if deploy keys are provided
mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ -n "$GIT_RSA_DEPLOY_KEY" ]; then
    echo "Installing RSA key from environment variable"
    echo "$GIT_RSA_DEPLOY_KEY" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
fi

if [ -n "$GIT_RSA_DEPLOY_KEY_FILE" ]; then
    echo "Installing RSA key from file: $GIT_RSA_DEPLOY_KEY_FILE"
    cp "$GIT_RSA_DEPLOY_KEY_FILE" ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
fi

# Add git host to known_hosts if remote is configured
if [ -n "$REMOTE_NAME" ] && [ -n "$REMOTE_URL" ]; then
    git_hostname=$(echo "$REMOTE_URL" | sed -e 's#.*@\(.*\):.*#\1#')
    if [ -n "$git_hostname" ]; then
        echo "Adding $git_hostname to known_hosts"
        ssh-keyscan -H "$git_hostname" >> ~/.ssh/known_hosts 2>/dev/null
    fi
fi

# Change to the data directory
cd /mnt/geoserver_datadir

# Initialize or update the git repository
if [ ! -d .git ]; then
    echo "No git repository found in /mnt/geoserver_datadir"
    
    if [ -n "$REMOTE_NAME" ] && [ -n "$REMOTE_URL" ]; then
        # Check if directory is empty (excluding . and ..)
        files_count=$(ls -A | wc -l)
        
        if [ "$files_count" -gt 0 ]; then
            if [ "$FORCE_CLONE" = "yes" ]; then
                echo "FORCE_CLONE is set, cleaning directory"
                rm -rf ./* ./.[!.]* ./..?*
            else
                echo "ERROR: Directory not empty and FORCE_CLONE not set"
                echo "Set FORCE_CLONE=yes to force cleanup, or manually clear the directory"
                exit 1
            fi
        fi
        
        echo "Cloning from $REMOTE_URL (branch: $REMOTE_BRANCH)"
        git clone -b "$REMOTE_BRANCH" "$REMOTE_URL" .
        
        # Configure the repository for git-sync
        git config --bool branch."$REMOTE_BRANCH".sync true
        git config --bool branch."$REMOTE_BRANCH".syncNewFiles true
        git config branch."$REMOTE_BRANCH".remote "$REMOTE_NAME"
        git config branch."$REMOTE_BRANCH".merge "refs/heads/$REMOTE_BRANCH"
        git config branch."$REMOTE_BRANCH".pushRemote "$REMOTE_NAME"
    else
        echo "No remote configured, initializing local repository"
        git init
        git checkout -b "$REMOTE_BRANCH"
        git config --bool branch."$REMOTE_BRANCH".sync true
        git config --bool branch."$REMOTE_BRANCH".syncNewFiles true
    fi
else
    echo "Git repository already exists"
    
    # Update remote if configured
    if [ -n "$REMOTE_NAME" ] && [ -n "$REMOTE_URL" ]; then
        echo "Updating remote $REMOTE_NAME to $REMOTE_URL"
        git remote remove "$REMOTE_NAME" 2>/dev/null || true
        git remote add "$REMOTE_NAME" "$REMOTE_URL"
        
        # Configure upstream tracking for the branch
        echo "Configuring upstream tracking for branch $REMOTE_BRANCH"
        git config branch."$REMOTE_BRANCH".remote "$REMOTE_NAME"
        git config branch."$REMOTE_BRANCH".merge "refs/heads/$REMOTE_BRANCH"
        git config branch."$REMOTE_BRANCH".pushRemote "$REMOTE_NAME"
        
        # Fetch latest changes
        echo "Fetching from remote"
        git fetch "$REMOTE_NAME"
    fi
fi

# Set custom commit message if provided
if [ -n "$GIT_COMMIT_MESSAGE" ]; then
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "$REMOTE_BRANCH")
    # Evaluate the commit message (it might be a command)
    commit_msg=$(eval echo "$GIT_COMMIT_MESSAGE")
    git config branch."$current_branch".syncCommitMsg "$commit_msg"
    echo "Custom commit message configured"
fi

echo "======================================="
echo "Repository initialized and configured"
echo "Branch: $(git symbolic-ref --short HEAD 2>/dev/null || echo 'detached')"
if [ -n "$REMOTE_NAME" ] && [ -n "$REMOTE_URL" ]; then
    echo "Remote: $REMOTE_NAME ($REMOTE_URL)"
fi
if [ -n "$WEBHOOK_URL" ]; then
    echo "Webhook notifications: enabled"
fi
echo "======================================="

# Webhook is required for continuous sync monitoring
if [ -z "$WEBHOOK_URL" ]; then
    echo "ERROR: WEBHOOK_URL is not configured"
    echo "Webhook notifications are required for monitoring continuous sync."
    echo "Please set the WEBHOOK_URL environment variable."
    exit 1
fi

echo "Starting continuous sync (watching for changes)"
echo "Sync interval: ${GIT_SYNC_INTERVAL}ms"

# Execute the command passed to the container
exec "$@"
