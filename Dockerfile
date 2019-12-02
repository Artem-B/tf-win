# escape=`

# Use a specific tagged image. Tags can be changed, though that is unlikely for most images.
# You could also use the immutable tag @sha256:324e9ab7262331ebb16a4100d0fb1cfb804395a766e3bb1806c62989d1fc1326
ARG FROM_IMAGE=mcr.microsoft.com/windows/servercore:1809
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

ARG CUDA_VERSION=10.1
ARG CUDNN_VERSION=7.6
COPY scoop\bucket\llvm-nightly.json C:\TEMP\scoop\llvm-nightly.json
COPY scoop\bucket\cuda-${CUDA_VERSION}.json C:\TEMP\scoop\bucket\cuda.json
COPY scoop\bucket\cudnn-${CUDNN_VERSION}-cuda-${CUDA_VERSION}.json C:\TEMP\scoop\bucket\cudnn.json

RUN powershell scoop install -k 7zip aria2 shellcheck; `
    scoop install -k curl sudo git openssh coreutils grep sed less python msys2 ;`
    scoop install C:\temp\scoop\llvm-nightly.json; `
    scoop install -k bazel unzip patch ; `
    pip3 install six numpy wheel ; `
    pip3 install keras_applications==1.0.6 --no-deps ;`
    pip3 install keras_preprocessing==1.0.5 --no-deps ; `
    scoop install -k C:\temp\scoop\bucket\cuda.json C:\temp\scoop\bucket\cudnn.json ; `
    scoop cache rm *

RUN echo exit | msys2
ENV MSYS2_PATH_TYPE inherit

WORKDIR "C:/work"
CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
