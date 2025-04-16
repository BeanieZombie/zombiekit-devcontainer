# Self-Hosted GitHub Actions Runner (Dockerized)

This directory contains the Dockerfile and scripts to run a self-hosted GitHub Actions runner inside a container for the `zombiekit-devcontainer` project.

---

## Features

- ARM64-native runner (Linux)
- Docker-in-Docker support for build & push workflows
- Multi-arch ready (via QEMU + Buildx)
- Auto-registers with GitHub on startup
- Persistent volume for credentials and configuration

---

## Files

| File             | Purpose                                                        |
|------------------|----------------------------------------------------------------|
| `Dockerfile`     | Builds Ubuntu + Docker + GitHub Runner stack                  |
| `entrypoint.sh`  | Automatically configures and launches the GitHub runner       |
| `.dockerignore`  | Optional – reduces Docker build context                       |
| `.gitignore`     | Optional – prevents downloaded runner binaries from being committed |

---

## Step 1: Build the Runner Image

From the project root:

```bash
docker build -t github-runner-arm64 .github-runner
```

---

## Step 2: Run the Containerized Runner

Replace `YOUR_GITHUB_RUNNER_TOKEN` with a token from the GitHub Actions runner setup page:

```bash
docker run -d --restart always \
  --name github-runner-arm64 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v github-runner-data:/home/runner \
  --group-add docker \
  -e REPO_URL="https://github.com/BeanieZombie/zombiekit-devcontainer" \
  -e RUNNER_TOKEN="YOUR_GITHUB_RUNNER_TOKEN" \
  github-runner-arm64
```

Generate a new token here:
https://github.com/BeanieZombie/zombiekit-devcontainer/settings/actions/runners/new

---

## Step 3: Confirm the Runner is Registered

Go to your GitHub repository:

```
Settings → Actions → Runners
```

You should see the runner online with these labels:

```
self-hosted, linux, ARM64
```

---

## Step 4: Cleanup (Optional)

To stop and remove the runner container:

```bash
docker stop github-runner-arm64 && docker rm github-runner-arm64
docker rmi github-runner-arm64
```

---

## Prerequisites

- Docker must be installed on the host machine
- Host system must be ARM64 or have QEMU + binfmt_misc enabled
- Outbound internet access to GitHub and GHCR (ghcr.io)
- A GitHub token with `repo` and `write:packages` scopes

---

## Notes

- This runner enables the `build-arm64` GitHub Actions job
- Connects to the host’s Docker daemon via `/var/run/docker.sock`
- Runner data is persisted using the `github-runner-data` volume

---

## References

- https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners
- https://docs.docker.com/buildx/working-with-buildx/
- https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
