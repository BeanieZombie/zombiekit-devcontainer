# ZombieKit DevContainer

This repository provides a DevContainer environment for developing ZombieKit, optimized for RISC-V and compatible with various architectures.

## Usage

This DevContainer is designed to be used with the `BeanieZombie/zombiekit` repository.

It provides a complete development environment including:

- Go (1.24)
- Bun (latest version) for frontend web development (Viem, Lit Web Components)
- Foundry (v0.2.0) for Solidity smart contract development
- Docker CLI for modular infrastructure management (via docker-compose)

**Sonic Node runtime has been fully modularized.**
The Sonic blockchain node is run as a separate container via Docker Compose.

ZombieKit Core connects to Sonic over RPC (`http://sonic-node:8545`).

Follow the instructions in the ZombieKit main repository to start the Sonic node:

```bash
docker compose up -d sonic-node
```

Genesis priming is automatically handled by the `sonic-node` container on first boot if needed.

---

## Included Tools

- Go 1.24
- Bun (latest)
- Foundry v0.2.0
- Docker CLI + Docker Compose

---

## Notes

- The DevContainer supports `linux/amd64` and `linux/arm64` architectures.
- Support for `linux/riscv64` will be added in a future update by building a custom Go base image or using a future upstream version with RISC-V support.
- For `linux/arm64`, a self-hosted GitHub Actions runner is needed for native building. See `.github-runner` setup instructions.
- The DevContainer **does not run Sonic node internally**. Sonic is launched as a modular service via Docker Compose.
- Running a full Sonic archive node requires significant resources (1 TB SSD, 32+ GB RAM) and must be deployed outside of the DevContainer environment. Refer to Sonic Labs documentation: https://docs.soniclabs.com/sonic/node-deployment/archive-node

---

## Contributing

When contributing to this repository, please ensure that temporary files, editor configurations, and dependency downloads are not committed. See the `.gitignore` file for excluded files.

---

## License

This project is licensed under the MIT License — see the LICENSE file for details.

Note: The `BeanieZombie/zombiekit` repository may have different licensing terms (e.g., BUSL for some components). Ensure compliance when using this DevContainer environment.
