#!/bin/bash
podman kill konductor
podman run -d --rm --cap-add=CAP_AUDIT_WRITE --publish 2222:2222 --publish 7681:7681 --publish 8088:8080 --name konductor --hostname konductor --security-opt label=disable --pull=always ghcr.io/containercraft/konductor
