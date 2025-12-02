# Toolbox Docker Image

## About

This Docker image provides a lightweight Alpine Linux-based toolbox container with network debugging and monitoring tools. It's designed for troubleshooting and analysis tasks in containerized environments.

## Included Tools

- **mitmproxy** - An interactive, SSL/TLS-capable intercepting proxy for HTTP/HTTPS
- **tcpdump** - Command-line packet analyzer
- **bash** - Enhanced shell for scripting
- **curl** - Command line tool for transferring data
- **wget** - Network downloader
- **bind-tools** - DNS utilities (dig, nslookup)

## Usage

### Inject the container as a debug container in a running pod

```bash
kubectl debug -it georchestra-header-b768c765b-qjk56 --image ghcr.io/camptocamp/georchestra-docker-images/toolbox:latest -- bash
```

### Basic Usage

```bash
docker run -it --rm ghcr.io/camptocamp/georchestra-docker-images/toolbox
```

```
kubectl run toolbox --image=ghcr.io/camptocamp/georchestra-docker-images/toolbox --restart=Never
```

### Running with network access

```bash
docker run -it --rm --net=host ghcr.io/camptocamp/georchestra-docker-images/toolbox
```

### Running specific tools

```bash
# Use tcpdump to capture packets
docker run -it --rm --net=host --cap-add=NET_RAW ghcr.io/camptocamp/georchestra-docker-images/toolbox tcpdump -i any

# Use mitmproxy
docker run -it --rm -p 8080:8080 ghcr.io/camptocamp/georchestra-docker-images/toolbox mitmproxy
```

## Notes

- Based on Alpine Linux for minimal size
- Runs as non-root user (toolbox) for security
- Requires `--cap-add=NET_RAW` for tcpdump packet capture
- May require `--net=host` for network tools depending on use case
