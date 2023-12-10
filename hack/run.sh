#!/bin/bash
#podman kill konductor
#podman run -d --rm --cap-add=CAP_AUDIT_WRITE --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 --name konductor --hostname konductor --security-opt label=disable --pull=always ghcr.io/containercraft/konductor

docker run -it --rm --pull=never --name konductor --hostname k \
          --publish 2222:2222 \
          --publish 7681:7681 \
          --publish 8088:8080 \
          --publish 32767:32767 \
          --volume $PWD:/home/k/konductor:z \
          --volume $PWD/hack/group:/etc/group \
          --volume $PWD/hack/passwd:/etc/passwd \
          --user $(id -u):$(id -g) --entrypoint fish --workdir /home/k/konductor \
        local.host/konductor/k:test
#       ghcr.io/containercraft/konductor:latest
#       192.168.1.2:32000/konductor/k:latest
#         --volume $PWD/sudo:/etc/sudoers.d/sudo \
