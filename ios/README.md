## Building iOS

### 1. Build the Rust native core

Xcode and Flutter don't automatically compile the Rust backend, so build it manually:

```bash
cd ouisync/bindings/swift/OuisyncLib
bash build-xcframework.sh
```

This builds:
- The Rust service for iOS (arm64)
- Static library (`OuisyncLibFFI.xcframework`) for the File Provider extension
- Dynamic framework (`OuisyncService.framework/ios/`) for the main app

### 2. Set up CocoaPods

```bash
cd ios
pod install
cd ..
```

### 3. Build Flutter dependencies and the app

```bash
flutter build ios --release
```

Or for development with hot-reload on a simulator:

```bash
flutter run -d "iPhone 15 Pro"  # Use your preferred simulator
```

### 4. Open in Xcode (optional)

To debug or develop further:

```bash
open ios/Runner.xcworkspace
```

Always open `.xcworkspace`, not `.xcodeproj`. Select the `Runner` scheme (not the File Provider extension), then build/run via Xcode (`Cmd+B` / `Cmd+R`).

## Archiving for TestFlight

```bash
flutter build ios --release
open ios/Runner.xcworkspace
# In Xcode: Product → Archive
```

Then distribute via Xcode Organizer.

## Troubleshooting

**"Module 'ouisync' not found"**: Always open `.xcworkspace`, not `.xcodeproj`.

**"Unable to load OuisyncService.framework"**: Ensure `build-xcframework.sh` completed successfully and that `ouisync/bindings/dart/darwin/ios/OuisyncService.framework` exists.

**File Provider extension not loading**: The extension is a separate target. Make sure you're building/running the `Runner` scheme, not the extension itself.
