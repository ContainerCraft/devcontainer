###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim -f docker/slim/Dockerfile ./docker
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim
###############################################################################
# Base Devcontainer Image
#FROM mcr.microsoft.com/devcontainers/base:ubuntu
FROM docker.io/library/ubuntu:24.04
LABEL tag="slim"
ENV DEVCONTAINER="slim"
SHELL ["/bin/bash", "-c", "-ex"]
USER root

# Append rootfs directory tree into container to copy
# additional files into the container's directory tree
ADD slim/rootfs /
ADD slim/rootfs/etc/skel/ /root/
RUN cp -rf /etc/skel/.bashrc /root/.bashrc && rm /root/.vimrc
ADD slim/rootfs/etc/skel/ /home/runner/
ADD slim/rootfs/etc/skel/ /home/ubuntu/

#################################################################################
# Environment Variables

# Disable LC_ALL for Nix compatibility
# currently inheriting from base MS base image
ENV LC_ALL=""
# Disable timezone prompts
ENV TZ=UTC
# Set TERM to linux to avoid prompts
ENV TERM=linux
# Disable package manager prompts
ENV DEBIAN_FRONTEND=noninteractive
# Add go and nix to path
ENV PATH="/home/ubuntu/.krew/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/nix/var/nix/profiles/default/bin"
# Set necessary nix environment variable
ENV NIX_INSTALLER_EXTRA_CONF='filter-syscalls = false'
# Set default bin directory for new packages
ENV BIN="/usr/local/bin"
# Set default binary install command
ENV INSTALL="install -m 755 -o root -g root"
# Set additional environment variables
ENV REGISTRY_AUTH_FILE='/home/ubuntu/.docker/config.json'
ENV XDG_CONFIG_HOME=/home/ubuntu/.config
# Set Starship Container Name
ENV STARSHIP_CONTAINER="Konductor"

# Common Dockerfile Container Build Functions
ENV apt_update="sudo apt-get update"
ENV apt_install="TERM=linux DEBIAN_FRONTEND=noninteractive sudo apt-get install -q --yes --purge --assume-yes --auto-remove --allow-downgrades -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'"
ENV root_apt_update="apt-get update"
ENV root_apt_install="TERM=linux DEBIAN_FRONTEND=noninteractive apt-get install -q --yes --purge --assume-yes --auto-remove --allow-downgrades -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold'"
ENV root_apt_upgrade="TERM=linux DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
ENV apt_clean="sudo apt-get clean && sudo apt-get autoremove -y && sudo apt-get purge -y --auto-remove"
ENV curl="/usr/bin/curl --silent --show-error --tlsv1.2 --location"
ENV curl_github="/usr/bin/curl --silent --show-error --tlsv1.2 --request GET --url"
ENV dir_clean="\
  sudo rm -rf \
  /var/lib/{apt,cache,log} \
  /usr/share/{doc,man,locale} \
  /var/cache/apt \
  /home/*/.cache \
  /root/.cache \
  /var/tmp/* \
  /tmp/* \
  "

#################################################################################
# Base package and user configuration
#################################################################################

# Apt Packages
ARG APT_PKGS="\
  gh \
  git \
  tar \
  pen \
  sudo \
  btop \
  file \
  wget \
  tree \
  curl \
  tmux \
  socat \
  unzip \
  gnupg \
  gnupg2 \
  pipenv \
  psmisc \
  procps \
  passwd \
  libwrap0 \
  xz-utils \
  fontconfig \
  glibc-tools \
  lsb-release \
  netcat-openbsd \
  build-essential \
  ca-certificates \
  libarchive-tools \
  python3-neovim \
  ruby-neovim \
  neovim \
  "

# Apt Packages
RUN echo \
  && export TEST="vim --version" \
  && ${root_apt_update} \
  && bash -c "${root_apt_upgrade}" \
  && bash -c "${root_apt_install} --no-install-recommends -o Dpkg::Options::='--force-confold' ${APT_PKGS}" \
  && update-alternatives --set vim /usr/bin/nvim \
  && apt-get remove -y --purge nano \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# jq
RUN echo \
  && export NAME="jq" \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="jqlang/jq" \
  && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | awk -F '[\"v\",-]' '/tag_name/{print $5}')" \
  && export PKG="${NAME}-linux-${ARCH}" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${NAME}-${VERSION}/${NAME}-linux-${ARCH}" \
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && ${curl} ${URL} --output /tmp/${NAME} \
  && file /tmp/${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# direnv
RUN echo \
  && export NAME="direnv"\
  && export PKG="install.sh"\
  && export URL="https://direnv.net/${PKG}"\
  && export TEST="${NAME} --version"\
  && echo "INFO[${NAME}] Install Package:"\
  && echo "INFO[${NAME}]  Command: ${NAME}"\
  && echo "INFO[${NAME}]  Package: ${PKG}"\
  && echo "INFO[${NAME}]  Source:  ${URL}"\
  && ${curl} ${URL} --output /tmp/${PKG} \
  && chmod +x /tmp/${PKG} \
  && sudo bash -c "/tmp/${PKG}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Starship
RUN echo \
  && export NAME=starship \
  && export TEST="${NAME} --version" \
  && export URL="https://starship.rs/install.sh" \
  && ${curl} ${URL} --output /tmp/${NAME} \
  && chmod +x /tmp/${NAME} \
  && bash -c "/tmp/${NAME} --verbose --yes" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

#################################################################################
# Create Users and Groups
# Create User: runner (for github actions runner support)

RUN echo \
  && mkdir -p /etc/sudoers.d || true \
  && groupadd --force --system sudo || true \
  && groupadd --force --gid 127 --system docker \
  && echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/sudo \
  && echo "%runner ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers.d/sudo \
  && echo "%ubuntu ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers.d/sudo \
  && echo

# Set User & Workdir default to $HOME
USER ubuntu
WORKDIR /home/ubuntu

# Adduser:
# - user:   ubuntu
# - group:  ubuntu
# - uid:    1000
# - gid:    1000
RUN echo \
  && export USER_ID="1000" \
  && export USER_NAME="ubuntu" \
  && export USER_SHELL="bash" \
  && export USER_GROUPS="${USER_NAME},sudo,docker,ubuntu" \
  && export USER_GROUP_NAME="${USER_NAME}" \
  && export USER_GROUP_ID="${USER_ID}" \
  && echo "INFO[${USER_NAME}]  User:" \
  && echo "INFO[${USER_NAME}]    User Name:   ${USER_NAME}" \
  && echo "INFO[${USER_NAME}]    User Group:  ${USER_GROUP_NAME}" \
  && echo "INFO[${USER_NAME}]    Aux Groups:  ${USER_GROUPS}" \
  && echo "INFO[${USER_NAME}]    Group ID:    ${USER_GROUP_ID}" \
  && echo "INFO[${USER_NAME}]    User ID:     ${USER_ID}" \
  && echo "INFO[${USER_NAME}]    SHELL:       $(which ${USER_SHELL})" \
  && echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers \
  && sudo groupadd --force --gid ${USER_ID} ${USER_NAME} \
  && sudo useradd --create-home --uid ${USER_ID} --gid ${USER_GROUP_ID} --shell $(which ${USER_SHELL}) --groups ${USER_GROUPS} ${USER_NAME} || true \
  && sudo usermod --append --groups ${USER_GROUPS} ${USER_NAME} \
  && sudo chsh --shell $(which ${USER_SHELL}) ${USER_NAME} \
  && sudo mkdir -p /home/ubuntu/.krew/bin \
  && sudo chmod 0755 -R /home/ubuntu/.krew/bin \
  && sudo chown ${USER_NAME}:${USER_NAME} -R /home/ubuntu/.krew/bin \
  && sudo su --preserve-environment --shell $(which ${USER_SHELL}) -c groups ${USER_NAME} 2>/dev/null \
  && sudo chmod 0775 /usr/local/lib \
  && sudo rm -rf /usr/local/lib/node_modules \
  && sudo mkdir -p /usr/local/lib/node_modules \
  && echo

RUN sudo chown ubuntu:ubuntu -R /home/ubuntu

# Adduser:
# - user:   runner
# - group:  runner
# - uid:    1001
# - gid:    1001
RUN echo \
  && export USER_ID="1001" \
  && export USER_NAME="runner" \
  && export USER_SHELL="bash" \
  && export USER_GROUPS="sudo,docker,ubuntu,runner" \
  && export USER_GROUP_ID="${USER_ID}" \
  && echo "INFO[${USER_NAME}:${USER_ID}:${USER_GROUPS}] User:" \
  && echo "INFO[${USER_NAME}:${USER_ID}:${USER_GROUPS}]   UID:         ${USER_ID}" \
  && echo "INFO[${USER_NAME}:${USER_ID}:${USER_GROUPS}]   NAME:        ${USER_NAME}" \
  && echo "INFO[${USER_NAME}:${USER_ID}:${USER_GROUPS}]   SHELL:       $(which ${USER_SHELL})" \
  && echo "INFO[${USER_NAME}:${USER_ID}:${USER_GROUPS}]   USER GROUP:  ${USER_GROUP_ID}" \
  && echo "INFO[${USER_NAME}:${USER_ID}:${USER_GROUPS}]   AUX GROUPS:  ${USER_GROUPS}" \
  && sudo groupadd --force --gid ${USER_ID} ${USER_NAME} \
  && sudo echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers \
  && sudo useradd --create-home --uid ${USER_ID} --gid ${USER_GROUP_ID} --shell $(which ${USER_SHELL}) --groups ${USER_GROUPS} ${USER_NAME} \
  && sudo chsh --shell $(which ${USER_SHELL}) ${USER_NAME} \
  && sudo usermod --append --groups ${USER_GROUPS} ${USER_NAME} \
  && sudo usermod --append --groups ${USER_GROUPS} ubuntu \
  && sudo su --preserve-environment --shell $(which ${USER_SHELL}) -c groups ${USER_NAME} \
  && sudo chown runner:runner -R /home/runner \
  && sudo chmod 755 /home/ubuntu/.* \
  && echo

RUN sudo chown runner:runner -R /home/runner

##################################################################################
# Install Creature Comforts

# Nix
RUN echo \
  && export NAME=nix-installer \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="DeterminateSystems/nix-installer" \
  && export VERSION="$(${curl_github} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x86_64"; else if ($1 == "aarch64" || $1 == "arm64") print "aarch64"; else print "unknown" }') \
  && export PKG="${NAME}-${ARCH}-linux" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && sudo ${curl} ${URL} --output /tmp/${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${NAME} install linux --init none --no-confirm --extra-conf "filter-syscalls = false" \
  && bash -c "${TEST}" \
  && sudo chown ubuntu -R /nix \
  && sudo usermod -aG nixbld ubuntu \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# NerdFonts: FiraCode Nerd Font Mono
RUN echo \
  && export NAME=FiraMonoNerdFont \
  && export TEST="fc-list --quiet ${NAME}" \
  && export REPOSITORY="ryanoasis/nerd-fonts" \
  && export VERSION="$(${curl_github} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
  && export PKG="FiraMono.zip" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && export DIR="/usr/share/fonts/truetype/firacode" \
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && ${curl} ${URL} --output /tmp/fonts.zip \
  && sudo mkdir -p $DIR \
  && sudo rm -rf $DIR/* \
  && sudo unzip /tmp/fonts.zip -d /usr/share/fonts/truetype/firacode \
  && sudo fc-cache -f -v \
  && fc-list : family | sort | uniq \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# TMUX Plugins
RUN echo \
  && ~/.tmux/plugins/tpm/bin/install_plugins || true \
  && echo

##################################################################################
# Install runme cli
# - https://github.com/stateful/runme/releases
RUN echo \
  && export NAME="runme" \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="stateful/runme" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x86_64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}_linux_${ARCH}.deb" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${apt_update} \
  && ${curl} ${URL} --output /tmp/${PKG} \
  && DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y --no-install-recommends -o Dpkg::Options::='--force-confold' /tmp/${PKG} \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

  ##################################################################################
# Install Taskfile cli
# - https://github.com/go-task/task/releases
RUN echo \
  && export NAME="task" \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="go-task/task" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}_linux_${ARCH}.deb" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${apt_update} \
  && ${curl} ${URL} --output /tmp/${PKG} \
  && DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y --no-install-recommends -o Dpkg::Options::='--force-confold' /tmp/${PKG} \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

#################################################################################
# Insall Github Actions Local Testing CLI
# - https://nektosact.com
# - https://github.com/nektos/gh-act
RUN echo \
  && export NAME=act \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="nektos/gh-act" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="linux-${ARCH}" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} --output /tmp/${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

################################################################################
# Install Pulumi CLI, ESC, & CTL

# Install Pulumi CLI Utility
RUN echo \
  && export NAME=pulumi \
  && export TEST="pulumi version" \
  && export REPOSITORY="pulumi/pulumi" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}-${VERSION}-linux-${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | tar xzvf - --directory /tmp \
  && sudo chmod 755 /tmp/pulumi/* \
  && sudo chown root:root /tmp/pulumi/* \
  && sudo mv /tmp/pulumi/* /usr/local/bin/ \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Install pulumi esc
RUN echo \
  && export NAME="esc" \
  && export TEST="esc version" \
  && export REPOSITORY="pulumi/esc" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}-${VERSION}-linux-${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | tar xzvf - --directory /tmp \
  && sudo ${INSTALL} /tmp/${NAME}/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Install pulumictl
RUN echo \
  && export NAME="pulumictl" \
  && export TEST="${NAME} version" \
  && export REPOSITORY="pulumi/pulumictl" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}-${VERSION}-linux-${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | tar xzvf - --directory /tmp \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

#################################################################################
# Load startup artifacts
COPY ./bin/connect            /bin/
COPY ./bin/entrypoint         /bin/
COPY ./bin/devcontainer-links /bin/

#################################################################################
# Entrypoint & default command
ENTRYPOINT ["/usr/bin/bash", "-c", "entrypoint"]
HEALTHCHECK --interval=120s --timeout=30s --start-period=5s --retries=3 CMD [ "true" ]

#################################################################################
# Image Metadata
LABEL name="ContainerCraft Konductor Devcontainer"
LABEL io.k8s.display-name="ContainerCraft Konductor Devcontainer"
LABEL org.opencontainers.image.authors="github.com/ContainerCraft"
LABEL org.opencontainers.image.source="https://github.com/containercraft/devcontainer"
LABEL org.opencontainers.image.licenses="APACHE-2.0"
LABEL distribution-scope="public"
