###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/containercraft/devcontainer:code-server -f docker/code-server/Dockerfile ./docker
# - docker run --rm -d --name devcontainer --hostname devcontainer --entrypoint bash ghcr.io/containercraft/devcontainer:code-server
###############################################################################
FROM ghcr.io/containercraft/devcontainer:nvim
LABEL tag="code-server"
ENV DEVCONTAINER="code-server"

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
  /var/lib/{apt,cache,log} \
  /usr/share/{doc,man,locale} \
  /etc/apt/sources.list.d/nodesource.list \
  /var/cache/apt \
  /root/.cache \
  /var/tmp/* \
  /tmp/* \
  && true

# Install VSCode Extension Plugins
ARG CODE_PKGS="\
vscodevim.vim \
stateful.runme \
max-ss.cyberpunk \
ms-python.python \
esbenp.prettier-vscode \
oderwat.indent-rainbow \
okteto.kubernetes-context \
ms-vsliveshare.vsliveshare \
ms-azuretools.vscode-docker \
github.vscode-github-actions \
github.vscode-pull-request-github \
ms-vscode-remote.remote-containers \
randomfractalsinc.vscode-data-table \
ms-kubernetes-tools.vscode-kubernetes-tools \
"

RUN set -ex \
  && for pkg in ${CODE_PKGS}; do code-server --install-extension ${pkg}; echo "Installed: ${pkg}"; done \
  && true