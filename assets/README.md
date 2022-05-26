We're using the `icons_launcher` package to generate the icons for each platform.
Once the base icon in this folder is changed, for it to take effect one has to run:

```
flutter pub get
flutter pub run icons_launcher:create
```

As described [here](https://pub.dev/packages/icons_launcher).

The configuration for the icons generation are located in `icons_launcher.yaml`

**NOTE**: We are using adaptive icons for Android, and the confiuguration files are located, together with the required images, in `/assets`.
A round icon is also provided, in case is needed for some Android OEMs
