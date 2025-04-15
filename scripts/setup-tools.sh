#!/bin/bash

     # Install Bun (pin to a specific version)
     BUN_VERSION="1.1.0"
     curl -fsSL https://bun.sh/install | bash -s -- $BUN_VERSION
     echo 'export PATH=$PATH:$HOME/.bun/bin' >> $HOME/.bashrc
     export PATH=$PATH:$HOME/.bun/bin

     # Install Foundry (pin to a specific version)
     curl -L https://foundry.paradigm.xyz | bash
     $HOME/.foundry/bin/foundryup --version v0.2.0
     echo 'export PATH=$PATH:$HOME/.foundry/bin' >> $HOME/.bashrc
     export PATH=$PATH:$HOME/.foundry/bin

     # Install sonicd and sonictool (already pinned to v2.0.1)
     SONIC_DIR=$HOME/sonic
     mkdir -p $SONIC_DIR
     cd $SONIC_DIR
     git clone https://github.com/0xsoniclabs/Sonic.git .
     git fetch --tags && git checkout -b v2.0.1 tags/v2.0.1
     make all
     mkdir -p $HOME/bin
     cp build/bin/sonicd $HOME/bin/
     cp build/bin/sonictool $HOME/bin/
     echo 'export PATH=$PATH:$HOME/bin' >> $HOME/.bashrc
     export PATH=$PATH:$HOME/bin