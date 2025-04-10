###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim-all -f docker/slim-all/Dockerfile ./docker
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim-all
###############################################################################
# Base Image
FROM ghcr.io/containercraft/devcontainer:slim
LABEL tag="slim-all"
ENV DEVCONTAINER="slim-all"

#################################################################################
# Install Programming Language Tooling
# - python
#################################################################################
# Python
ARG APT_PKGS="\
    direnv \
    python3 \
    python3-dev \
    python3-venv \
    python3-dotenv \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
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
#ARG PIP_PKGS="\
#    setuptools \
#    "
#RUN echo \
#    && sudo python3 -m pip install ${PIP_PKGS} \
#    && ${dir_clean} \
#    && echo

# Install Poetry for Python dependency management
ENV POETRY_HOME="/usr/local"
ENV PATH="/usr/local/bin:${PATH}"

USER root
RUN PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2) \
    && NAME="poetry" \
    && echo "---------------------------------------------------------" \
    && echo "INFO[${NAME}] Installing:" \
    && echo "INFO[${NAME}]   Command:        ${NAME}" \
    && echo "INFO[${NAME}]   Python Version: ${PYTHON_VERSION}" \
    && echo "---------------------------------------------------------" \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && chmod +x /usr/local/bin/poetry \
    && poetry config virtualenvs.in-project true \
    && poetry --version \
    && mkdir -p \
         /home/ubuntu/.config/pypoetry \
         /etc/skel/.config/pypoetry \
    && chown -R ubuntu:ubuntu /home/ubuntu/.config \
    && echo
USER ubuntu 

##################################################################################
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

##################################################################################
# Install nodejs npm yarn
RUN echo \
    && export NODE_MAJOR=23 \
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

# Install claude-code
# Configure npm global packages to install in user home
RUN echo \
    && mkdir -p ~/.npm-global \
    && npm config set prefix ~/.npm-global \
    && echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc \
    && export PATH=~/.npm-global/bin:$PATH \
    && npm install -g @anthropic-ai/claude-code \
    && echo "Claude Code installed at: $(which claude-code)" \
    && true

##################################################################################
# Dotnet
ARG APT_PKGS="\
    dotnet-sdk-8.0 \
    dotnet-runtime-8.0 \
    "
RUN echo \
    && bash -c "${apt_install} ${APT_PKGS}" \
    && bash -c "${apt_clean}" \
    && ${dir_clean} \
    && echo
