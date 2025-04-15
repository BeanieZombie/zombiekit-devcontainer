 This repository provides a devcontainer image for developing [Zombie Kit](https://github.com/BeanieZombie/zombiekit), optimized for RISC-V and compatible with various architectures.

 ## Usage

 This devcontainer is designed to be used with the `BeanieZombie/zombiekit` repository. Follow the instructions in the [Zombie Kit README](https://github.com/BeanieZombie/zombiekit/blob/main/README.md) to set up your development environment.

 ### Included Tools
 - Go (1.24) with GoFiber support
 - Bun (1.1.0) for Viem and Lit Web Components
 - Foundry (v0.2.0) for Solidity smart contracts
 - Sonic tools (`sonicd`, `sonictool`, v2.0.1)

 ### Notes
 - The image is built for multiple architectures (`linux/amd64`, `linux/arm64`, `linux/riscv64`) to support Zombie Boxes on various hardware.
 - Resource settings are optimized for RISC-V; adjust `runArgs` in `devcontainer.json` if needed.

 ## Contributing

 When contributing to this repository, please ensure that temporary files, editor configurations, and dependency downloads are not committed. See the [`.gitignore`](./.gitignore) file for details on excluded files.

 ## License

 This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. Note that the `BeanieZombie/zombiekit` repository may have different licensing terms (e.g., BUSL for some components), so ensure compliance when using this devcontainer with `zombiekit`.