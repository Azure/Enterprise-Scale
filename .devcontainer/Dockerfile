FROM mcr.microsoft.com/powershell:latest

LABEL version="0.2"
LABEL repository="https://github.com/Azure/Enterprise-Scale"
LABEL maintainer="Microsoft"

ARG github=0.10.1
ARG azure_accounts=1.8.1
ARG azure_resources=2.0.1

RUN [ "/bin/bash", "-c", "apt-get update &> /dev/null && apt-get install -y git wget &> /dev/null" ]
RUN [ "/bin/bash", "-c", "wget https://github.com/cli/cli/releases/download/v${github}/gh_${github}_linux_amd64.deb -O /tmp/gh_${github}_linux_amd64.deb  &> /dev/null" ]
RUN [ "/bin/bash", "-c", "dpkg -i /tmp/gh_${github}_linux_amd64.deb &> /dev/null" ]
RUN [ "/usr/bin/pwsh", "-Command", "Install-Module -Name Az.Accounts -RequiredVersion ${azure_accounts} -Scope AllUsers -Force" ]
RUN [ "/usr/bin/pwsh", "-Command", "Install-Module -Name Az.Resources -RequiredVersion ${azure_resources} -Scope AllUsers -Force" ]