FROM cirrusci/windowsservercore:visualstudio2022-2022.06.23 as android-sdk

## Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

WORKDIR C:/TEMP

ADD https://download.java.net/java/GA/jdk19.0.2/fdb695a9d9064ad6b064dc6df578380c/7/GPL/openjdk-19.0.2_windows-x64_bin.zip .

RUN mkdir C:\OpenJDK19 && \
    tar -zxvf openjdk-19.0.2_windows-x64_bin.zip -C C:\OpenJDK19

RUN setx JAVA_HOME "C:\OpenJDK19\jdk-19.0.2"

RUN setx path "%path%;%JAVA_HOME%\bin"

ADD https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip .

RUN tar -zxvf commandlinetools-win-9477386_latest.zip

RUN mkdir C:\Android\android-sdk

RUN yes | cmdline-tools\bin\sdkmanager "platform-tools" "platforms;android-33" "cmdline-tools;latest" "build-tools;33.0.2" "ndk;25.2.9519653" --sdk_root=C:\Android\android-sdk

RUN setx ANDROID_HOME "C:\Android\android-sdk"

RUN setx path "%path%;%ANDROID_HOME%\tools;%ANDROID_HOME%\tools\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\cmdline-tools\latest\bin"

FROM android-sdk as rust

# Install Rust (rustup)

ADD https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe C:/TEMP/rustup-init.exe
RUN powershell.exe -Command \
        C:\TEMP\rustup-init.exe -y \
        && del C:\TEMP\rustup-init.exe

RUN rustup target add aarch64-linux-android && \
    rustup target add armv7-linux-androideabi && \
    rustup target add x86_64-linux-android && \
    rustup target add aarch64-unknown-linux-gnu && \
    rustup target add armv7-unknown-linux-gnueabihf

FROM rust as flutter

# Install LLVM for ffigen

ADD https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.1/LLVM-16.0.1-win64.exe C:/TEMP/LLVM-16.0.1-win64.exe
RUN powershell.exe -Command \
        C:\TEMP\LLVM-16.0.1-win64.exe /S

# Install Google Root R1 cert so pub.dartlang.org stays working

ADD https://pki.goog/repo/certs/gtsr1.pem C:/TEMP/gtsr1.pem
RUN powershell.exe -Command \
        Import-Certificate -FilePath C:\TEMP\gtsr1.pem -CertStoreLocation Cert:\LocalMachine\Root

# Install Flutter

ADD https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.7.11-stable.zip C:/TEMP/flutter_windows_3.7.11-stable.zip

RUN \
    mkdir C:\src && \
    tar -zxvf C:/TEMP/flutter_windows_3.7.11-stable.zip -C "C:\src"

RUN setx path "%path%;C:\src\flutter\bin\;C:\src\flutter\bin\cache\dart-sdk\bin"

RUN flutter config --no-analytics

RUN flutter config --enable-windows-desktop

RUN yes | flutter doctor --android-licenses

RUN flutter doctor

FROM flutter as ouisync-code

RUN mkdir C:\code && \
    cd C:\code

WORKDIR C:/code

RUN git clone https://github.com/equalitie/ouisync-app && \
    cd ouisync-app && \
    git checkout master && \
    git submodule update --init --recursive 

RUN echo "rust.rustcCommand=C:\\Users\\ContainerAdministrator\\.cargo\\bin\\rustc" >> C:\code\ouisync-app\android\local.properties
RUN echo "rust.cargoCommand=C:\\Users\\ContainerAdministrator\\.cargo\\bin\\cargo" >> C:\code\ouisync-app\android\local.properties

RUN cd C:\code\ouisync-app\ouisync-plugin\ouisync && \
        cargo build --release -p ouisync-ffi && \
        cargo run --bin bindgen

RUN cd C:\code\ouisync-app\ouisync-plugin && \
        flutter pub get && \
        flutter pub run ffigen

RUN cd C:\code\ouisync-app && \
        flutter pub get

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

WORKDIR C:/code/ouisync-app