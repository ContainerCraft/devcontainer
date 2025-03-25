###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/containercraft/devcontainer:extra -f docker/extra/Dockerfile ./docker
# - docker run --rm -d --name devcontainer --hostname devcontainer --entrypoint bash ghcr.io/containercraft/devcontainer:extra
###############################################################################
FROM docker.io/gitlab/glab:latest as glab
FROM ghcr.io/containercraft/devcontainer:dind
LABEL tag="extra"
ENV DEVCONTAINER="extra"

#################################################################################
# Base package and user configuration
#################################################################################

# Configure Poetry cli
RUN poetry config virtualenvs.in-project true \
    && poetry config virtualenvs.create true

# Apt Packages
ARG APT_PKGS="\
  fish \
  "
RUN echo \
  && export TEST="fish --version" \
  && ${apt_update} \
  && bash -c "${apt_install} --no-install-recommends -o Dpkg::Options::='--force-confold' ${APT_PKGS}" \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Oh My Fish (OMF)
RUN echo \
  && export URL="https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install" \
  && ${curl} ${URL} --output /tmp/install \
  && fish -c '. /tmp/install --noninteractive' \
  && ${dir_clean} \
  && echo

# SSH & SSHD Packages
# TEST is not available normally as sshd has no version flag
RUN echo \
  && export TEST="command -v sshd" \
  && ${apt_update} \
  && DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y --no-install-recommends -o Dpkg::Options::='--force-confold' openssh-server ssh-askpass ssh-import-id \
  && sudo mkdir /var/run/sshd \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Cilium CLI
# - https://cilium.io
# - https://github.com/cilium/cilium-cli
RUN echo \
  && export NAME=cilium \
  && export TEST="${NAME} version --client" \
  && export REPOSITORY="cilium/cilium-cli" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}-linux-${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}"/${PKG} \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | tar xzvf - --directory /tmp ${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Istioctl CLI
# - https://istio.io
# - https://github.com/istio/istio
RUN echo \
  && export NAME=istioctl \
  && export TEST="${NAME} version --short 2>/dev/null" \
  && export REPOSITORY="istio/istio" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="istio-${VERSION}-linux-${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | tar xzvf - --directory /tmp istio-${VERSION}/bin/${NAME} \
  && sudo ${INSTALL} /tmp/istio-${VERSION}/bin/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Clusterctl CLI
RUN echo \
  && export NAME=clusterctl \
  && export TEST="${NAME} version" \
  && export REPOSITORY="kubernetes-sigs/cluster-api" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}-linux-${ARCH}" \
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

# Virtctl CLI
RUN echo \
  && export NAME=virtctl \
  && export TEST="${NAME} version --client" \
  && export REPOSITORY="kubevirt/kubevirt" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
  && export PKG="${NAME}-${VERSION}-linux-${ARCH}" \
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

##################################################################################
# Install Gitlab glab CLI
# - https://gitlab.com/gitlab-org/cli/-/blob/main/docs/installation_options.md#mpr-debianubuntu
COPY --from=glab /usr/bin/glab /usr/local/bin/glab

##################################################################################
# Install talosctl
RUN echo \
  && export NAME=talosctl \
  && export TEST="${NAME} version --client" \
  && export REPOSITORY="siderolabs/talos" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
  && export PKG="${NAME}-linux-${ARCH}" \
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

# Install omnictl
RUN echo \
  && export NAME=omnictl \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="siderolabs/omni" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
  && export PKG="${NAME}-linux-${ARCH}" \
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

##################################################################################
# Install kubelogin
# - dep of omnictl
RUN echo \
  && export NAME=kubelogin \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="azure/kubelogin" \
  && export VERSION="$(${curl_github} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH="$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }')" \
  && export PKG="${NAME}-linux-${ARCH}.zip" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && export DIR="/usr/local/bin" \
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && ${curl} ${URL} --output /tmp/${PKG} \
  && sudo unzip /tmp/${PKG} -d /tmp/ \
  && sudo mv /tmp/bin/linux_${ARCH}/${NAME} ${DIR}/${NAME} \
  && ${TEST} \
  && ${dir_clean} \
  && echo

##################################################################################
# Install ttyd
# - https://tsl0922.github.io/ttyd
# - https://github.com/tsl0922/ttyd
RUN echo \
&& export NAME=ttyd \
&& export TEST="${NAME} --version" \
&& export REPOSITORY="tsl0922/ttyd" \
&& export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
&& export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x86_64"; else if ($1 == "aarch64" || $1 == "arm64") print "aarch64"; else print "unknown" }') \
&& export PKG="${NAME}.${ARCH}" \
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

##################################################################################
# Install Flux CLI
# - https://fluxcd.io
# - https://github.com/fluxcd/flux2
RUN echo \
  && export NAME=flux \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="fluxcd/flux2" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}_${VERSION#v}_linux_${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | tar xzvf - --directory /tmp ${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

##################################################################################
# Install Terraform CLI
# - https://www.terraform.io
# - https://github.com/hashicorp/terraform
RUN echo \
  && export NAME=terraform \
  && export TEST="${NAME} --version" \
  && ${curl} https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null \
  && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list \
  && ${apt_update} \
  && bash -c "${apt_install} --no-install-recommends -o Dpkg::Options::='--force-confold' ${NAME}" \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

RUN echo \
  && export NAME=crossplane \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="crossplane/crossplane" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}" \
  && export URL="https://releases.crossplane.io/stable/${VERSION}/bin/linux_${ARCH}/${PKG}" \
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

# Helm cli
# - https://helm.sh
# - https://github.com/helm/helm
#RUN echo \
#  && export NAME=helm \
#  && export TEST="${NAME} version" \
#  && export REPOSITORY="helm/helm" \
#  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
#  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
#  && export PKG="${NAME}-${VERSION}-linux-${ARCH}.tar.gz" \
#  && export URL="https://get.helm.sh/${PKG}" \
#  && echo "---------------------------------------------------------"\
#  && echo "INFO[${NAME}] Installed:" \
#  && echo "INFO[${NAME}]   Command:        ${NAME}" \
#  && echo "INFO[${NAME}]   Package:        ${PKG}" \
#  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
#  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
#  && echo "INFO[${NAME}]   Source:         ${URL}" \
#  && echo "---------------------------------------------------------"\
#  && ${curl} ${URL} | tar xzvf - --directory /tmp linux-${ARCH}/${NAME} \
#  && sudo ${INSTALL} /tmp/linux-${ARCH}/${NAME} ${BIN}/${NAME} \
#  && ${dir_clean} \
#  && ${TEST} \
#  && echo

