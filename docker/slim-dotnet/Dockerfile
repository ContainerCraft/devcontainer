###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim-dotnet -f ./docker/slim-dotnet/Dockerfile ./docker
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim-dotnet
###############################################################################
# Base VSCode Image
FROM ghcr.io/containercraft/devcontainer:slim

#################################################################################
# Image Metadata
LABEL tag="slim-dotnet"

#################################################################################
# Install Programming Language Tooling
# - dotnet
ARG APT_PKGS="\
  dotnet-sdk-8.0 \
  dotnet-runtime-8.0 \
  "
RUN echo \
  && sudo apt-get update \
  && bash -c "${apt_install} ${APT_PKGS}" \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && echo
