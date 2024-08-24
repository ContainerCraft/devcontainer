# CCIO Devcontainer - DevOps Practitioner Container

CCIO Devcontainer is a DevOps practitioner userspace container designed to provide a consistent development environment for DevOps practitioners.

Common tools and config required for DevOps are added by default including Kubernetes, Helm, Kubectl, K9s, Tmux, and more.

## About

These images power [Konductor](https://github.com/containercraft/konductor). A multi-arch, and multi-platform opinionated VSCode IDE configuration for use on local machines, remote servers, and cloud-based development environments including Github Codespaces and others.

## Images

| Image | Description |
| --- | --- |
| `ghcr.io/containercraft/devcontainer:slim` | The foundational builder image for all other ccio devcontainers |
| `ghcr.io/containercraft/devcontainer:slim-node` | Node.js project slim devcontainer |
| `ghcr.io/containercraft/devcontainer:slim-python` | Python project slim devcontainer |
| `ghcr.io/containercraft/devcontainer:slim-go` | Go project slim devcontainer |
| `ghcr.io/containercraft/devcontainer:slim-dotnet` | .NET project slim devcontainer |
| `ghcr.io/containercraft/devcontainer:slim-all` | All-in-one slim devcontainer |
| `ghcr.io/containercraft/devcontainer:hugo` | Hugo Docs Development devcontainer |
| `ghcr.io/containercraft/devcontainer:base` | Base devcontainer with minimum viable tools and config built on `slim-all` |
| `ghcr.io/containercraft/devcontainer:dind` | Docker-in-Docker supported devcontainer |
| `ghcr.io/containercraft/devcontainer:extra` | Extra tools and config for Cloud Ops Development built on `dind` image |
| `ghcr.io/containercraft/devcontainer:code-server` | VSCode Code-Server devcontainer for running CCIO Devcontainer as a service |
