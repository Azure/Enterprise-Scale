FROM mcr.microsoft.com/powershell:latest

LABEL version="0.2"
LABEL repository="https://github.com/Azure/Enterprise-Scale"
LABEL maintainer="Microsoft"

ARG github=0.10.1
ARG azure=4.2.0

RUN [ "/bin/bash", "-c", "apt-get update &> /dev/null && apt-get install -y git wget &> /dev/null" ]
RUN [ "/bin/bash", "-c", "wget https://github.com/cli/cli/releases/download/v${github}/gh_${github}_linux_amd64.deb -O /tmp/gh_${github}_linux_amd64.deb  &> /dev/null" ]
RUN [ "/bin/bash", "-c", "dpkg -i /tmp/gh_${github}_linux_amd64.deb &> /dev/null" ]
RUN [ "/usr/bin/pwsh", "-Command", "Install-Module -Name Az -RequiredVersion ${azure} -Scope AllUsers -Force" ]