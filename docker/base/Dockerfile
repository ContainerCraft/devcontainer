###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:base -f docker/base/Dockerfile ./docker
# - docker run --rm -d --name devcontainer --hostname devcontainer --entrypoint bash ghcr.io/pulumi/devcontainer:base
###############################################################################
# Base VSCode Image
FROM ghcr.io/containercraft/devcontainer:slim-all
LABEL tag="base"
ENV DEVCONTAINER="base"

##################################################################################
#### Common Binary Install Arguments
##################################################################################

# Install Kubectl
# - https://kubernetes.io
#:sparkles:  - github.com/kubernetes/kubernetes
# && export URL="https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/${ARCH}/${PKG}" \
RUN echo \
  && export NAME=kubectl \
  && export TEST="${NAME} version --client" \
  && export REPOSITORY="kubernetes/kubernetes" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}" \
  && export URL="https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && sudo ${curl} ${URL} --output /tmp/${NAME} \
  && sudo ${INSTALL} /tmp/kubectl ${BIN}/${NAME} \
  && sudo ${INSTALL} /tmp/kubectl ${BIN}/k \
  && ${dir_clean} \
  && ${TEST} \
  && echo

##################################################################################
# Install kubecolor CLI
# - https://github.com/kubecolor/kubecolor/releases/download/v0.4.0/kubecolor_0.4.0_linux_amd64.tar.gz
# - kubecolor_0.0.0_linux_amd64.tar.gz
RUN echo \
  && export NAME=kubecolor \
  && export TEST="${NAME} version --client" \
  && export REPOSITORY="kubecolor/kubecolor" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="$(echo ${NAME}_${VERSION}_linux_${ARCH}.tar.gz| sed 's/v//')" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | sudo tar xzvf - --directory /tmp ${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Install Krew
ARG KREW_PKG="\
  view-utilization \
  view-secret \
  oidc-login \
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
RUN echo \
  && export NAME=krew \
  && export TEST="kubectl ${NAME} version" \
  && export REPOSITORY="kubernetes-sigs/${NAME}" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export PKG="${NAME}-linux_${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command: (kubectl) ${NAME}" \
  && echo "INFO[${NAME}]   Package:           ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release:    ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:      ${ARCH}" \
  && echo "INFO[${NAME}]   Source:            ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | tar xzvf - --directory /tmp ./${NAME}-linux_${ARCH} \
  && sudo ${INSTALL} /tmp/${NAME}-linux_${ARCH} ${BIN}/kubectl-${NAME} \
  && kubectl krew update \
  && for pkg in ${CODE_PKGS}; do kubectl ${NAME} install ${pkg}; echo "Installed: ${pkg}"; done \
  && kubectl krew update \
  && kubectl krew install oidc-login \
  && ${dir_clean} \
  && ${TEST} \
  && echo

##################################################################################
# Install k9s CLI
# - https://k9scli.io
# - https://github.com/derailed/k9s
RUN echo \
  && export NAME=k9s \
  && export TEST="${NAME} version" \
  && export REPOSITORY="derailed/k9s" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}_Linux_${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | sudo tar xzvf - --directory /tmp ${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

##################################################################################
# Install kubectx CLI
# - https://github.com/ahmetb/kubectx
RUN echo \
  && export NAME=kubectx \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="ahmetb/kubectx" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x86_64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}_${VERSION}_linux_${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} -L ${URL} | sudo tar xzvf - --directory /tmp ${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo

##################################################################################
# Install kubens CLI
# - https://github.com/ahmetb/kubectx
RUN echo \
  && export NAME=kubens \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="ahmetb/kubectx" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x86_64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}_${VERSION}_linux_${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installed:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} -L ${URL} | sudo tar xzvf - --directory /tmp ${NAME} \
  && sudo ${INSTALL} /tmp/${NAME} ${BIN}/${NAME} \
  && ${dir_clean} \
  && ${TEST} \
  && echo
