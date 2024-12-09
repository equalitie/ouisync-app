# duisync-darwin
This folder hosts code specific to deploying the ouisync library to apple devices.

## Supported platforms
Currently, macOS 11+ and iOS 16+ are supported targets.

## Requirements
To build, you must have a mac and the following:

* [xcode](https://apps.apple.com/us/app/xcode/id497799835) 15.2 or above
  (earlier versions are not tested)
* xcode command line tools:
  `xcode-select --install`
* [rust](https://www.rust-lang.org/):
  `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
* [flutter](https://docs.flutter.dev/release/archive#stable-channel-macos)
* [cocoapods](https://cocoapods.org/):
  `sudo gem install cocoapods` or
  `brew install cocoapods`
* an account that is a (paid) member of the
  [Apple Developer Program](https://developer.apple.com/programs/enroll/)
  WARN: a free account is insufficient to build due to our use of app groups

## Tips & tricks
* Xcode cannot currently open the same package in multiple windows; as such,
  if you work on iOS and macOS at the same time, only the first opened workspace
  will be able to access the shared dependencies: `OuisyncCommon`,
  `OuisyncBackend` or `OuisyncLib`.
* Your first build will take a long time because it involves cross-compiling
  the rust library on all platforms; you can speed things up by editing
  `config.sh` from the `OuisyncLib` package dependency and opting for a release
  build instead of a (much larger) debug build

## Troubleshooting
* `Module 'biometric_storage' not found`: You can only build from Xcode by
  opening the `.xcworkspace`; the `.xcproject` will leave you unable to load
  dependencies; as far as I can tell, this is an
  [intentional decision](https://docs.flutter.dev/deployment/ios#review-xcode-project-settings)
  made by early flutter devs and one that cannot be (easily) worked around.
  If you already opened the workspace, you need to run `pod install` from
  either `macos` or `ios`
* `Unable to load contents of file list: 'ouisync-app/macos/Flutter/ephemeral/FlutterInputs.xcfilelist'`:
  appears to be a [known issue](https://github.com/flutter/flutter/issues/115804#issuecomment-1324164871)
  in Flutter; current workaround is to run `flutter build macos` after checkout
  and after every `flutter clean` before building from Xcode
* `Linker command failed with exit code 1 (use -v to see invocation)`:
  9 times out of 10, this means that your ouisync rust framework was not built
  correctly: this can either be because you didn't successfully run
  `Update rust dependencies` before building, the OuisyncLib build plugin did
  not run or you've disabled your current target in `config.sh`
