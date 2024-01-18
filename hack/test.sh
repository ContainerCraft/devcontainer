#!/bin/bash
docker run -d --rm --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock --cap-add=CAP_AUDIT_WRITE --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 --name konductor --hostname konductor --security-opt label=disable --pull=always ghcr.io/containercraft/konductor

#docker run -it --rm --pull always --privileged --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock ghcr.io/containercraft/konductor:latest
