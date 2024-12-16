FROM cirrusci/windowsservercore:visualstudio2022-2022.06.23 as android-sdk

## Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# We'll use this folder for all the installers
WORKDIR C:/TEMP

# Download OpenJDK 19(0.2)
ADD https://download.java.net/java/GA/jdk19.0.2/fdb695a9d9064ad6b064dc6df578380c/7/GPL/openjdk-19.0.2_windows-x64_bin.zip .

# Extract into C:\OpenJDK19
RUN mkdir C:\OpenJDK19 && \
    tar -zxvf openjdk-19.0.2_windows-x64_bin.zip -C C:\OpenJDK19

# Update the JAVA_HOME variable with the OpenJDK location, and the PATH 
RUN setx JAVA_HOME "C:\OpenJDK19\jdk-19.0.2"
RUN setx path "%path%;%JAVA_HOME%\bin"

# Download Android command line tools (latest)
ADD https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip . 

# Extract into C:\TEMP\cmdline-tools
RUN tar -zxvf commandlinetools-win-9477386_latest.zip

# Create the folders for the Android SDK, NDK and tools
RUN mkdir C:\Android\android-sdk

# Use sdkmanager for installing platform-tools, Android SDK 33, command line tools (latest), build tools (33.0.2) and Android NDK (25.2.9519653) on C:\Android\android-sdk
RUN yes | cmdline-tools\bin\sdkmanager "platform-tools" "platforms;android-33" "cmdline-tools;latest" "build-tools;33.0.2" "ndk;25.2.9519653" --sdk_root=C:\Android\android-sdk

# Update ANDROID_HOME with the Android SDK path, and the PATH
RUN setx ANDROID_HOME "C:\Android\android-sdk"
RUN setx path "%path%;%ANDROID_HOME%\tools;%ANDROID_HOME%\tools\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin"

FROM android-sdk as rust

WORKDIR C:/TEMP

# Download rustup (Rust)
ADD https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe .

# Install rustup
RUN powershell.exe -Command \
        C:\TEMP\rustup-init.exe -y

# Add the targets for the supported platforms (Note: The target for the platform running the rustup installation (Window, Linux, Mac) was already added by the installer)
RUN rustup target add aarch64-linux-android && \
    rustup target add armv7-linux-androideabi && \
    rustup target add x86_64-linux-android && \
    rustup target add aarch64-unknown-linux-gnu && \
    rustup target add armv7-unknown-linux-gnueabihf

# Install Python for the library compilation
RUN choco install python -y

FROM rust as flutter

WORKDIR C:/TEMP

# Install LLVM for ffigen
ADD https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.1/LLVM-16.0.1-win64.exe .
RUN powershell.exe -Command \
        C:\TEMP\LLVM-16.0.1-win64.exe /S

# Install Google Root R1 cert so pub.dartlang.org stays working
ADD https://pki.goog/repo/certs/gtsr1.pem .
RUN powershell.exe -Command \
        Import-Certificate -FilePath C:\TEMP\gtsr1.pem -CertStoreLocation Cert:\LocalMachine\Root

# Download Flutter (stable)
ADD https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.7.11-stable.zip .

# Extract into C:\src 
RUN mkdir C:\src && \
    tar -zxvf C:/TEMP/flutter_windows_3.7.11-stable.zip -C "C:\src"

# Update PATH with the Flutter and Dart locations
RUN setx path "%path%;C:\src\flutter\bin\;C:\src\flutter\bin\cache\dart-sdk\bin"

# Flutter configurations
RUN flutter config --no-analytics
RUN flutter config --enable-windows-desktop
RUN yes | flutter doctor --android-licenses

RUN flutter doctor

FROM flutter as ouisync-code

# Create folder for the ouisync-app code
RUN mkdir C:\code

WORKDIR C:/code

# Clone the ouisync-app repository and initialize its submodules (ouisync-plugin, ouisync)
RUN git clone https://github.com/equalitie/ouisync-app && \
    cd ouisync-app && \
    git checkout master && \
    git submodule update --init --recursive 

# Update android\local.properties with the location to rustc and cargo
RUN echo "rust.rustcCommand=C:\\Users\\ContainerAdministrator\\.cargo\\bin\\rustc" >> C:\code\ouisync-app\android\local.properties
RUN echo "rust.cargoCommand=C:\\Users\\ContainerAdministrator\\.cargo\\bin\\cargo" >> C:\code\ouisync-app\android\local.properties

# Build the ouisync library and generate the headers
RUN cd C:\code\ouisync-app\ouisync-plugin\ouisync && \
        cargo build --release -p ouisync-service && \
        cargo run --bin bindgen

# Get the plugin dependencies and generate the bindings for the library headers
RUN cd C:\code\ouisync-app\ouisync-plugin && \
        flutter pub get && \
        flutter pub run ffigen

# Get the app dependencies
RUN cd C:\code\ouisync-app && \
        flutter pub get

# If you want the ability to SSH into this container, uncomment the following section

# FROM ouisync-code as SSHLogLevel

# # Install OpenSSH Server 8.6.0-beta1 (https://community.chocolatey.org/packages/openssh/8.6.0-beta1)
# RUN choco install openssh --version=8.6.0-beta1 -y --params "'/SSHServerFeature /AlsoLogToFile /SSHLogLevel:DEBUG2'"

# # Setup OpenSSH
# RUN net user docker /add \
#     && net localgroup administrators docker /add \
#     && powershell -Command New-Item -Type File -Path C:\ProgramData\ssh\administrators_authorized_keys; \
#     Set-Acl C:\ProgramData\ssh\administrators_authorized_keys -AclObject (Get-Acl C:\ProgramData\ssh\ssh_host_dsa_key)

# # OpenSSH Server
# EXPOSE 22/tcp

# Remove all the installers
RUN rm C:\TEMP -r

WORKDIR C:/code/ouisync-app