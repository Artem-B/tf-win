# escape=`

# Use a specific tagged image. Tags can be changed, though that is unlikely for most images.
# You could also use the immutable tag @sha256:324e9ab7262331ebb16a4100d0fb1cfb804395a766e3bb1806c62989d1fc1326
ARG FROM_IMAGE=mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019
FROM ${FROM_IMAGE}

SHELL ["cmd", "/S", "/C"]

# Copy our Install script.
COPY Install.cmd C:\TEMP\

# Download collect.exe in case of an install failure.
ADD https://aka.ms/vscollect.exe C:\TEMP\collect.exe

# Use the latest release channel. For more control, specify the location of an internal layout.
ARG CHANNEL_URL=https://aka.ms/vs/16/release/channel
ADD ${CHANNEL_URL} C:\TEMP\VisualStudio.chman

# Download and install Build Tools excluding workloads and components with known issues.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe
RUN C:\TEMP\Install.cmd C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --channelUri C:\TEMP\VisualStudio.chman `
    --installChannelUri C:\TEMP\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended `
    --add Microsoft.VisualStudio.Component.VC.ATL

# Install Python and Git.
RUN powershell.exe -ExecutionPolicy RemoteSigned `
  iex (new-object net.webclient).downloadstring('https://get.scoop.sh'); `
  scoop install python git

# ENTRYPOINT does not work due to an issue in docker: 
# https://github.com/MicrosoftDocs/visualstudio-docs/issues/3713
# https://github.com/docker/for-win/issues/4386
# https://github.com/MicrosoftDocs/visualstudio-docs/issues/4317

## From https://github.com/MicrosoftDocs/visualstudio-docs/issues/3713#issuecomment-543327030
#ADD VsDevCmdPowerShell.bat C:\BuildTools\
#ENTRYPOINT  C:\BuildTools\VsDevCmdPowerShell.bat

# Start developer command prompt with any other commands specified.
#ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat &&
# Default to PowerShell if no other command specified.
#CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

#COPY C:\BuildTools\Common7\Tools\VsDevCmd.bat C:\BuildTools\

#RUN echo Environment before VsCmdRun.bat & `
#    set & `
#    C:\BuildTools\Common7\Tools\VsDevCmd.bat -arch=x64 -host_arch=x64 &  `
#    echo Environment after VsCmdRun.bat & `
#    set

WORKDIR "/work"
CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

ENV CommandPromptType="Native"
ENV DevEnvDir="C:\BuildTools\Common7\IDE\"
ENV ExtensionSdkDir="C:\Program Files (x86)\Microsoft SDKs\Windows Kits\10\ExtensionSDKs"
ENV Framework40Version="v4.0"
ENV FrameworkDir="C:\Windows\Microsoft.NET\Framework64\"
ENV FrameworkDir64="C:\Windows\Microsoft.NET\Framework64\"
ENV FrameworkVersion="v4.0.30319"
ENV FrameworkVersion64="v4.0.30319"
ENV INCLUDE="C:\BuildTools\VC\Tools\MSVC\14.23.28105\include;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\include\um;C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\ucrt;C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\shared;C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um;C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\winrt;C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\cppwinrt"
ENV LIB="C:\BuildTools\VC\Tools\MSVC\14.23.28105\lib\x64;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\lib\um\x64;C:\Program Files (x86)\Windows Kits\10\lib\10.0.18362.0\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\lib\10.0.18362.0\um\x64;"
ENV LIBPATH="C:\BuildTools\VC\Tools\MSVC\14.23.28105\lib\x64;C:\BuildTools\VC\Tools\MSVC\14.23.28105\lib\x86\store\references;C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.18362.0;C:\Program Files (x86)\Windows Kits\10\References\10.0.18362.0;C:\Windows\Microsoft.NET\Framework64\v4.0.30319;"
ENV NETFXSDKDir="C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\"
ENV Path="C:\BuildTools\VC\Tools\MSVC\14.23.28105\bin\HostX64\x64;C:\BuildTools\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\BuildTools\MSBuild\Current\bin\Roslyn;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\x64\;C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64;C:\Program Files (x86)\Windows Kits\10\bin\x64;C:\BuildTools\\MSBuild\Current\Bin;C:\Windows\Microsoft.NET\Framework64\v4.0.30319;C:\BuildTools\Common7\IDE\;C:\BuildTools\Common7\Tools\;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Users\ContainerAdministrator\AppData\Local\Microsoft\WindowsApps;C:\Program Files\NuGet;C:\Program Files (x86)\Microsoft Visual Studio\2019\TestAgent\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools;C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool;C:\Users\ContainerAdministrator\scoop\apps\python\current;C:\Users\ContainerAdministrator\scoop\apps\python\current\Scripts;C:\Users\ContainerAdministrator\scoop\shims;C:\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja"
ENV UCRTVersion="10.0.18362.0"
ENV UniversalCRTSdkDir="C:\Program Files (x86)\Windows Kits\10\"
ENV VCIDEInstallDir="C:\BuildTools\Common7\IDE\VC\"
ENV VCINSTALLDIR="C:\BuildTools\VC\"
ENV VCToolsInstallDir="C:\BuildTools\VC\Tools\MSVC\14.23.28105\"
ENV VCToolsRedistDir="C:\BuildTools\VC\Redist\MSVC\14.23.27820\"
ENV VCToolsVersion="14.23.28105"
ENV VisualStudioVersion="16.0"
ENV VS160COMNTOOLS="C:\BuildTools\Common7\Tools\"
ENV VSCMD_ARG_app_plat="Desktop"
ENV VSCMD_ARG_HOST_ARCH="x64"
ENV VSCMD_ARG_TGT_ARCH="x64"
ENV VSCMD_VER="16.3.10"
ENV VSINSTALLDIR="C:\BuildTools\"
ENV WindowsLibPath="C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.18362.0;C:\Program Files (x86)\Windows Kits\10\References\10.0.18362.0"
ENV WindowsSdkBinPath="C:\Program Files (x86)\Windows Kits\10\bin\"
ENV WindowsSdkDir="C:\Program Files (x86)\Windows Kits\10\"
ENV WindowsSDKLibVersion="10.0.18362.0\"
ENV WindowsSdkVerBinPath="C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\"
ENV WindowsSDKVersion="10.0.18362.0\"
ENV WindowsSDK_ExecutablePath_x64="C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\x64\"
ENV WindowsSDK_ExecutablePath_x86="C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\"
ENV __DOTNET_ADD_64BIT="1"
ENV __DOTNET_PREFERRED_BITNESS="64"
ENV __VSCMD_PREINIT_PATH="C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Users\ContainerAdministrator\AppData\Local\Microsoft\WindowsApps;C:\Program Files\NuGet;C:\Program Files (x86)\Microsoft Visual Studio\2019\TestAgent\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools;C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool;C:\Users\ContainerAdministrator\scoop\apps\python\current;C:\Users\ContainerAdministrator\scoop\apps\python\current\Scripts;C:\Users\ContainerAdministrator\scoop\shims"