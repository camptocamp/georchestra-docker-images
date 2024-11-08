# About

Custom Docker images for the geOrchetra team.

Currently host:
- sftp-server: `ghcr.io/camptocamp/georchestra-docker-images/sftp-server`
- apache-nas: `ghcr.io/camptocamp/georchestra-docker-images/apache-nas`

# Update a Docker image

1. Do your changes in the folder of the Docker image.
2. Go to the workflow of the Docker image, example `.github/workflows/docker-build-sftp-server.yml`
3. Update the version of the Docker image for `VERSION:`.
4. Push your changes.

# How to add a new Docker image

## If it's a script or a custom tool that exist only for Rennes métropole (or only in this repository)
1. Copy an existing workflow file based on sftp-server.
2. Change the workflow name: `name:`.
3. Adapt the paths in `push.paths`.
4. For the step `docker_build`, adapt every parameter to the project name.
5. Set a version for the Docker image in `VERSION:`

# Explanation about the workflows with a schedule.
These workflows will be rebuilt every X time (`0 */12 * * *` for most of them).

They will fetch the latest version for the version specified in the workflow file then try to build a new docker image if the version has never been built. You can change that by setting to a fixed version.

This allows to update the environment as quickly as possible because if a new geOrchestra version comes out then the new Docker images will already be ready.