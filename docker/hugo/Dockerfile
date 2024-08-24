###############################################################################
# Use:
# - docker build --progress plain --tag ghcr.io/pulumi/devcontainer:hugo .
# - docker run --rm -d --name devcontainer --hostname devcontainer ghcr.io/pulumi/devcontainer:hugo
###############################################################################
# Based from the Pulumi Devcontainer SLIM image.
FROM ghcr.io/pulumi/devcontainer:slim-all

#################################################################################
# Image Metadata
#################################################################################
LABEL tag="hugo"

# Apt Packages
ARG APT_PKGS="\
chromium-browser \
"
# Apt Packages
RUN echo \
&& export TEST="gh version" \
&& ${apt_update} \
&& bash -c "${apt_install} --no-install-recommends -o Dpkg::Options::='--force-confold' ${APT_PKGS}" \
&& bash -c "${apt_clean}" \
&& ${dir_clean} \
&& ${TEST} \
&& echo

# Install hugo
EXPOSE 1313
RUN set -ex \
    && export arch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
    && export urlHugoRelease="https://api.github.com/repos/gohugoio/hugo/releases/latest" \
    && export urlHugoVersion=$(curl -s ${urlHugoRelease} | awk -F '["v,]' '/tag_name/{print $5}') \
    && export urlHugoBase="https://github.com/gohugoio/hugo/releases/download" \
    && export urlHugoBin="hugo_${urlHugoVersion}_linux-${arch}.deb" \
    && export urlHugo="${urlHugoBase}/v${urlHugoVersion}/${urlHugoBin}" \
    && curl --output /tmp/${urlHugoBin} -L ${urlHugo} \
    && sudo dpkg -i /tmp/${urlHugoBin} \
    && which hugo \
    && hugo version \
    && rm -rf /tmp/* \
    && true
