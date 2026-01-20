# About

This directory builds an Apache HTTPd server being used in the `geOrchestra` deployments.

It is currently being used in most of our deployments, either under Kubernetes, or in some docker-compose based deployments.

# Notes

The image derives from the official php-apache flavour image.

Please update the `FROM:` image when a new version is out.
