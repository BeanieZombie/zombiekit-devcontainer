#!/bin/bash

# Configure the runner
./config.sh --url $REPO_URL --token $RUNNER_TOKEN --labels self-hosted,linux,ARM64 --unattended --replace

# Run the GitHub runner
./run.sh