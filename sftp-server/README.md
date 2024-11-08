# About

This docker build is a slightly simplified version of the SFTP stack being
used in the `geOrchestra` deployments.

It is currently being used in most of our deployments, either under Kubernetes.

# Notes

This is based on Debian bookworm, the latest stable Debian version at the time for writing.

Please update the `FROM:` debian image when a new Debian version is out.
