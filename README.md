# Zombie Kit Devcontainer

This repository provides a devcontainer image for developing Zombie Kit, optimized for RISC-V and compatible with various architectures.

## Usage

This devcontainer is designed to be used with the `BeanieZombie/zombiekit` repository. Follow the instructions in the Zombie Kit README to set up your development environment.

### Included Tools

- Go (1.24 for runtime and building Sonic tools)
- Bun (latest version) for Viem and Lit Web Components
- Foundry (v0.2.0) for Solidity smart contracts
- Sonic tools (`sonicd`, `sonictool`, v2.0.1)

### Notes

- The image is currently built for `linux/amd64` and `linux/arm64` architectures due to limitations in the `golang:1.24` base image, which does not support `linux/riscv64` in its Docker image manifest. Support for `linux/riscv64` will be added in a future update by building a custom `golang:1.24` image with RISC-V support or using a different Go version that includes `linux/riscv64` manifests.
- The base image has been updated to `ubuntu:jammy-20250404` to include recent security patches and address critical/high vulnerabilities.
- Resource settings are optimized for RISC-V; adjust `runArgs` in `devcontainer.json` if needed.
- The devcontainer includes `sonicd` and `sonictool` (v2.0.1) for development purposes, such as generating genesis files or testing node interactions. It does not run a full Sonic archive node. To run a Sonic archive node, follow the official Sonic documentation at https://docs.soniclabs.com/sonic/node-deployment/archive-node, which requires significant resources (e.g., 1 TB SSD, 32+ GB RAM) and network configuration (port 5050).

## Contributing

When contributing to this repository, please ensure that temporary files, editor configurations, and dependency downloads are not committed. See the `.gitignore` file for details on excluded files.

## License

This project is licensed under the MIT License - see the LICENSE file for details. Note that the `BeanieZombie/zombiekit` repository may have different licensing terms (e.g., BUSL for some components), so ensure compliance when using this devcontainer with `zombiekit`.