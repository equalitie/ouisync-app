# Based in the Windows Dockerfile for Android SDK 30 from CirusCI:
# https://git.openprivacy.ca/openprivacy/flutter-desktop/src/branch/main/windows/Dockerfile
FROM cirrusci/android-sdk:30-windowsservercore-2019 as tools

# Install VS
## https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019

## Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

## Download the Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/channel C:/TEMP/VisualStudio.chman

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:/TEMP/vs_buildtools.exe
## https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019

# When installing Visual Studio, we need Desktop development with C++ components.
# For that we need to add: Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core
RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache \
    --channelUri C:\TEMP\VisualStudio.chman \
    --installChannelUri C:\TEMP\VisualStudio.chman \
    --add Microsoft.VisualStudio.Component.Windows10SDK.19041 \
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
    --add Microsoft.VisualStudio.Component.VC.CMake.Project \
    --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core \
    --add Microsoft.VisualStudio.Workload.NativeDesktop \
    --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools \
    --add Microsoft.VisualStudio.Workload.VCTools \
    --add Microsoft.VisualStudio.Component.VC.CLI.Support \
    --installPath C:\BuildTools \
     || IF "%ERRORLEVEL%"=="3010" EXIT 0

# Install Google Root R1 cert so pub.dartlang.org stays working

ADD https://pki.goog/repo/certs/gtsr1.pem C:/TEMP/gtsr1.pem
RUN powershell.exe -Command \
        Import-Certificate -FilePath C:\TEMP\gtsr1.pem -CertStoreLocation Cert:\LocalMachine\Root

# Install LLVM for ffigen

ADD https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.6/LLVM-14.0.6-win64.exe C:/TEMP/LLVM-14.0.6-win64.exe
RUN powershell.exe -Command \
        C:\TEMP\LLVM-14.0.6-win64.exe /S

# Install Rust (rustup)

ADD https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe C:/TEMP/rustup-init.exe
RUN powershell.exe -Command \
        C:\TEMP\rustup-init.exe -y

FROM tools as flutter

# Install Flutter

RUN setx path "%path%;C:\flutter\bin;C:\flutter\bin\cache\dart-sdk\bin;"

RUN git clone -b stable https://github.com/flutter/flutter.git C:\flutter

RUN flutter config --no-analytics

RUN flutter config --enable-windows-desktop

## Fix android sdk licenses (missing in cirruslabs container)
RUN powershell.exe -Command \
        Set-Content -Value "`n859f317696f67ef3d7f30a50a5560e7834b43903" -Path C:\Android\licenses\android-sdk-arm-dbt-license

# Install Android Command Line Tools

#RUN powershell.exe -Command \
#        cd \Android\tools\bin && \
#        sdkmanager --install "cmdline-tools;latest"

RUN flutter doctor -v 

FROM flutter as checkout-code

RUN echo "Checking out branch $branch" && \
    git clone https://github.com/equalitie/ouisync-app && git -C ouisync-app checkout master && \
    cd ouisync-app && \
    git submodule update --init --recursive 

#RUN echo "rust.rustcCommand=\Users\ContainerAdministrator\.cargo\bin\rustc" >> C:\ouisync-app\android\local.properties
#RUN echo "rust.cargoCommand=\Users\ContainerAdministrator\.cargo\bin\cargo" >> C:\ouisync-app\android\local.properties

FROM checkout-code as build

RUN cd \ouisync-app\ouisync-plugin\ouisync && \
    cargo build --release --lib && \
    cargo run --bin bindgen

RUN cd \ouisync-app\ouisync-plugin\ && \
    flutter pub get && \
    flutter pub run ffigen

RUN cd \ouisync-app && \
    flutter pub get

FROM build as release

RUN flutter build windows --release
