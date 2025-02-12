###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim-python .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim-python
###############################################################################
# Base VSCode Image
FROM ghcr.io/containercraft/devcontainer:slim

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
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    python3-setuptools \
    "
RUN echo \
    && sudo apt-get update \
    && bash -c "${apt_install} ${APT_PKGS}" \
    && bash -c "${apt_clean}" \
    && sudo update-alternatives --install \
    /usr/bin/python python \
    /usr/bin/python3 1 \
    && ${dir_clean} \
    && echo

## Python Pip Packages
#ARG PIP_PKGS="\
#    "
#RUN echo \
#    && sudo python3 -m pip install ${PIP_PKGS} \
#    && ${dir_clean} \
#    && echo

##################################################################################
# Install Poetry for Python dependency management
ENV POETRY_HOME="/usr/local"
ENV PATH="/usr/local/bin:${PATH}"

USER root
RUN PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2) \
    && NAME="poetry" \
    && echo "---------------------------------------------------------" \
    && echo "INFO[${NAME}] Installing:" \
    && echo "INFO[${NAME}]   Command:        ${NAME}" \
    && echo "INFO[${NAME}]   Python Version: ${PYTHON_VERSION}" \
    && echo "---------------------------------------------------------" \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && chmod +x /usr/local/bin/poetry \
    && poetry config virtualenvs.in-project true \
    && poetry --version \
    && mkdir -p \
         /home/ubuntu/.config/pypoetry \
         /etc/skel/.config/pypoetry \
    && chown -R ubuntu:ubuntu /home/ubuntu/.config \
    && echo
USER ubuntu

