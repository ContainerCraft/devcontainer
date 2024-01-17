# docker build --tag ghcr.io/containercraft/konductor:latest .
# docker run --rm --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 -d --name konductor --hostname konductor ghcr.io/containercraft/konductor:latest
# docker run -d --rm --cap-add=CAP_AUDIT_WRITE --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 --name konductor --hostname konductor --security-opt label=disable --pull=always ghcr.io/containercraft/konductor
# docker run -it --rm --entrypoint fish --mount type=bind,source=/run/docker.sock,target=/run/docker.sock --privileged --user vscode ghcr.io/containercraft/konductor:latest
###############################################################################
# Base VSCode Image
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Append rootfs directory tree into container to copy
# additional files into the container's directory tree
ADD rootfs /
ADD rootfs/etc/skel/ /home/vscode/
ADD rootfs/etc/skel/ /root/

# Disable timezone prompts
ENV TZ=UTC
# Disable package manager prompts
ENV DEBIAN_FRONTEND=noninteractive
# Add go and nix to path
ENV PATH="/home/vscode/.krew/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/nix/var/nix/profiles/default/bin"
# Set necessary nix environment variable
ENV NIX_INSTALLER_EXTRA_CONF='filter-syscalls = false'

#################################################################################
# Base package and user configuration
#################################################################################

# Apt Packages
ARG APT_PKGS="\
gh \
bc \
mc \
vim \
git \
tar \
mosh \
file \
wget \
tree \
pigz \
fish \
curl \
tmux \
tmate \
gnupg \
pipenv \
netcat \
psmisc \
procps \
passwd \
ripgrep \
tcpdump \
python3 \
pciutils \
xz-utils \
fontconfig \
glibc-tools \
python3-pip \
build-essential \
ca-certificates \
libarchive-tools \
neofetch \
"

# Install Apt Packages
#   && gh extension install nektos/gh-act \
RUN set -ex \
    && sudo apt-get update \
    && TERM=linux DEBIAN_FRONTEND=noninteractive \
        sudo apt-get install \
                --yes -q \
                --force-yes \
                -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" \
            ${APT_PKGS} \
    && sudo apt-get clean \
    && sudo apt-get autoremove -y \
    && sudo apt-get purge -y --auto-remove \
    && sudo rm -rf \
        /var/lib/{apt,dpkg,cache,log} \
        /usr/share/{doc,man,locale} \
        /var/cache/apt \
        /root/.cache \
        /var/tmp/* \
        /tmp/* \
    && neofetch \
    && echo

# Install docker packages for codespaces docker-in-docker
ARG APT_PKGS="\
docker-buildx-plugin \
docker-ce-cli \
libffi-dev \
iptables \
"
RUN set -ex \
    && sudo apt-get update \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install ${APT_PKGS} \
    && sudo apt-get clean \
    && sudo apt-get autoremove -y \
    && sudo apt-get purge -y --auto-remove \
    && sudo update-alternatives --set iptables /usr/sbin/iptables-legacy \
    && sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy \
    && sudo rm -rf \
        /var/lib/{apt,dpkg,cache,log} \
        /usr/share/{doc,man,locale} \
        /var/cache/apt \
        /root/.cache \
        /var/tmp/* \
        /tmp/* \
    && echo

# Create Primary User: vscode
RUN set -ex \
    && sudo groupadd --system sudo || echo \
    && sudo mkdir -p /etc/sudoers.d || echo \
    && sudo echo "vscode ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && sudo echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo \
    && sudo groupadd -g 127 docker \
    && sudo groupadd -g 1000 vscode \
    && sudo groupadd -g 1001 runner \
    && sudo useradd -m -u 1000 -g 1000 -s /usr/bin/fish --groups users,sudo,docker vscode \
    && sudo chsh --shell /usr/bin/fish vscode || echo \
    && sudo chmod 0775 /usr/local/lib \
    && sudo chgrp users /usr/local/lib \
    && sudo mkdir /usr/local/lib/node_modules \
    && sudo chown -R vscode:vscode \
        /usr/local/lib/node_modules \
        /home/vscode \
        /var/local \
    && echo

# Create User: runner (for github actions runner support)
RUN set -ex \
    && sudo echo "runner ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && sudo useradd -m -u 1001 -g 1001 -s /usr/bin/bash --groups users,sudo,docker runner \
    && sudo chsh --shell /usr/bin/bash runner || echo \
    && sudo chmod 0775 /usr/local/lib \
    && sudo chgrp users /usr/local/lib \
    && sudo mkdir /usr/local/lib/node_modules \
    && sudo chown -R runner:runner \
        /usr/local/lib/node_modules \
        /home/runner \
        /var/local \
    && echo

# Post user creation configuration
RUN set -ex \
    && sudo usermod -aG adm vscode \
    && sudo usermod -aG docker vscode \
    && sudo usermod -aG adm runner \
    && sudo usermod -aG docker runner \
    && sudo chsh --shell /usr/bin/fish vscode \
    && sudo chsh --shell /usr/bin/bash runner \
    && echo

# Install jq
RUN set -ex \
    && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
    && export VERSIONJq="$(curl -s https://api.github.com/repos/jqlang/jq/releases/latest | awk -F '["jq-]' '/tag_name/{print $7}')" \
    && export URLJq="https://github.com/jqlang/jq/releases/download/jq-${VERSIONJq}/jq-linux-$ARCH" \
    && sudo curl -L "${URLJq}" -o /bin/jq \
    && sudo chmod +x /bin/jq \
    && /bin/jq --version \
    && echo

# Install yq
RUN set -ex \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSIONYq=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && export URLYq="https://github.com/mikefarah/yq/releases/download/v${VERSIONYq}/yq_linux_$ARCH" \
    && sudo curl -L ${URLYq} -o /bin/yq \
    && sudo chmod +x /bin/yq \
    && /bin/yq --version \
    && echo

# Set User & Workdir default to $HOME
USER vscode
WORKDIR /home/vscode

# Install Starship prompt theme
RUN set -ex \
    && curl --output /tmp/install.sh -L https://starship.rs/install.sh \
    && chmod +x /tmp/install.sh \
    && bash -c "/tmp/install.sh --verbose --yes" \
    && starship --version \
    && rm -rf /tmp/install.sh /tmp/* \
    && echo

# Install Vim & TMUX Plugins
RUN set -ex \
    && /bin/bash -c "vim -T dumb -n -i NONE -es -S <(echo -e 'silent! PluginInstall')" \
    && ~/.tmux/plugins/tpm/bin/install_plugins || echo \
    && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
    && vim -E -u NONE -S ~/.vimrc +PluginInstall +qall \
    && echo

# Install OMF
RUN set -ex \
    && curl --output install -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install \
    && fish -c '. install --noninteractive' \
    && rm install \
    && echo

##################################################################################
# Install NerdFonts FiraCode Nerd Font Mono
RUN set -ex \
    && export NAME=FiraMonoNerdFont \
    && export REPOSITORY="ryanoasis/nerd-fonts" \
    && export TEST="fc-list --quiet $NAME" \
    && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
    && export VERSION=$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '["]' '/tag_name/{print $4}') \
    && export PKG="FiraMono.zip" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && export DIR="/usr/share/fonts/truetype/firacode" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --output /tmp/fonts.zip --location $URL \
    && sudo rm -rf $DIR/* \
    && sudo mkdir -p $DIR \
    && sudo unzip /tmp/fonts.zip -d /usr/share/fonts/truetype/firacode \
    && sudo rm -rf /tmp/* \
    && sudo fc-cache -f -v \
    && fc-list : family | sort | uniq \
    && $TEST \
    && echo

#################################################################################
# Install Basic Dependencies
#################################################################################

# Install golang
RUN set -ex \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSIONGo="$(curl -s https://go.dev/dl/?mode=json | awk -F'[":go]' '/  "version"/{print $8}' | head -n1)" \
    && curl -L https://go.dev/dl/go${VERSIONGo}.linux-$ARCH.tar.gz | sudo tar -C /usr/local/ -xzvf - \
    && which go \
    && go version \
    && echo

# Install python
ARG APT_PKGS="\
python3 \
python3-pip \
python3-venv \
"
ARG PIP_PKGS="\
setuptools \
"
RUN set -ex \
    && sudo apt-get update \
    && sudo apt-get install ${APT_PKGS} \
    && sudo update-alternatives --install \
        /usr/bin/python python \
        /usr/bin/python3 1 \
    && sudo python3 -m pip install ${PIP_PKGS} \
    && sudo apt-get clean \
    && sudo apt-get autoremove -y \
    && sudo apt-get purge -y --auto-remove \
    && sudo rm -rf \
        /var/lib/{apt,dpkg,cache,log} \
        /usr/share/{doc,man,locale} \
        /var/cache/apt \
        /root/.cache \
        /var/tmp/* \
        /tmp/* \
    && echo

# Install dotnet
ARG APT_PKGS="\
dotnet-sdk-7.0 \
dotnet-runtime-7.0 \
"
RUN set -ex \
    && sudo apt-get update \
    && sudo apt-get install ${APT_PKGS} \
    && sudo apt-get clean \
    && sudo apt-get autoremove -y \
    && sudo apt-get purge -y --auto-remove \
    && sudo rm -rf \
        /var/lib/{apt,dpkg,cache,log} \
        /usr/share/{doc,man,locale} \
        /var/cache/apt \
        /root/.cache \
        /var/tmp/* \
        /tmp/* \
    && echo

# Install nodejs npm yarn
RUN set -ex \
    && export NODE_MAJOR=20 \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
        | sudo tee /etc/apt/sources.list.d/nodesource.list \
    && sudo apt-get update \
    && sudo apt-get install nodejs \
    && sudo apt-get clean \
    && sudo apt-get autoremove -y \
    && sudo apt-get purge -y --auto-remove \
    && sudo rm -rf \
        /var/lib/{apt,dpkg,cache,log} \
        /usr/share/{doc,man,locale} \
        /var/cache/apt \
        /root/.cache \
        /var/tmp/* \
        /tmp/* \
    && node --version \
    && npm --version \
    && sudo npm install --global yarn \
    && yarn --version \
    && echo

#################################################################################
# Load startup artifacts
COPY ./bin/code.entrypoint /bin/
COPY ./bin/connect         /bin/
COPY ./bin/entrypoint      /bin/

#################################################################################
# Entrypoint & default command
ENTRYPOINT fish
#CMD ["/usr/bin/env", "connect"]

# Ports
# - mosh
EXPOSE 6000
# - TTYd
EXPOSE 7681

#################################################################################
# Finalize Image
ENV \
  BUILDAH_ISOLATION=chroot \
  XDG_CONFIG_HOME=/home/vscode/.config \
  REGISTRY_AUTH_FILE='/home/vscode/.docker/config.json'

LABEL org.opencontainers.image.authors="github.com/containercraft"
LABEL org.opencontainers.image.licenses="GPLv3"
LABEL name="Konductor"
LABEL distribution-scope="public"
LABEL io.k8s.display-name="Konductor"
LABEL summary="ContainerCraft Konductor DevOps Container"
LABEL io.openshift.tags="containercraft,konductor"
LABEL description="ContainerCraft Konductor DevOps Container"
LABEL maintainer="github.com/containercraft"
LABEL io.k8s.description="ContainerCraft Konductor DevOps Container"

#################################################################################
# Install Pulumi CLI, ESC, & CTL
# Install Pulumi CLI Utilities and Pulumi go deps
ARG GO_PKGS="\
golang.org/x/tools/gopls@latest \
github.com/josharian/impl@latest \
github.com/fatih/gomodifytags@latest \
github.com/cweill/gotests/gotests@latest \
github.com/go-delve/delve/cmd/dlv@latest \
honnef.co/go/tools/cmd/staticcheck@latest \
github.com/haya14busa/goplay/cmd/goplay@latest \
"
RUN set -ex \
    && export NAME=pulumi \
    && export REPOSITORY="pulumi/pulumi" \
    && export TEST="pulumi version" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSION="$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
    && export PKG="pulumi-v$VERSION-linux-$ARCH.tar.gz" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL | tar xzvf - --directory /tmp \
    && chmod 755 /tmp/pulumi/* \
    && chown root:root /tmp/pulumi/* \
    && sudo mv /tmp/pulumi/* /usr/local/bin/ \
    && $TEST \
    && echo "+-------------------------------------------------------+"\
    && echo "|       Installing Basic Pulumi Golang Deps             |"\
    && echo "+-------------------------------------------------------+"\
    && for pkg in ${GO_PKGS}; do go install ${pkg}; echo "Installed: ${pkg}"; done \
    && sudo rm -rf /tmp/* \
    && echo

# Install pulumi esc
RUN set -ex \
    && export NAME="esc" \
    && export REPOSITORY="pulumi/esc" \
    && export TEST="esc version" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSION="$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
    && export PKG="esc-v$VERSION-linux-$ARCH.tar.gz" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && curl --location $URL --output /tmp/$NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && curl -L $URL | tar xzvf - --directory /tmp \
    && chmod +x /tmp/esc/esc \
    && sudo mv /tmp/esc/esc /usr/local/bin/esc \
    && which esc \
    && $TEST \
    && rm -rf /tmp/* \
    && echo

# Install pulumictl
RUN set -ex \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export urlPulumiRelease="https://api.github.com/repos/pulumi/pulumictl/releases/latest" \
    && export urlPulumiVersion=$(curl -s ${urlPulumiRelease} | awk -F '["v,]' '/tag_name/{print $5}') \
    && export urlPulumiBase="https://github.com/pulumi/pulumictl/releases/download" \
    && export urlPulumiBin="pulumictl-v${urlPulumiVersion}-linux-$ARCH.tar.gz" \
    && export urlPulumi="${urlPulumiBase}/v${urlPulumiVersion}/${urlPulumiBin}" \
    && curl -L ${urlPulumi} | tar xzvf - --directory /tmp \
    && chmod +x /tmp/pulumictl \
    && sudo mv /tmp/pulumictl /usr/local/bin/ \
    && which pulumictl \
    && pulumictl version \
    && rm -rf /tmp/* \
    && echo

#################################################################################
# DevOps Dependencies
#################################################################################

# Install nix
RUN set -ex \
    && export urlNix="https://install.determinate.systems/nix" \
    && curl --proto '=https' --tlsv1.2 -sSf -L ${urlNix} --output /tmp/install.sh \
    && chmod +x /tmp/install.sh \
    && sudo /tmp/install.sh install linux --init none --extra-conf "filter-syscalls = false" --no-confirm \
    && sh -c "nix --version" \
    && sudo rm -rf /tmp/install.sh /tmp/* \
    && echo

# Install direnv
RUN set -ex \
    && curl --output /tmp/install.sh --proto '=https' --tlsv1.2 -Sf -L "https://direnv.net/install.sh" \
    && chmod +x /tmp/install.sh \
    && sudo bash -c "/tmp/install.sh" \
    && direnv --version \
    && sudo rm -rf /tmp/* \
    && echo

# Install Kubectl
RUN set -ex \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSIONKubectl="$(curl --silent -L https://storage.googleapis.com/kubernetes-release/release/stable.txt | sed 's/v//g')" \
    && export URLKubectl="https://storage.googleapis.com/kubernetes-release/release/v${VERSIONKubectl}/bin/linux/$ARCH/kubectl" \
    && sudo curl -L ${URLKubectl} --output /bin/kubectl \
    && sudo chmod +x /bin/kubectl \
    && kubectl version --client \
    && echo

##################################################################################
#### Common Binary Install Arguments
##################################################################################
ARG BIN="/usr/local/bin"

##################################################################################
# Install ttyd
# - https://tsl0922.github.io/ttyd
# - https://github.com/tsl0922/ttyd
RUN set -ex \
    && export NAME=ttyd \
    && export REPOSITORY="tsl0922/ttyd" \
    && export TEST="$NAME --version" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x86_64"; else if ($1 == "aarch64" || $1 == "arm64") print "aarch64"; else print "unknown" }') \
    && export PKG="ttyd.$ARCH" \
    && export VERSION=$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '[":,]' '/tag_name/{print $5}') \
    && export URL="https://github.com/$REPOSITORY/releases/download/$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL --output /tmp/$NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Install k9s CLI
# - https://k9scli.io
# - https://github.com/derailed/k9s
RUN set -ex \
    && export NAME=k9s \
    && export REPOSITORY="derailed/k9s" \
    && export TEST="$NAME version" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export PKG="k9s_Linux_$ARCH.tar.gz" \
    && export VERSION=$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '[":,]' '/tag_name/{print $5}') \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL | sudo tar xzvf - --directory /tmp $NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Insall Cilium CLI
# - https://cilium.io
# - https://github.com/cilium/cilium-cli
RUN set -ex \
    && export NAME=cilium \
    && export REPOSITORY="cilium/cilium-cli" \
    && export TEST="$NAME version --client" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSION="$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
    && export PKG="cilium-linux-$ARCH.tar.gz" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION"/$PKG \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL | tar xzvf - --directory /tmp $NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Insall istioctl
# - https://istio.io
# - https://github.com/istio/istio
RUN set -ex \
    && export NAME=istioctl \
    && export REPOSITORY="istio/istio" \
    && export TEST="$NAME version --short 2>&1 | grep -v unable" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSION="$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '[\"v,]' '/tag_name/{print $4}')" \
    && export PKG="istio-$VERSION-linux-$ARCH.tar.gz" \
    && export URL="https://github.com/$REPOSITORY/releases/download/$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL | tar xzvf - --directory /tmp $NAME \
    && curl --location $URL | tar xzvf - --directory /tmp istio-$VERSION/bin/$NAME \
    && sudo install -m 755 -o root -g root /tmp/istio-$VERSION/bin/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Insall Github Actions Local Testing CLI
# - https://nektosact.com
# - https://github.com/nektos/gh-act
RUN set -ex \
    && export NAME=act \
    && export REPOSITORY="nektos/gh-act" \
    && export TEST="$NAME --version" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export PKG="linux-$ARCH" \
    && export VERSION="$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL --output /tmp/$NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Insall helm cli
# - https://helm.sh
# - https://github.com/helm/helm
RUN set -ex \
    && export NAME=helm \
    && export REPOSITORY="helm/helm" \
    && export TEST="$NAME version" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSION="$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
    && export PKG="helm-v$VERSION-linux-$ARCH.tar.gz" \
    && export URL="https://get.helm.sh/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL | tar xzvf - --directory /tmp linux-$ARCH/$NAME \
    && sudo install -m 755 -o root -g root /tmp/linux-$ARCH/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Install clusterctl
RUN set -ex \
    && export NAME=clusterctl \
    && export REPOSITORY="kubernetes-sigs/cluster-api" \
    && export TEST="$NAME version" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSION=$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && export PKG="$NAME-linux-$ARCH" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL --output /tmp/$NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Install talosctl
RUN set -ex \
    && export NAME=talosctl \
    && export REPOSITORY="siderolabs/talos" \
    && export TEST="$NAME version --client" \
    && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
    && export VERSION="$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')" \
    && export PKG="$NAME-linux-$ARCH" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL --output /tmp/$NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Install virtctl
RUN set -ex \
    && export NAME=virtctl \
    && export REPOSITORY="kubevirt/kubevirt" \
    && export TEST="$NAME version --client" \
    && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
    && export PKG="virtctl-v$VERSION-linux-$ARCH" \
    && export VERSION="$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL --output /tmp/$NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Install Kind Kubernetes-in-Docker
RUN set -ex \
    && export NAME=virtctl \
    && export REPOSITORY="kubevirt/kubevirt" \
    && export TEST="$NAME version --client" \
    && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
    && export VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && export PKG="$NAME-linux-$ARCH" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command:        $NAME" \
    && echo "INFO[$NAME]   Package:        $ARCH" \
    && echo "INFO[$NAME]   Latest Release: $VERSION" \
    && echo "INFO[$NAME]   Architecture:   $ARCH" \
    && echo "INFO[$NAME]   Source:         $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL --output /tmp/$NAME \
    && sudo install -m 755 -o root -g root /tmp/$NAME $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && echo

##################################################################################
# Install Krew
ARG KREW_PKG="\
view-utilization \
view-secret \
view-cert \
rook-ceph \
open-svc \
whoami \
konfig \
ktop \
neat \
tail \
ctx \
ns \
"
RUN set -ex \
    && export NAME=krew \
    && export REPOSITORY="kubernetes-sigs/krew" \
    && export TEST="kubectl $NAME version" \
    && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export VERSION=$(curl -s https://api.github.com/repos/$REPOSITORY/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && export PKG="krew-linux_$ARCH.tar.gz" \
    && export URL="https://github.com/$REPOSITORY/releases/download/v$VERSION/$PKG" \
    && echo "---------------------------------------------------------"\
    && echo "INFO[$NAME] Installed:" \
    && echo "INFO[$NAME]   Command: (kubectl) $NAME" \
    && echo "INFO[$NAME]   Package:           $ARCH" \
    && echo "INFO[$NAME]   Latest Release:    $VERSION" \
    && echo "INFO[$NAME]   Architecture:      $ARCH" \
    && echo "INFO[$NAME]   Source:            $URL" \
    && echo "---------------------------------------------------------"\
    && curl --location $URL | tar xzvf - --directory /tmp ./$NAME-linux_$ARCH \
    && sudo install -m 755 -o root -g root /tmp/$NAME-linux_$ARCH $BIN/$NAME \
    && sudo rm -rf /tmp/* \
    && $TEST \
    && sudo mv /bin/krew-linux_$ARCH /bin/kubectl-krew \
    && sudo chmod +x /bin/kubectl-krew \
    && /bin/kubectl krew version \
    && for pkg in ${CODE_PKGS}; do kubectl krew install ${pkg}; echo "Installed: ${pkg}"; done \
    && echo
