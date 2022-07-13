# OuiSync Docker Build

## Android Bundle (Linux)
To create an image that builds OuiSync for Android and generates a signed bundle file (`.aab`), you need to run the build command and pass the parameters used to sign the bundle: `build_name`, `buiild_number`, `keystore`, and `keystore_password_file` name.
Also provide a path to the location, so the signed bundle can be copy to it, using the paramater `output_destination`.

**Important:** Before building the `Dockerfile`, remember to place the keystore (`.jks` file), and the keystore password file (`.txt` file), in the same location that the `Dockerfile`, which is the one from where the build command is being executed.

#### build name
A version triple such as `0.0.1` or `0.0.1-rc1`

#### build number
An identifier used as an internal version number.
Each build must have a unique identifier to differentiate it from previous builds.

**Note:** you can run `flutter build appbundle -h` for more info

#### keystore
Name of the keystore used for signing the app bundle (`.jks` file). 

#### keystore password file
Name of the file containing the password to unlock the keystore (`.txt` file).

#### output_destination
Path to the location where the build command is being executed (in the **HOST**)

Run this command:

`sudo docker build --build-arg build_name=<build-name> --build-arg build_number=<build-number> --build-arg keystore=<keystore-name> --build-arg keystore_password_file=<password-file-name> --build-arg output_destination=<destination-path>  -t <tag> .`

**Note:** By default, docker will run using **BuildKit**. If you want to dissable it, just add `DOCKER_BUILDKIT=0` at the beginning of the command, right between `sudo` and `docker`
