###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:slim-node .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:slim-node
###############################################################################
# Base VSCode Image
FROM ghcr.io/pulumi/devcontainer:slim

#################################################################################
# Image Metadata
LABEL tag="slim-node"

#################################################################################
# Install Programming Language Tooling
# - nodejs
# - npm
# - yarn
RUN echo \
&& export NODE_MAJOR=20 \
&& ${curl} https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
&& echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
    | sudo tee /etc/apt/sources.list.d/nodesource.list \
&& sudo apt-get update \
&& sudo apt-get install nodejs \
&& sudo apt-get clean \
&& sudo apt-get autoremove -y \
&& sudo apt-get purge -y --auto-remove \
&& ${dir_clean} \
&& node --version \
&& npm --version \
&& sudo npm install --global yarn \
&& yarn --version \
&& true
