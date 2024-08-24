###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim-dotnet .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim-dotnet
###############################################################################
# Base VSCode Image
FROM ghcr.io/pulumi/devcontainer:slim

#################################################################################
# Image Metadata
LABEL tag="slim-dotnet"

#################################################################################
# Install Programming Language Tooling
# - dotnet
ARG APT_PKGS="\
dotnet-sdk-7.0 \
dotnet-runtime-7.0 \
"
RUN echo \
&& bash -c "${apt_install} ${APT_PKGS}" \
&& bash -c "${apt_clean}" \
&& ${dir_clean} \
&& echo
