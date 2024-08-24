###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:code .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:code
###############################################################################
FROM ghcr.io/pulumi/devcontainer:extra

#################################################################################
# Image Metadata
#################################################################################
LABEL tag="code-server"

# Install VSCode Service
EXPOSE 8080
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "aarch64") print "arm64"; else print "unknown" }') \
    && export varVerCode=$(curl -s https://api.github.com/repos/coder/code-server/releases/latest | awk -F '["v,]' '/tag_name/{print $5}') \
    && curl --output /tmp/code-server.deb -L "https://github.com/coder/code-server/releases/download/v${varVerCode}/code-server_${varVerCode}_${arch}.deb" \
    && sudo apt-get update \
    && sudo apt-get install -y /tmp/code-server.deb \
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

# Install VSCode Extension Plugins
ARG CODE_PKGS="\
golang.go \
vscodevim.vim \
github.copilot \
max-ss.cyberpunk \
ms-python.python \
redhat.vscode-yaml \
esbenp.prettier-vscode \
oderwat.indent-rainbow \
okteto.kubernetes-context \
ms-vsliveshare.vsliveshare \
chadonsom.auto-view-readme \
ms-azuretools.vscode-docker \
github.vscode-github-actions \
ms-kubernetes-tools.kind-vscode \
ms-vscode.vscode-typescript-next \
github.vscode-pull-request-github \
matt-rudge.auto-open-preview-panel \
ms-vscode-remote.remote-containers \
bierner.markdown-preview-github-styles \
visualstudioexptteam.vscodeintellicode \
bierner.markdown-preview-github-styles \
ms-kubernetes-tools.vscode-kubernetes-tools \
"
RUN set -ex \
    && for pkg in ${CODE_PKGS}; do code-server --install-extension ${pkg}; echo "Installed: ${pkg}"; done \
    && true

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
