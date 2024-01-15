# docker build --tag ghcr.io/containercraft/konductor:latest .
# docker run --rm --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 -d --name konductor --hostname konductor ghcr.io/containercraft/konductor:latest
# docker run -d --rm --cap-add=CAP_AUDIT_WRITE --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 --name konductor --hostname konductor --security-opt label=disable --pull=always ghcr.io/containercraft/konductor
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
    && true

# Install docker packages for codespaces docker-in-docker
ARG APT_PKGS="\
docker-buildx-plugin \
docker-ce-cli \
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
    && sudo rm -rf \
        /var/lib/{apt,dpkg,cache,log} \
        /usr/share/{doc,man,locale} \
        /var/cache/apt \
        /root/.cache \
        /var/tmp/* \
        /tmp/* \
    && true

# Create User: vscode
RUN set -ex \
    && sudo groupadd --system sudo || true \
    && sudo mkdir -p /etc/sudoers.d || true \
    && sudo echo "vscode ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && sudo echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo \
    && sudo groupadd -g 1000 vscode || true \
    && sudo groupadd -g 120 docker \
    && sudo useradd -m -u 1000 -g 1000 -s /usr/bin/fish --groups users,sudo,docker vscode \
    && sudo usermod -aG docker vscode \
    && sudo chsh --shell /usr/bin/fish vscode || true \
    && sudo chmod 0775 /usr/local/lib \
    && sudo chgrp users /usr/local/lib \
    && sudo mkdir /usr/local/lib/node_modules \
    && sudo chown -R vscode:vscode \
         /usr/local/lib/node_modules \
         /home/vscode \
         /var/local \
    && true

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
    && true 

# Install Vim & TMUX Plugins
RUN set -ex \
    && /bin/bash -c "vim -T dumb -n -i NONE -es -S <(echo -e 'silent! PluginInstall')" \
    && ~/.tmux/plugins/tpm/bin/install_plugins || true \
    && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim \
    && vim -E -u NONE -S ~/.vimrc +PluginInstall +qall \
    && true

# Install OMF
RUN set -ex \
    && curl --output install -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install \
    && fish -c '. install --noninteractive' \
    && rm install \
    && true

# Install NerdFonts FiraCode Nerd Font Mono
RUN set -ex \
    && sudo rm -rf /usr/share/fonts/truetype/firacode/* \
    && sudo mkdir -p /usr/share/fonts/truetype/firacode \
    && export varVerFonts="$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | awk -F '["]' '/tag_name/{print $4}')" \
    && export varUrlFonts="https://github.com/ryanoasis/nerd-fonts/releases/download/${varVerFonts}/FiraMono.zip" \
    && curl --output /tmp/fonts.zip -L ${varUrlFonts} \
    && sudo unzip /tmp/fonts.zip -d /usr/share/fonts/truetype/firacode \
    && rm -rf /tmp/fonts.zip \
    && sudo fc-cache -f -v \
    && fc-list : family | sort | uniq \
    && true

#################################################################################
# Install Basic Dependencies
#################################################################################

# Install golang
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export varVerGo="$(curl -s https://go.dev/dl/?mode=json | awk -F'[":go]' '/  "version"/{print $8}' | head -n1)" \
    && curl -L https://go.dev/dl/go${varVerGo}.linux-${arch}.tar.gz | sudo tar -C /usr/local/ -xzvf - \
    && which go \
    && go version \
    && true

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
    && true

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
    && true

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
    && true

# Install nix
RUN set -ex \
    && export urlNix="https://install.determinate.systems/nix" \
    && curl --proto '=https' --tlsv1.2 -sSf -L ${urlNix} --output /tmp/install.sh \
    && chmod +x /tmp/install.sh \
    && sudo /tmp/install.sh install linux --init none --extra-conf "filter-syscalls = false" --no-confirm \
    && sh -c "nix --version" \
    && sudo rm -rf /tmp/install.sh /tmp/* \
    && true

# Install direnv
RUN set -ex \
    && curl --output /tmp/install.sh --proto '=https' --tlsv1.2 -Sf -L "https://direnv.net/install.sh" \
    && chmod +x /tmp/install.sh \
    && sudo bash -c "/tmp/install.sh" \
    && direnv --version \
    && sudo rm -rf /tmp/* \
    && true

# Install jq
RUN set -ex \
    && export arch="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
    && export varVerJq="$(curl -s https://api.github.com/repos/jqlang/jq/releases/latest | awk -F '["jq-]' '/tag_name/{print $7}')" \
    && export varUrlJq="https://github.com/jqlang/jq/releases/download/jq-${varVerJq}/jq-linux-${arch}" \
    && sudo curl -L "${varUrlJq}" -o /bin/jq \
    && sudo chmod +x /bin/jq \
    && /bin/jq --version \
    && true

# Install yq
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export varVerYq=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && export varUrlYq="https://github.com/mikefarah/yq/releases/download/v${varVerYq}/yq_linux_${arch}" \
    && sudo curl -L ${varUrlYq} -o /bin/yq \
    && sudo chmod +x /bin/yq \
    && /bin/yq --version \
    && true

#################################################################################
# Install Pulumi
#################################################################################

# Install Pulumi & Pulumi go deps
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
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "x64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export urlPulumiRelease="https://api.github.com/repos/pulumi/pulumi/releases/latest" \
    && export urlPulumiVersion=$(curl -s ${urlPulumiRelease} | awk -F '["v,]' '/tag_name/{print $5}') \
    && export urlPulumiBase="https://github.com/pulumi/pulumi/releases/download" \
    && export urlPulumiBin="pulumi-v${urlPulumiVersion}-linux-${arch}.tar.gz" \
    && export urlPulumi="${urlPulumiBase}/v${urlPulumiVersion}/${urlPulumiBin}" \
    && curl -L ${urlPulumi} | tar xzvf - --directory /tmp \
    && chmod +x /tmp/pulumi/* \
    && sudo mv /tmp/pulumi/* /usr/local/bin/ \
    && which pulumi \
    && pulumi version \
    && for pkg in ${GO_PKGS}; do go install ${pkg}; echo "Installed: ${pkg}"; done \
    && rm -rf /tmp/* \
    && true

# Install pulumi esc
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "x64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export urlPulumiRelease="https://api.github.com/repos/pulumi/esc/releases/latest" \
    && export urlPulumiVersion=$(curl -s ${urlPulumiRelease} | awk -F '["v,]' '/tag_name/{print $5}') \
    && export urlPulumiBase="https://github.com/pulumi/esc/releases/download" \
    && export urlPulumiBin="esc-v${urlPulumiVersion}-linux-${arch}.tar.gz" \
    && export urlPulumi="${urlPulumiBase}/v${urlPulumiVersion}/${urlPulumiBin}" \
    && curl -L ${urlPulumi} | tar xzvf - --directory /tmp \
    && chmod +x /tmp/esc/esc \
    && sudo mv /tmp/esc/esc /usr/local/bin/esc \
    && which esc \
    && esc version \
    && rm -rf /tmp/* \
    && true

# Install pulumictl
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export urlPulumiRelease="https://api.github.com/repos/pulumi/pulumictl/releases/latest" \
    && export urlPulumiVersion=$(curl -s ${urlPulumiRelease} | awk -F '["v,]' '/tag_name/{print $5}') \
    && export urlPulumiBase="https://github.com/pulumi/pulumictl/releases/download" \
    && export urlPulumiBin="pulumictl-v${urlPulumiVersion}-linux-${arch}.tar.gz" \
    && export urlPulumi="${urlPulumiBase}/v${urlPulumiVersion}/${urlPulumiBin}" \
    && curl -L ${urlPulumi} | tar xzvf - --directory /tmp \
    && chmod +x /tmp/pulumictl \
    && sudo mv /tmp/pulumictl /usr/local/bin/ \
    && which pulumictl \
    && pulumictl version \
    && rm -rf /tmp/* \
    && true

#################################################################################
# DevOps Dependencies
#################################################################################

# Install Kubectl
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export varVerKubectl="$(curl --silent -L https://storage.googleapis.com/kubernetes-release/release/stable.txt | sed 's/v//g')" \
    && export varUrlKubectl="https://storage.googleapis.com/kubernetes-release/release/v${varVerKubectl}/bin/linux/${arch}/kubectl" \
    && sudo curl -L ${varUrlKubectl} --output /bin/kubectl \
    && sudo chmod +x /bin/kubectl \
    && kubectl version --client \
    && true

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
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export varVerKrew=$(curl -s https://api.github.com/repos/kubernetes-sigs/krew/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && export varUrlKrew="https://github.com/kubernetes-sigs/krew/releases/download/v${varVerKrew}/krew-linux_${arch}.tar.gz" \
    && curl -L ${varUrlKrew} \
       | sudo tar xzvf - --directory /bin ./krew-linux_${arch} \
    && sudo mv /bin/krew-linux_${arch} /bin/kubectl-krew \
    && sudo chmod +x /bin/kubectl-krew \
    && /bin/kubectl krew version \
    && for pkg in ${CODE_PKGS}; do kubectl krew install ${pkg}; echo "Installed: ${pkg}"; done \
    && true

# Insall helm cli
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export varVerHelm="$(curl -s https://api.github.com/repos/helm/helm/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
    && export varUrlHelm="https://get.helm.sh/helm-v${varVerHelm}-linux-${arch}.tar.gz" \
    && curl -L ${varUrlHelm} | tar xzvf - --directory /tmp linux-${arch}/helm \
    && sudo mv /tmp/linux-${arch}/helm /bin/helm \
    && rm -rf /tmp/linux-${arch} \
    && sudo chmod +x /bin/helm \
    && /bin/helm version \
    && true

# Install clusterctl
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export varVerCapi=$(curl -s https://api.github.com/repos/kubernetes-sigs/cluster-api/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && export varUrlCapi="https://github.com/kubernetes-sigs/cluster-api/releases/download/v${varVerCapi}/clusterctl-linux-${arch}" \
    && sudo curl --output /usr/bin/clusterctl -L ${varUrlCapi} \
    && sudo chmod +x /usr/bin/clusterctl \
    && /usr/bin/clusterctl version \
    && true

# Install talosctl
RUN set -ex \
    && export arch="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
    && export varVerTalos="$(curl -s https://api.github.com/repos/siderolabs/talos/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')" \
    && export varUrlTalos="https://github.com/siderolabs/talos/releases/download/v${varVerTalos}/talosctl-linux-${arch}" \
    && sudo curl --output /usr/bin/talosctl -L ${varUrlTalos} \
    && sudo chmod +x /usr/bin/talosctl \
    && /usr/bin/talosctl version --client \
    && true

# Install virtctl
RUN set -ex \
    && export arch="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
    && export varVerKubevirt="$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')" \
    && export varUrlKubevirt="https://github.com/kubevirt/kubevirt/releases/download/v${varVerKubevirt}/virtctl-v${varVerKubevirt}-linux-${arch}" \
    && sudo curl -L ${varUrlKubevirt} -o /bin/virtctl \
    && sudo chmod +x /bin/virtctl \
    && /bin/virtctl version --client \
    && true

# Install Kind Kubernetes-in-Docker
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export varVerKind=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && export varUrlKind="https://github.com/kubernetes-sigs/kind/releases/download/v${varVerKind}/kind-linux-${arch}" \
    && sudo curl --output /usr/bin/kind -L ${varUrlKind} \
    && sudo chmod +x /usr/bin/kind \
    && /usr/bin/kind version \
    && true

# Insall istioctl
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && echo ${arch} && echo \
    && export varVerIstio="$(curl -s https://api.github.com/repos/istio/istio/releases/latest | awk -F '[\"v,]' '/tag_name/{print $4}')" \
    && echo ${varVerIstio} && echo \
    && export varUrlIstio="https://github.com/istio/istio/releases/download/${varVerIstio}/istio-${varVerIstio}-linux-${arch}.tar.gz" \
    && echo ${varUrlIstio} && echo \
    && curl -L ${varUrlIstio} | tar xzvf - --directory /tmp istio-${varVerIstio}/bin/istioctl \
    && chmod +x /tmp/istio-${varVerIstio}/bin/istioctl \
    && sudo mv /tmp/istio-${varVerIstio}/bin/istioctl /bin/istioctl \
    && /bin/istioctl version --short 2>&1 | grep -v unable \
    && rm -rf /tmp/istio* \
    && true

# Insall cilium cli
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && echo ${arch} && echo \
    && export varVerCiliumCli="$(curl -s https://api.github.com/repos/cilium/cilium-cli/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
    && echo ${varVerCiliumCli} && echo \
    && export varUrlCiliumCli="https://github.com/cilium/cilium-cli/releases/download/v${varVerCiliumCli}/cilium-linux-${arch}.tar.gz" \
    && echo ${varUrlCiliumCli} && echo \
    && curl -L ${varUrlCiliumCli} | tar xzvf - --directory /tmp cilium \
    && chmod +x /tmp/cilium \
    && sudo mv /tmp/cilium /bin/cilium \
    && /bin/cilium version --client \
    && rm -rf /tmp/cilium \
    && true

# Install k9scli.io
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export varVerK9s="$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
    && export varUrlK9s="https://github.com/derailed/k9s/releases/download/v${varVerK9s}/k9s_Linux_${arch}.tar.gz" \
    && curl -L ${varUrlK9s} \
       | sudo tar xzvf - --directory /usr/bin k9s \
    && sudo chmod +x /usr/bin/k9s \
    && /usr/bin/k9s version \
    && true

# Install ttyd
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "x86_64"; else if ($1 == "aarch64" || $1 == "arm64") print "aarch64"; else print "unknown" }') \
    && export varVerTtyd=$(curl -s https://api.github.com/repos/tsl0922/ttyd/releases/latest | awk -F '[":,]' '/tag_name/{print $5}') \
    && export varUrlTtyd="https://github.com/tsl0922/ttyd/releases/download/${varVerTtyd}/ttyd.${arch}" \
    && sudo curl -L ${varUrlTtyd} --output /bin/ttyd \
    && sudo chmod +x /bin/ttyd \
    && /bin/ttyd --version \
    && true

#################################################################################
# Load startup artifacts
COPY ./bin/code.entrypoint /bin/
COPY ./bin/connect         /bin/
COPY ./bin/entrypoint      /bin/

#################################################################################
# Entrypoint & default command
ENTRYPOINT /bin/entrypoint
CMD ["/usr/bin/env", "connect"]

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
LABEL \
  license="GPLv3" \
  name="Konductor" \
  distribution-scope="public" \
  io.k8s.display-name="Konductor" \
  summary="ContainerCraft Konductor DevOps Container" \
  io.openshift.tags="containercraft,konductor" \
  description="ContainerCraft Konductor DevOps Container" \
  maintainer="github.com/containercraft" \
  io.k8s.description="ContainerCraft Konductor DevOps Container" \
  org.opencontainers.image.source="https://github.com/containercraft/konductor" \
  org.opencontainers.image.description="Konductor is as a DevOps Userspace Container.\
    Included:\
    - Fish Shell\
    - Starship prompt by starship.rs\
    - VS Code Server by coder.com\
    - TTYd Terminal Server\
    - SSH Server\
    - SSH\
    - Tmux\
    - Tmate\
    - Helm\
    - K9s\
    - Kubectl\
    - Kumactl\
    - VirtCtl\
    - GRPCurl\
    - Pulumi\
    - Talosctl\
    - Skopeo\
    - Jq\
    - Yq\
"
