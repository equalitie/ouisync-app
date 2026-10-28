# Testing and building in Docker

This folder contains scripts for testing and building Ouisync App in docker containers.

- The `linux.sh` script is used to run unit and integration tests and to build release packages for
  linux and android.
- The `windows.sh` script is used to build release packages for windows.

## Usage

Run `./docker/linux.sh --help` and `./docker/windows.sh --help` for usage instructions.

## Requirements

To build the release packages, have [pass](https://www.passwordstore.org/) installed with
eQualitie's password repository.
