###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:extra .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:extra
###############################################################################
FROM ghcr.io/pulumi/devcontainer:dind

#################################################################################
# Image Metadata
#################################################################################
LABEL tag="extra"

#################################################################################
# Base package and user configuration
#################################################################################

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

# Helm cli
# - https://helm.sh
# - https://github.com/helm/helm
RUN echo \
&& export NAME=helm \
&& export TEST="${NAME} version" \
&& export REPOSITORY="helm/helm" \
&& export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
&& export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
&& export PKG="${NAME}-${VERSION}-linux-${ARCH}.tar.gz" \
&& export URL="https://get.helm.sh/${PKG}" \
&& echo "---------------------------------------------------------"\
&& echo "INFO[${NAME}] Installed:" \
&& echo "INFO[${NAME}]   Command:        ${NAME}" \
&& echo "INFO[${NAME}]   Package:        ${PKG}" \
&& echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
&& echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
&& echo "INFO[${NAME}]   Source:         ${URL}" \
&& echo "---------------------------------------------------------"\
&& ${curl} ${URL} | tar xzvf - --directory /tmp linux-${ARCH}/${NAME} \
&& sudo ${INSTALL} /tmp/linux-${ARCH}/${NAME} ${BIN}/${NAME} \
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

# Talosctl CLI
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
