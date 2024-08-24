###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim-golang .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim-golang
###############################################################################
# Base VSCode Image
FROM ghcr.io/pulumi/devcontainer:slim

#################################################################################
# Image Metadata
LABEL tag="slim-golang"

#################################################################################
# Install Programming Language Tooling
# - golang
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
