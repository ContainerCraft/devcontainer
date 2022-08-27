# docker run --rm --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 -d --name konductor --hostname konductor ghcr.io/usrbinkat/konductor
# podman run -d --rm --cap-add=CAP_AUDIT_WRITE --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 --name konductor --hostname konductor --security-opt label=disable --pull=always ghcr.io/usrbinkat/konductor
###############################################################################
# Builder Image
FROM quay.io/fedora/fedora:36 as builder

###############################################################################
# DNF Package List
ARG DNF_LIST="\
  xz \
  bc \
  dnf \
  vim \
  git \
  tar \
  sudo \
  file \
  wget \
  tree \
  tmux \
  pigz \
  fish \
  bash \
  curl \
  which \
  glibc \
  rsync \
  unzip \
  podman \
  passwd \
  skopeo \
  bsdtar \
  sqlite \
  iputils \
  findutils \
  procps-ng \
  net-tools \
  nmap-ncat \
  bind-utils \
  httpd-tools \
  openssh-server \
  libvarlink-util \
  bash-completion \
  glibc-langpack-en \
  glibc-locale-source \
  python3-pip \
  python3 \
  fira-code-fonts \
  powerline-fonts \
  tmux-powerline \
  starship \
"
# glibc-all-langpacks \

ARG PIP_LIST="\
  k8s \
  passlib \ 
  ansible \
  github3.py \
  kubernetes \
"
###############################################################################
# DNF Package Install Flags
ARG DNF_FLAGS="\
  -y \
  --releasever 36 \
  --installroot /rootfs \
"
ARG DNF_FLAGS_EXTRA="\
  --nodocs \
  --exclude container-selinux \
  --setopt=install_weak_deps=false \
  ${DNF_FLAGS} \
"

###############################################################################
# Build Rootfs
ARG BUILD_PATH=/rootfs
RUN set -ex \
     && mkdir -p ${BUILD_PATH} \
     && dnf install ${DNF_FLAGS_EXTRA} ${DNF_LIST} \
     && dnf -y install ${DNF_FLAGS_EXTRA} 'dnf-command(copr)' \
     && dnf clean all ${DNF_FLAGS} \
     && rm -rf \
           ${BUILD_PATH}/var/cache/* \
           ${BUILD_PATH}/var/log/dnf* \
           ${BUILD_PATH}/var/log/yum* \
    && echo

#################################################################################
# Create image from rootfs
FROM scratch
COPY --from=builder /rootfs /
ADD ./rootfs/ /
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
COPY ./bin/code.entrypoint /bin/
COPY ./bin/connect         /bin/
COPY ./bin/entrypoint      /bin/

# Install NerdFonts FiraCode
#RUN set -ex \
#    && curl -LO https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install \
#    && fish -c install \
#    && curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip \
#    && unzip FiraCode.zip -d /usr/share/fonts/NerdFonts \
#    && rm -rf FiraCode.zip \
#    && echo 
#   && git clone --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts \
#   && cd nerd-fonts \
#   && git sparse-checkout add patched-fonts/FiraCode \
#   && ./install.sh FiraCode \
#   && mv /root/.local/share/fonts/NerdFonts /etc/skel/.local/share/fonts/ \

# Add User 'k'
RUN set -ex \
     && groupadd --system sudo \
     && groupadd -g 1001 k \
     && useradd -m -u 1001 -g 1001 -s /usr/bin/fish --groups sudo k \
     && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#################################################################################
# Install helm cli
RUN set -ex \
     && export varVerHelm="$(curl -s https://api.github.com/repos/helm/helm/releases/latest | awk -F '[\"v,]' '/tag_name/{print $5}')" \
     && export varUrlHelm="https://get.helm.sh/helm-v${varVerHelm}-linux-amd64.tar.gz" \
     && curl -L ${varUrlHelm} | tar xzvf - --directory /tmp linux-amd64/helm \
     && mv /tmp/linux-amd64/helm /bin/helm \
     && rm -rf /tmp/linux-amd64 \
     && chmod +x /bin/helm \
     && /bin/helm version \
    && echo

# Add Pulumi binary
RUN set -ex \
     && export urlPulumiRelease="https://api.github.com/repos/pulumi/pulumi/releases/latest" \
     && export urlPulumiVersion=$(curl -s ${urlPulumiRelease} | awk -F '["v,]' '/tag_name/{print $5}') \
     && export urlPulumiBase="https://github.com/pulumi/pulumi/releases/download" \
     && export urlPulumiBin="pulumi-v${urlPulumiVersion}-linux-x64.tar.gz" \
     && export urlPulumi="${urlPulumiBase}/v${urlPulumiVersion}/${urlPulumiBin}" \
     && curl -L ${urlPulumi} \
        | tar xzvf - --directory /tmp \
     && mv /tmp/pulumi/* /usr/local/bin/ \
     && rm -rf /tmp/pulumi \
     && pulumi version \
    && echo

# Install openshift client plugin "oc-mirror"
#RUN set -ex \
#     && export varVerOpenshift="$(curl --silent https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt | awk '/  Version/{print $2}')" \
#     && export varUrlOpenshift="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/oc-mirror-${varVerOpenshift}.tar.gz" \
#     && curl -L ${varUrlOpenshift} \
#        | tar xzvf - --directory /bin oc-mirror \
#     && chmod +x /bin/oc-mirror \
#     && /bin/oc-mirror version --client \
#    && echo

# Install openshift client "oc"
RUN set -ex \
     && export varVerOpenshift="$(curl --silent https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt | awk '/  Version/{print $2}')" \
     && export varUrlOpenshift="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-${varVerOpenshift}.tar.gz" \
     && curl -L ${varUrlOpenshift} \
        | tar xzvf - --directory /bin oc kubectl \
     && chmod +x /bin/oc /bin/kubectl \
     && /bin/oc version --client \
    && echo

# Install virtctl
RUN set -ex \
     && export varVerKubevirt=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
     && export varUrlKubevirt="https://github.com/kubevirt/kubevirt/releases/download/v${varVerKubevirt}/virtctl-v${varVerKubevirt}-linux-amd64" \
     && curl -L ${varUrlKubevirt} -o /bin/virtctl \
     && chmod +x /bin/virtctl \
     && /bin/virtctl version --client \
    && echo

# Install jq
RUN set -ex \
     && export varVerJq=$(curl -s https://api.github.com/repos/stedolan/jq/releases/latest | awk -F '["jq-]' '/tag_name/{print $7}') \
     && export varUrlJq="https://github.com/stedolan/jq/releases/download/jq-${varVerJq}/jq-linux64" \
     && curl -L ${varUrlJq} -o /bin/jq \
     && chmod +x /bin/jq \
     && /bin/jq --version \
    && echo

# Install yq
RUN set -ex \
     && export varVerYq=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
     && export varUrlYq="https://github.com/mikefarah/yq/releases/download/v${varVerYq}/yq_linux_amd64" \
     && curl -L ${varUrlYq} -o /bin/yq \
     && chmod +x /bin/yq \
     && /bin/yq --version \
   && echo

# Install grpcurl
RUN set -ex \
     && export varVerGrpcurl=$(curl -s https://api.github.com/repos/fullstorydev/grpcurl/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
     && export varUrlGrpcurl="https://github.com/fullstorydev/grpcurl/releases/download/v${varVerGrpcurl}/grpcurl_${varVerGrpcurl}_linux_x86_64.tar.gz" \
     && curl -L ${varUrlGrpcurl} \
        | tar xzvf - --directory /bin grpcurl \
     && chmod +x /bin/grpcurl \
     && /bin/grpcurl --version \
    && echo

# Install ttyd
RUN set -ex \
     && export varVerTtyd=$(curl -s https://api.github.com/repos/tsl0922/ttyd/releases/latest | awk -F '[":,]' '/tag_name/{print $5}') \
     && export varUrlTtyd="https://github.com/tsl0922/ttyd/releases/download/${varVerTtyd}/ttyd.x86_64" \
     && curl -L ${varUrlTtyd} --output /bin/ttyd \
     && chmod +x /bin/ttyd \
     && /bin/ttyd --version \
    && echo

# Install VSCode Service
RUN set -ex \
     && export varVerCode=$(curl -s https://api.github.com/repos/coder/code-server/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
     && dnf install -y "https://github.com/coder/code-server/releases/download/v${varVerCode}/code-server-${varVerCode}-amd64.rpm" \
     && dnf clean all \
     && rm -rf \
           ${BUILD_PATH}/var/cache/* \
           ${BUILD_PATH}/var/log/dnf* \
           ${BUILD_PATH}/var/log/yum* \
     && code-server --install-extension vscodevim.vim \
     && code-server --install-extension redhat.vscode-yaml \
     && code-server --install-extension esbenp.prettier-vscode \
     && code-server --install-extension oderwat.indent-rainbow \
     && code-server --install-extension tabnine.tabnine-vscode \
     && code-server --install-extension zhuangtongfa.Material-theme \
     && code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools \
     && ln /usr/bin/vim /usr/bin/vi \
    && echo 

#################################################################################
# Ports
EXPOSE 2222
EXPOSE 8080
EXPOSE 7681

USER k 
ENTRYPOINT /bin/entrypoint
CMD ["/usr/bin/env", "connect"]

#################################################################################
# Finalize Image
WORKDIR /root/
MAINTAINER "github.com/usrbinkat"
ENV \
  BUILDAH_ISOLATION=chroot \
  REGISTRY_AUTH_FILE='/root/.docker/config.json' \
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.local/bin"
LABEL \
  license=GPLv3 \
  name="konductor" \
  distribution-scope="public" \
  io.k8s.display-name="konductor" \
  summary="UBK Konductor Cloud Bastion" \
  io.openshift.tags="usrbinkat,konductor" \
  description="UBK Konductor Cloud Bastion" \
  io.k8s.description="UBK Konductor Cloud Bastion" \
  org.opencontainers.image.source="https://github.com/usrbinkat/konductor" \
  org.opencontainers.image.description="\
  Konductor is as a multi-function operator and developer bastion.\
    Included:\
    - Fish Shell\
    - Starship prompt by starship.rs\
    - VS Code Server\
    - TTYd Terminal Server\
    - SSH Server\
    - SSH\
    - Tmux\
    - Helm\
    - Kubectl\
    - VirtCtl\
    - GRPCurl\
    - Pulumi\
    - Skopeo\
    - Jq\
    - Yq\
  "
