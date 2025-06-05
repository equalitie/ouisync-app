## Some tips for working on macos

### Building

Currently xcode nor flutter for darwin doesn't compile the Rust backend automatically
thus one has to do it manually:

```bash
(cd ouisync; cargo build -p ouisync-service)
```

And then copy the `libouisync_service.dylib` to where xcode can find it:

```bash
  cp ouisync/target/debug/libouisync_service.dylib ouisync/bindings/dart/macos/
```

Further, xcode won't build flutter dependencies so this has to be done outside
of xcode as well:

```bash
flutter build -d macos
```

After the above, one can either run and debug ouisync from xcode or from the command
line as such:

```bash
flutter run
```

### Removing the file provider extension

Sometimes the extension misbehaves and/or xcode won't start the newly compiled binary.
If that happens it is sometimes useful to remove the extension from the system:

```bash
  local path=`pluginkit -mvi org.equalitie.ouisync.OuisyncFileProvider | awk '{ printf("%s", $7) }'`
  pluginkit -r $path
```
