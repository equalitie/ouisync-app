## Building macOS

### 1. Build the Rust native core

Xcode and Flutter don't automatically compile the Rust backend, so build it manually:

```bash
cd ouisync/bindings/swift/OuisyncLib
bash build-xcframework.sh
```

This builds:
- The Rust service for macOS (both x86_64 and arm64)
- Static library (`OuisyncLibFFI.xcframework`) for the File Provider extension
- Dynamic framework (`OuisyncService.framework`) for the main app

### 2. Set up CocoaPods

```bash
cd macos
pod install
cd ..
```

### 3. Build Flutter dependencies and the app

```bash
flutter build macos --release
```

Or for development with hot-reload:

```bash
flutter run -d macos
```

### 4. Open in Xcode (optional)

To debug or develop further:

```bash
open macos/Runner.xcworkspace
```

Always open `.xcworkspace`, not `.xcodeproj`. Then build/run via Xcode (`Cmd+B` / `Cmd+R`).

### Removing the file provider extension

Sometimes the extension misbehaves and/or xcode won't start the newly compiled binary.
If that happens it is sometimes useful to remove the extension from the system:

```bash
  local path=`pluginkit -mvi org.equalitie.ouisync.OuisyncFileProvider | awk '{ printf("%s", $7) }'`
  pluginkit -r $path
```
