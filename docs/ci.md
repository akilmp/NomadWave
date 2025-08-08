# CI Configuration

This repository uses GitLab CI to test, scan, build, and deploy the application.

## Protected variables

Define the following variables in **Settings > CI/CD > Variables** and mark them as *protected* so that they are only available on protected branches and tags.

- `IMAGE_REGISTRY` – Docker registry where images are pushed.
- `NOMAD_ADDR` – URL of the Nomad API endpoint.
- `NOMAD_TOKEN` – Token with permissions to update the Nomad job.

GitLab automatically provides `CI_COMMIT_SHA`, which is used as the image tag.
