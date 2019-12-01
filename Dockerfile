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
    --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended

# May need to add ATL to build some windows-specific tools. I think lldb needs it.
#    --add Microsoft.VisualStudio.Component.VC.ATL

# Install Python and Git.
RUN powershell.exe -ExecutionPolicy RemoteSigned `
  iex (new-object net.webclient).downloadstring('https://get.scoop.sh');


RUN scoop install 7zip aria2
RUN scoop install curl sudo git openssh coreutils grep sed less python
# Further installs need itcode installed by shellcheck and
# installing shellcheck requires using powershell
RUN powershell scoop install shellcheck msys2

COPY scoop\bucket\llvm-nightly.json C:\TEMP\scoop\llvm-nightly.json
RUN scoop install C:\temp\scoop\llvm-nightly.json

# Tensorflow dependencies
RUN scoop install bazel
RUN scoop install unzip patch
RUN pip3 install six numpy wheel 
RUN pip3 install keras_applications==1.0.6 --no-deps
RUN pip3 install keras_preprocessing==1.0.5 --no-deps

ARG CUDA_VERSION=10.1
COPY scoop\bucket\cuda-${CUDA_VERSION}.json C:\TEMP\scoop\bucket\cuda.json
RUN scoop install C:\temp\scoop\bucket\cuda.json

ARG CUDNN_VERSION=7.6
COPY scoop\bucket\cudnn-${CUDNN_VERSION}-cuda-${CUDA_VERSION}.json C:\TEMP\scoop\bucket\cudnn.json
RUN scoop install C:\temp\scoop\bucket\cudnn.json

# Cleanup scoop cache
RUN scoop cache rm *

# Set path to msys2 binaries. "ENV PATH" does not quite work on windows.
# https://github.com/moby/moby/issues/22017
RUN setx path "%path%;C:/Users/ContainerAdministrator/scoop/apps/msys2/current/usr/bin"

WORKDIR "C:/work"
CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
