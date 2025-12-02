# About

Custom Docker images for the geOrchetra team.

Currently host: https://github.com/orgs/camptocamp/packages?repo_name=georchestra-docker-images

# Update a Docker image

1. Do your changes in the folder of the Docker image.
4. Push your changes.

# How to add a new Docker image

## If it's a script or a custom tool (or only in this repository)
1. Copy an existing workflow file based on sftp-server.
2. Change the workflow name: `name:`.
3. Adapt the paths in `push.paths`.
4. For the step `docker_build`, adapt every parameter to the project name.
