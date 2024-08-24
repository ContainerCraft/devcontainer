###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:base .
###############################################################################
# Base VSCode Image
FROM ghcr.io/pulumi/devcontainer:slim-all

#################################################################################
# Base package and user configuration
#################################################################################

# Apt Packages
ARG APT_PKGS="\
bc \
mc \
btop \
pigz \
ripgrep \
tcpdump \
libwrap0 \
neofetch \
"

# Apt Packages
RUN echo \
&& export TEST="neofetch" \
&& ${apt_update} \
&& bash -c "${apt_install} --no-install-recommends -o Dpkg::Options::='--force-confold' ${APT_PKGS}" \
&& bash -c "${apt_clean}" \
&& ${dir_clean} \
&& ${TEST} \
&& echo

#################################################################################
# Image Metadata
#################################################################################
LABEL tag="base"

##################################################################################
#### Common Binary Install Arguments
##################################################################################

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
view-secret \
view-cert \
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
