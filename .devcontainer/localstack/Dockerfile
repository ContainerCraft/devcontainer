FROM ghcr.io/containercraft/konductor:latest

RUN set -ex \
  && ${apt_update} \
  && sudo apt install -y python3 python3.11 python3-dev python3.11-dev python3-venv python3.11-venv \
  && sudo pip install localstack localstack[runtime] \
  && ${apt_clean} \
  && echo
