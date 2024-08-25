###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:dind -f docker/docker-in-docker/Dockerfile ./docker
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:dind
###############################################################################
FROM ghcr.io/containercraft/devcontainer:base
LABEL tag="dind"
ENV TAG="dind"

#################################################################################
# Base package and user configuration
#################################################################################

# devcontainer docker-in-docker dependencies
ARG APT_PKGS="\
  docker-buildx-plugin \
  docker-ce-cli \
  libffi-dev \
  iptables \
  "
RUN echo \
  && ${curl} https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list \
  && ${apt_update} \
  && bash -c "${apt_install} ${APT_PKGS}" \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && sudo update-alternatives --set iptables /usr/sbin/iptables-legacy \
  && sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy \
  && echo

# Install Kind Kubernetes-in-Docker
RUN echo \
  && export NAME=kind \
  && export TEST="${NAME} version" \
  && export REPOSITORY="kubernetes-sigs/kind" \
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
