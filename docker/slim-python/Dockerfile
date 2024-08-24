###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim-python .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim-python
###############################################################################
# Base VSCode Image
FROM ghcr.io/pulumi/devcontainer:slim

#################################################################################
# Image Metadata
LABEL tag="slim-python"

#################################################################################
# Install Programming Language Tooling
# - python
ARG APT_PKGS="\
python3 \
python3-venv \
python3-dev \
python3.11 \
python3.11-venv \
python3.11-dev \
python3-pip \
"
RUN echo \
&& bash -c "${apt_install} ${APT_PKGS}" \
&& bash -c "${apt_clean}" \
&& sudo update-alternatives --install \
    /usr/bin/python python \
    /usr/bin/python3 1 \
&& ${dir_clean} \
&& echo

# Python Pip Packages
ARG PIP_PKGS="\
setuptools \
"
RUN echo \
&& sudo python3 -m pip install ${PIP_PKGS} \
&& ${dir_clean} \
&& echo
