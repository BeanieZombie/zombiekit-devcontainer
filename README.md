# Zombie Kit Devcontainer

This repository provides a devcontainer image for developing Zombie Kit, optimized for RISC-V and compatible with various architectures.

## Usage

This devcontainer is designed to be used with the `BeanieZombie/zombiekit` repository. Follow the instructions in the Zombie Kit README to set up your development environment.

### Included Tools

- Go (1.24 for runtime and building Sonic tools)
- Bun (latest version) for Viem and Lit Web Components
- Foundry (v0.2.0) for Solidity smart contracts
- Sonic tools (`sonicd`, `sonictool`, v2.0.4)

### Notes

- The image is currently built for `linux/amd64` and `linux/arm64` architectures due to limitations in the `golang:1.24` base image, which does not support `linux/riscv64` in its Docker image manifest. Support for `linux/riscv64` will be added in a future update by building a custom `golang:1.24` image with RISC-V support or using a different Go version that includes `linux/riscv64` manifests.
- Building for `linux/arm64` on GitHub Actions requires a self-hosted ARM64 runner, as the workflow uses a native ARM64 runner to avoid QEMU emulation issues. This repository includes a dockerized self-hosted ARM64 runner setup in the `.github-runner` directory. You can set up the self-hosted ARM64 runner either directly on the host or in a containerized environment. Follow these steps:

  ### Option 1: Run Directly on the Host
  1. Provision an ARM64 machine (e.g., AWS Graviton instance, Raspberry Pi, or Mac mini M1/M2).
  2. Install Docker on the machine:
     ```bash
     sudo apt-get update
     sudo apt-get install -y docker.io
     sudo systemctl start docker
     sudo systemctl enable docker
     ```
  3. Add the user running the GitHub Actions runner to the `docker` group to ensure Docker access:
     ```bash
     sudo usermod -aG docker $USER
     # Log out and log back in, or restart the runner process to apply group changes
     ```
  4. Install the GitHub Actions runner software on the machine. Follow the official GitHub documentation for downloading and configuring the runner: https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners
  5. Register the runner with your repository or organization using the GitHub Actions runner configuration process, applying the labels `self-hosted`, `linux`, and `ARM64`. You can do this via the GitHub UI under `Settings > Actions > Runners > New self-hosted runner`.
  6. Ensure the runner is online and available when running the workflow.

  ### Option 2: Run in a Containerized Environment Using .github-runner
  This repository includes a dockerized GitHub Actions runner setup in the `.github-runner` directory, which you can use to run the self-hosted ARM64 runner in a container. Follow these steps:
  1. Provision an ARM64 machine (e.g., AWS Graviton instance, Raspberry Pi, or Mac mini M1/M2).
  2. Install Docker on the host machine (as in Option 1, steps 1-3).
  3. Clone this repository to the ARM64 machine and navigate to the `.github-runner` directory:
     ```bash
     git clone https://github.com/BeanieZombie/zombiekit-devcontainer.git
     cd zombiekit-devcontainer/.github-runner
     ```
  4. Build the runner image using the provided `Dockerfile`:
     ```bash
     docker build -t beaniezombie/zombiekit-devcontainer-runner:arm64 .
     ```
     - This creates a local image named `beaniezombie/zombiekit-devcontainer-runner:arm64` containing the GitHub Actions runner software.
  5. Obtain a runner token from GitHub:
     - Go to `Settings > Actions > Runners` in your repository on GitHub.
     - Click `New self-hosted runner`, select `Linux` and `ARM64`, and follow the instructions to download the runner and obtain the `RUNNER_TOKEN`.
  6. Run the containerized runner, replacing `YOUR_RUNNER_TOKEN` with the token obtained from GitHub:
     ```bash
     docker run -d --restart always \
       -v /var/run/docker.sock:/var/run/docker.sock \
       -e REPO_URL="https://github.com/BeanieZombie/zombiekit-devcontainer" \
       -e RUNNER_TOKEN="YOUR_RUNNER_TOKEN" \
       --name github-runner-arm64 \
       beaniezombie/zombiekit-devcontainer-runner:arm64
     ```
     - The `-v /var/run/docker.sock:/var/run/docker.sock` flag mounts the host's Docker socket into the container, allowing the runner to communicate with Docker on the host.
     - The `beaniezombie/zombiekit-devcontainer-runner:arm64` image is the one you built in step 4.
     - The `--name github-runner-arm64` names the container for easy management.
  7. Verify that the runner is online in the GitHub UI under `Settings > Actions > Runners`. It should appear with the labels `self-hosted`, `linux`, and `ARM64`.
  8. Ensure the runner container is running and available when executing the workflow. If Docker commands fail (e.g., `docker: Cannot connect to the Docker daemon`), verify that:
     - Docker is running on the host (`sudo systemctl status docker`).
     - The Docker socket is accessible (`ls -l /var/run/docker.sock`).
     - The runner container is properly mounted with the socket (`docker inspect github-runner-arm64 | grep -i docker.sock`).
     - Restart the container if needed (`docker restart github-runner-arm64`).

  If a self-hosted ARM64 runner is not available, the `build-arm64` job will remain stuck in the "Waiting for a runner to pick up this job ..." state. In this case, you can revert to QEMU emulation by updating the `build-arm64` job to run on `Ubuntu-latest` with QEMU, though this may lead to unresponsiveness or timeouts due to the resource-intensive nature of building Sonic.

- The base image `ubuntu:jammy` may contain critical or high vulnerabilities. For production use, consider using a patched version (e.g., `ubuntu:jammy-20250404`) or applying security updates during the build.
- Resource settings are optimized for RISC-V; adjust `runArgs` in `devcontainer.json` if needed.
- The devcontainer includes `sonicd` and `sonictool` (v2.0.4) for development purposes, such as generating genesis files or testing node interactions. It does not run a full Sonic archive node. To run a Sonic archive node, follow the official Sonic documentation at https://docs.soniclabs.com/sonic/node-deployment/archive-node, which requires significant resources (e.g., 1 TB SSD, 32+ GB RAM) and network configuration (port 5050).

## Contributing

When contributing to this repository, please ensure that temporary files, editor configurations, and dependency downloads are not committed. See the `.gitignore` file for details on excluded files.

## License

This project is licensed under the MIT License - see the LICENSE file for details. Note that the `BeanieZombie/zombiekit` repository may have different licensing terms (e.g., BUSL for some components), so ensure compliance when using this devcontainer with `zombiekit`.