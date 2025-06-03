# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased](https://github.com/equalitie/ouisync-app/compare/v0.8.3-production...develop)

## [v0.7.2](https://github.com/equalitie/ouisync-app/compare/v0.7.0-beta...v0.7.2)

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

## [v0.7.0-beta](https://github.com/equalitie/ouisync-app/compare/v0.3.11...v0.7.0-beta)

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

## [v0.3.11](https://github.com/equalitie/ouisync-app/compare/v0.3.10...v0.3.11)

- Fix recently broken "enable/disable DHT button" sometimes not switching.
- Network while on Mobile is disabled by default until we figure a better way to do it, because it
  interferes with access point mode.

## v0.3.10

- Disable network on Mobile connection by default
- Tap to lock repositories
- Hints for what users should do in the sharing dialog
