# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased](https://github.com/equalitie/ouisync-app/compare/v0.9.2...master)

- Fix generating invalid content URI, breaking file preview and share on Android.
- Fix crash when downloading incomplete file

## [v0.9.2](https://github.com/equalitie/ouisync-app/compare/v0.9.1...v0.9.2)

- Update [Ouisync library](https://github.com/equalitie/ouisync) to [v0.9.3](https://github.com/equalitie/ouisync/blob/master/CHANGELOG.md#v0.9.3) which adds support for [Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider) on Android.

## [v0.9.1](https://github.com/equalitie/ouisync-app/compare/v0.9.0...v0.9.1) - 2025-08-05

- Update [Ouisync library](https://github.com/equalitie/ouisync) to [v0.9.2](https://github.com/equalitie/ouisync/blob/master/CHANGELOG.md#v0.9.2) (no protocol change).
- Update [Flutter](https://flutter.dev/) to [v3.32.5](https://github.com/flutter/flutter/blob/main/CHANGELOG.md#3325).
- Improve logging: capture more relevant log messages and implement log rotation.
- Fix segfault when exiting the app on linux.
- Add more dependencies to the ouisync-gui Debian package.
- Fix repository being deleted prior to confirmation.
- Fix a number of issues related to double clicking on action buttons (repo import, back buttons, file copy/move,...)
- Fix file being moved instead of copied when a file with the same name already existed in the destination folder
- Improve and add tests
- Remove the embedded log viewer

## [v0.9.0](https://github.com/equalitie/ouisync-app/compare/v0.8.3-production...v0.9.0) - 2025-06-05

### Breaking changes

- Update [Ouisync library](https://github.com/equalitie/ouisync) to [v0.9.0](https://github.com/equalitie/ouisync/blob/master/CHANGELOG.md#v0.9.0). Due to the sync protocol changes this version can no longer sync with peers running any of the the previous versions.

### Other changes

- Ongoing work towards improving iOS and macOS support.
- Implement background service icon on Android
- Allow resetting repository access using share token.
- Implement operations on multiple files/directories (copy, move, delete, download and upload).
- Support edge-to-edge mode on Android 15+.
- Various smaller UI/UX improvements.
- Add scripts and Dockerfiles for remote release building.

## [v0.8.3](https://github.com/equalitie/ouisync-app/compare/v0.8.2...v0.8.3-production) - 2024-11-15

- Fix few instances of black screens caused by popping more routes than were pushed into the navigator
- Localize more strings
- Fix storing files from Ouisync onto the file system (storage permissions)

## [v0.8.2](https://github.com/equalitie/ouisync-app/compare/v0.8.1...v0.8.2) - 2024-10-25

- Add a screen for switching languages
- Fix RTL Locale
- Syncing over mobile networks is now off by default
- Fix the Local discovery toggle
- Fix NAT Type detection by ignoring STUN servers which incorrectly return the "alternate-IP" same as their own
- Various fixes and sync speed improvements

## [v0.8.1](https://github.com/equalitie/ouisync-app/compare/v0.8.0...v0.8.1) - 2024-08-22

- Fix issue with Copy/Pasting files into Ouisync on Windows
- Improve explanation of mounting and other errors
- Fix layout issues
- Improve sorting
- Improve progress indication
- Add translations

## [v0.8.0](https://github.com/equalitie/ouisync-app/compare/v0.7.8...v0.8.0) - 2024-05-27

- Add sync progress/activity indicator
- Small improvements to the file and directory sorting functionality
- Small improvements to UI when navigating
- Improve the wording of dialog boxes during installation of Dokan
- Modify the security screen to show the current state + redesign for clarity
- Add SHA256 checksum for each release file
- Change where Ouisync database files are stored (on Android, Windows and Linux)
- Syncing in the background adapted to use less battery power
- Repository secrets and metadata are now stored inside repositories themselves to enable moving repositories around.
- Implement opt-out of using the cache server
- Fix IP address leakage from the caching server
- Bundle Dokan with the Windows installers
- Add port number to the internal IP address in the network settings
- Improvements to the Kotlin and Dart APIs
- Re-enable storing and restoring DHT IP addresses for when the bootstrap server is not reachable
- Fixes Windows/Dokan implementation
- Fix mouting repositories while Dokan is initiating
- Remove legacy settings options and perform migrations
- Stop relying on third party plugins to store secret settings and encrypt all values ourselves using ChaCha20+Poly1305
- Syncing performance improvements
- Change the Windows executable name from `ouisync` to `ouisync-gui`

## [v0.7.8](https://github.com/equalitie/ouisync-app/compare/v0.7.7...v0.7.8) - 2024-01-17

- Show NAT type using the new STUN-based API
- Implement IP and NAT detection with STUN
- Show external addresses using the new STUN-based API
- Make preview available for iOS and desktops
- Support manually added peer, redesign the peers page
- Fix: MOVE button state when navigating to destination
- Fix building msix if exe installer was built beforehand
- Fix cancelation snackbar when downloading file to the device
- Fix building msix if the exe installer was built beforehand
- Fix deleting non-empty folder gets two confirmation dialog boxes
- Fix Farsi localization
- Fix failing file download on desktop
- Auto-fill suggested repo name on import
- Fix showing redundant confirmation dialogs when deleting non-empty folders
- Detect peer disconnection even when the peers don't have any repos
- Fix message reordering
- Implement metrics Recorder for StateMonitor
- Dokan: fix writing the entire file
- Fix creating file names with non ASCII names
- Fix regression where unexpired blocks were not requested again

## [v0.7.7](https://github.com/equalitie/ouisync-app/compare/v0.7.6...v0.7.7) - 2023-12-05

- Update the Ouisync library to fix a bug in re-downloading expired blocks

## [v0.7.6](https://github.com/equalitie/ouisync-app/compare/v0.7.3...v0.7.6) - 2023-12-05

- Fixing issues with downloading files on the device caused by different behavior on different Android versions.
- Better handing of SIGINT and SIGTERM (Ctrl-C) on Linux
- Some work on iOS UI
- Enforce single instance of Ouisync on Linux
- Fix downloading files from Onuisync onto PC on Linux
- Peer count now counts the number of peers, not the number of connections

## [v0.7.3](https://github.com/equalitie/ouisync-app/compare/v0.7.2...v0.7.3) 2023-10-20

- Fixed message explosion caused by non-commutative merges
- Windows msix package
- Add Linux GUI support
- Linux deb package
- Remove the beta tag from icons
- CLI: add option for block expiration
- Implement file preview on desktop using url_launcher
- Replaced crashlytics with sentry
- Removed flavors
- Windows fix: download only works on Download folder
- Fix file download progress indicator
- Improve on-disk performance by implementing block cache and write operation batching

## [v0.7.2](https://github.com/equalitie/ouisync-app/compare/v0.7.0-beta...v0.7.2) - 2023-10-06

- Windows msix package
- Add Linux GUI support
- Linux deb package
- Remove the beta tag from icons
- CLI: add option for block expiration
- Implement file preview on desktop using url_launcher
- Replaced crashlytics with sentry
- Removed flavors
- Windows fix: download only works on Download folder
- Fix file download progress indicator
- Improve on-disk performance by implementing block cache and write operation batching

## [v0.7.0-beta](https://github.com/equalitie/ouisync-app/compare/v0.3.11...v0.7.0-beta) - 2023-07-27

- Create, package and release Windows installer.
- Fix and add notifications for when mounting fails on windows.
- Update new Icons
- Add FAQ page
- Add onboarding pages
- Fix logging on Windows
- Generate dokan2.dll during compilation on Windows
- Add notification and explanation when panic happens
- Move progress bar to the bottom
- More consistent use of capitalization in "Ouisync" name.
- Show warning when background execution is not enabled
- Save logs to the Download directory by default
- Add terms and conditions

## [v0.3.11](https://github.com/equalitie/ouisync-app/compare/v0.3.10...v0.3.11) - 2022-10-01

- Fix recently broken "enable/disable DHT button" sometimes not switching.
- Network while on Mobile is disabled by default until we figure a better way to do it, because it
  interferes with access point mode.

## v0.3.10 - 2022-09-24

- Disable network on Mobile connection by default
- Tap to lock repositories
- Hints for what users should do in the sharing dialog
