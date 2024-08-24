# CCIO Devcontainer - DevOps Practitioner Container

CCIO Devcontainer is a DevOps practitioner userspace container designed to provide a consistent development environment for DevOps practitioners.

Common tools and config required for DevOps are added by default including Kubernetes, Helm, Kubectl, K9s, Tmux, and more.

## About

These images power [Konductor](https://github.com/containercraft/konductor). A multi-arch, and multi-platform opinionated VSCode IDE configuration for use on local machines, remote servers, and cloud-based development environments including Github Codespaces and others.

## Images

Tags for the `ghcr.io/containercraft/devcontainer` image:

> **Note:** If uncertain, use `latest` or 'extra' image tag.

| Image | Description |
| --- | --- |
| `latest` | An alias of `extra` |
| `extra` | Extra tools and config for Cloud Ops Development built on `dind` image |
| `code-server` | VSCode Code-Server devcontainer for running CCIO Devcontainer as a service |
| --- | --- |
| `slim` | The foundational builder image for all other ccio devcontainers |
| `slim-node` | Node.js project slim devcontainer |
| `slim-python` | Python project slim devcontainer |
| `slim-go` | Go project slim devcontainer |
| `slim-dotnet` | .NET project slim devcontainer |
| `slim-all` | All-in-one slim devcontainer |
| `hugo` | Hugo Docs Development devcontainer |
| `base` | Base devcontainer with minimum viable tools and config built on `slim-all` |
| `dind` | Docker-in-Docker supported devcontainer |
