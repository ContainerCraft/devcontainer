###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim-all .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim-all
###############################################################################
# Base VSCode Image
FROM ghcr.io/pulumi/devcontainer:slim

#################################################################################
# Image Metadata
LABEL tag="slim-all"

#################################################################################
# Install Programming Language Tooling
# - python
#################################################################################
# Python
ARG APT_PKGS="\
python3 \
python3-venv \
python3-dev \
python3.11 \
python3.11-venv \
python3.11-dev \
python3-pip \
"
RUN echo \
&& bash -c "${apt_update}" \
&& bash -c "${apt_install} ${APT_PKGS}" \
&& bash -c "${apt_clean}" \
&& sudo update-alternatives --install \
    /usr/bin/python python \
    /usr/bin/python3 1 \
&& ${dir_clean} \
&& echo

# Python Pip Packages
ARG PIP_PKGS="\
setuptools \
"
RUN echo \
&& sudo python3 -m pip install ${PIP_PKGS} \
&& ${dir_clean} \
&& echo


# Golang
RUN echo ;set -ex \
&& jq --version \
&& export NAME="go" \
&& export TEST="${NAME} version" \
&& export VERSION="$(${curl} "https://go.dev/dl/?mode=json" | jq --compact-output --raw-output .[1].version)" \
&& export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
&& export PKG="${VERSION}.linux-${ARCH}.tar.gz" \
&& export URL="https://go.dev/dl/${PKG}" \
&& echo "INFO[${NAME}] Installed:" \
&& echo "INFO[${NAME}]   Command:        ${NAME}" \
&& echo "INFO[${NAME}]   Package:        ${PKG}" \
&& echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
&& echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
&& echo "INFO[${NAME}]   Source:         ${URL}" \
&& ${curl} ${URL} | sudo tar -C /usr/local/ -xzvf - \
&& sudo chmod 755 /usr/local/go/bin/* \
&& ${TEST} \
&& echo

# Install nodejs npm yarn
RUN echo \
&& export NODE_MAJOR=20 \
&& ${curl} https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
&& echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
    | sudo tee /etc/apt/sources.list.d/nodesource.list \
&& sudo apt-get update \
&& sudo apt-get install nodejs \
&& sudo apt-get clean \
&& sudo apt-get autoremove -y \
&& sudo apt-get purge -y --auto-remove \
&& ${dir_clean} \
&& node --version \
&& npm --version \
&& sudo npm install --global yarn \
&& yarn --version \
&& true

# Dotnet
ARG APT_PKGS="\
dotnet-sdk-7.0 \
dotnet-runtime-7.0 \
"
RUN echo \
&& bash -c "${apt_install} ${APT_PKGS}" \
&& bash -c "${apt_clean}" \
&& ${dir_clean} \
&& echo
