# Docker building

This folder contains scripts for building Ouisync App in remote docker containers.

The `build-linux.sh` script will build `aab`, `apk`, `deb-cli` and `deb-gui` packages.
The `build-windows.sh` script will build `msix` and `exe` packages.

## Usage

Assuming you have machines running Docker listed in your `~/.ssh/config` as `linux_machine` and `windows_machine`, run

```bash
./docker/build-linux.sh --host linux_machine --commit <COMMIT_HASH>
./docker/build-windows.sh --host windows_machine --commit <COMMIT_HASH>
```

## Requirements

Have [pass](https://www.passwordstore.org/) installed with eQualitie's password repository.
