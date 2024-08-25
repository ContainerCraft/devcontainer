###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:base -f docker/base/Dockerfile ./docker
# - docker run --rm -d --name devcontainer --hostname devcontainer --entrypoint bash ghcr.io/pulumi/devcontainer:base
###############################################################################
# Base VSCode Image
FROM ghcr.io/pulumi/devcontainer:slim-all
LABEL tag="base"
ENV TAG="base"

##################################################################################
#### Common Binary Install Arguments
##################################################################################

# Install Kubectl
# - https://kubernetes.io
# - github.com/kubernetes/kubernetes
RUN echo \
  && export NAME=kubectl \
  && export TEST="${NAME} version --client" \
  && export REPOSITORY="kubernetes/kubernetes" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}" \
  && export URL="https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/${ARCH}/${PKG}" \
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
  && ${dir_clean} \
  && ${TEST} \
  && echo

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
  && for pkg in ${CODE_PKGS}; do kubectl ${NAME} install ${pkg}; echo "Installed: ${pkg}"; done \
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
