# duisync-darwin
This folder hosts code specific to deploying Ouisync to apple devices.

## Supported platforms
Currently, macOS 11+ and iOS 16+ are supported targets.

## Requirements
To build, you must have a mac and:

* [xcode](https://apps.apple.com/us/app/xcode/id497799835) 15.2 or above
  (earlier versions are not tested)
* [flutter](https://docs.flutter.dev/release/archive#stable-channel-macos)
  ideally installed via [VS Code](https://code.visualstudio.com/) because it
  comes with a dart debugger and that's what most of the UI is written in
* [cocoapods](https://cocoapods.org/), preferrably via `brew install cocoapods`
  since the ruby that's bundled with macOS is no longer supported
* a paid [Apple Developer Program](https://developer.apple.com/programs/enroll/)
  account (a free account is insufficient to build due to our use of app groups)
* at least 10GB of free space (after installing the above)

## Building
1. `git clone git@github.com:equalitie/ouisync-app && cd ouisync-app`
2. `git clone git@github.com:equalitie/ouisync` (or `git submodule update` if
   you don't use ssh auth / don't want to push changes)
3. `darwin/init` to install the remaining dependencies
4. `flutter build macos` (grab a cup of ☕️ or 🍵 cause this will take some time)
5. `open macos/Runner.xcworkspace` to continue development (the first build must
   be done from the command line, though you can debug it via Xcode afterwards)

## Tips & tricks
* Xcode cannot currently open the same package in multiple windows; as such,
  if you work on iOS and macOS at the same time, only the first opened workspace
  will be able to access the shared dependencies: `OuisyncCommon`,
  `OuisyncBackend` or `OuisyncLib`.
* Your first build will take a long time because it involves cross-compiling
  the rust library on most suppoerted platforms; you can speed things up by
  editing `config.sh` from the `OuisyncLib` package and disabling un-needed
  platforms or opting for lighter release builds instead of debug
* Importing and enabling `FileProvider.mobileconfig` will provide you with more
  Console logs in case something goes wrong

## Troubleshooting
* `Module 'biometric_storage' not found`: You can only build from Xcode by
  opening the `.xcworkspace`; opening the `.xcproject` will leave you unable to
  load dependencies and, as far as I can tell, this is an
  [intentional](https://docs.flutter.dev/deployment/ios#review-xcode-project-settings)
  decision made by early flutter devs and one that cannot be easily fixed. If
  you have opened the workspace, you may need to run `flutter build macos` or
  `flutter build ios` to ensure your dependencies are up to date
* `Unable to load contents of file list: 'ouisync-app/macos/Flutter/ephemeral/FlutterInputs.xcfilelist'`:
  appears to be a [known issue](https://github.com/flutter/flutter/issues/115804#issuecomment-1324164871)
  in Flutter; current workaround is to run `flutter build macos` after checkout
  and after every `flutter clean` before building from Xcode
* `Linker command failed with exit code 1 (use -v to see invocation)`:
  9 times out of 10, this means that your ouisync rust framework was not built
  correctly: this can either be because you didn't successfully run
  `Update rust dependencies` (right click on the OuisyncLib package in Xcode or
  `darwin/update-rust-dependencies`) before building or because you've disabled
  your current platform in `config.sh`; the 10th time, it's something else and
  you will have to inspect the logs to figure out what

