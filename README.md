# ContainerCraft Devcontainer

[![Build Status](https://github.com/containercraft/devcontainer/actions/workflows/build.yaml/badge.svg)](https://github.com/containercraft/devcontainer/actions/workflows/build.yaml)

A comprehensive cloud-native development container with built-in support for Pulumi, Kubernetes, and modern development workflows. Pre-configured with essential tools and optimized for cloud infrastructure development.

## Table of Contents

- [Features](#features)
- [Image Variants](#image-variants)
  - [Supported Architectures](#supported-architectures)
- [Development Modes](#development-modes)
  - [VSCode / Cursor AI Development Container](#vscode--cursor-ai-development-container)
  - [Neovim Development Environment](#neovim-development-environment)
  - [Remote Code-Server](#remote-code-server)
  - [Terminal-Based Development](#terminal-based-development)
  - [Local Docker Desktop / Docker CLI (on Linux)](#local-docker-desktop--docker-cli-on-linux)
  - [Remote GitHub Codespaces via Remote Containers Extension](#remote-github-codespaces-via-remote-containers-extension)
- [Installed Tools](#installed-tools)
  - [Programming Languages](#programming-languages)
  - [Core Utilities](#core-utilities)
  - [Development Tools](#development-tools)
  - [Cloud Native Tools](#cloud-native-tools)
- [Configuration and Environment](#configuration-and-environment)
  - [Environment Variables](#environment-variables)
  - [User and Permission Model](#user-and-permission-model)
  - [Volume Mounts and Ports](#volume-mounts-and-ports)
  - [Shell Customizations](#shell-customizations)
- [Usage](#usage)
  - [Quick Start Guides](#quick-start-guides)
    - [Running the Slim Variant](#running-the-slim-variant)
    - [Accessing Neovim](#accessing-neovim)
    - [Using Docker-in-Docker](#using-docker-in-docker)
  - [Volume and Network Configuration](#volume-and-network-configuration)
- [Technical Specifications](#technical-specifications)
  - [Container Configuration](#container-configuration)
  - [Tool Chain Details](#tool-chain-details)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- 🏗️ **Multi-architecture support**: Compatible with both `amd64` and `arm64` architectures.
- 🐳 **Docker-in-Docker capabilities**: Enables running Docker inside the container for testing and development.
- 🔧 **Multiple development modes**: Supports VSCode, Neovim, and Code-Server for diverse workflows.
- 🛠️ **Comprehensive cloud-native CLI tools**: Includes Kubernetes tools, Pulumi, Helm, and more.
- 🐍 **Multiple language support**: Python, Node.js, Go, and .NET environments pre-configured.
- 🔐 **Security-focused configuration**: User and permission models optimized for secure development.
- 🎨 **Custom shell with Starship prompt**: Enhanced terminal experience with Starship and tmux.
- 🖥️ **Remote development ready**: Optimized for Codespaces and remote container development.

## Image Variants

The ContainerCraft Devcontainer provides multiple Docker image variants tailored for different development needs. Below is a summary of the available images, their inheritance chain, and key features.

| Tag           | Base Image                                     | Description                        | Key Features                      |
|---------------|------------------------------------------------|------------------------------------|-----------------------------------|
| `slim`        | `mcr.microsoft.com/devcontainers/base:ubuntu`  | Minimal base environment           | Core dev tools, Pulumi CLI        |
| `slim-python` | `ghcr.io/containercraft/devcontainer:slim`     | Python development environment     | Python 3.x, Poetry                |
| `slim-node`   | `ghcr.io/containercraft/devcontainer:slim`     | Node.js development environment    | Node.js 20.x, npm, yarn           |
| `slim-golang` | `ghcr.io/containercraft/devcontainer:slim`     | Go development environment         | Go 1.x                            |
| `slim-dotnet` | `ghcr.io/containercraft/devcontainer:slim`     | .NET development environment       | .NET SDK 7.0                      |
| `slim-all`    | `ghcr.io/containercraft/devcontainer:slim`     | All language support               | Python, Go, Node.js, .NET         |
| `dind`        | `ghcr.io/containercraft/devcontainer:slim`     | Docker-in-Docker capabilities      | Docker CLI, Docker Buildx         |
| `base`        | `ghcr.io/containercraft/devcontainer:slim-all` | Kubernetes-focused tools           | kubectl, k9s, Helm, Krew plugins  |
| `nvim`        | `ghcr.io/containercraft/devcontainer:dind`     | Neovim development environment     | Neovim with LazyVim configuration |
| `extra`       | `ghcr.io/containercraft/devcontainer:nvim`     | Extended tools                     | Additional CLIs                   |
| `code`        | `ghcr.io/containercraft/devcontainer:extra`    | VSCode Server in browser           | code-server with browser access   |

### Supported Architectures

All images support the following architectures:

- `amd64` (x86_64)
- `arm64` (aarch64)

## Development Modes

### VSCode / Cursor AI Development Container

Leverage the development container with [Visual Studio Code](https://code.visualstudio.com/) or [Cursor AI](https://cursor.dev/) for a seamless development experience.

Add the following `.devcontainer/Dockerfile` to your project:

```Dockerfile
FROM ghcr.io/containercraft/devcontainer:latest

# Install additional tools or dependencies
# ...
```

Add the following `devcontainer.json` configuration to your project:

```json
{
  "name": "ContainerCraft Devcontainer",
  "dockerFile": "Dockerfile",
  "settings": {
    "terminal.integrated.defaultProfile.linux": "bash"
  },
  "extensions": [
    "ms-azuretools.vscode-docker",
    "ms-python.python",
    "golang.go"
  ],
  "remoteUser": "vscode",
  "postCreateCommand": "devcontainer-links",
  "forwardPorts": [8080, 1313],
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
  ],
  "runArgs": [
    "--init",
    "--privileged"
  ]
}
```

Clone your repository:

```bash
git clone https://github.com/your/repo.git
```

- **Requirements**:
  - [VSCode](https://code.visualstudio.com/) or [Cursor AI](https://cursor.dev/)
  - [Docker Desktop](https://www.docker.com/products/docker-desktop) or Docker CLI

### Neovim Development Environment

Use the Neovim-configured container for terminal-based development with advanced editing capabilities.

```bash
docker run -it --rm \
  --name neovim \
  --hostname neovim \
  --entrypoint bash \
  --workdir /workspace/project \
  -v "$(pwd):/workspace/project" \
  ghcr.io/containercraft/devcontainer:nvim
```

- **Features**:
  - Pre-configured Neovim with LazyVim setup.
  - LSP support for multiple languages.
  - Tmux integration for multiplexing.

### Remote Code-Server

Run VSCode in the browser using code-server for remote development.

```bash
docker run --rm -d \
  --name codeserver \
  --hostname codeserver \
  -p 8080:8080 \
  ghcr.io/containercraft/devcontainer:code
```

- **Access**: Open your browser and navigate to `http://localhost:8080`.
- **Features**:
  - Full VSCode experience in the browser.
  - Extensions pre-installed for cloud-native development.

### Terminal-Based Development

Access a fully-featured terminal environment with all tools installed, ideal for SSH or TTYD access.

```bash
docker run -it --rm \
  --name terminal \
  --hostname terminal \
  --entrypoint bash \
  ghcr.io/containercraft/devcontainer:slim
```

- **Features**:
  - Starship prompt with custom theme.
  - Tmux session management.
  - Shell utilities and aliases pre-configured.

### Local Docker Desktop / Docker CLI (on Linux)

Use the `dind` variant to run Docker-in-Docker for local development on Linux systems.

```bash
docker run --privileged --rm -d \
  --name dind \
  --hostname dind \
  ghcr.io/containercraft/devcontainer:dind
```

- **Features**:
  - Docker CLI and Buildx installed.
  - Ability to build and run Docker images within the container.

### Remote GitHub Codespaces via Remote Containers Extension

The images are compatible with GitHub Codespaces for remote development using the Remote Containers extension.

- **Requirements**:
  - [GitHub Codespaces](https://github.com/features/codespaces)
  - [Remote - Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Installed Tools

### Programming Languages

#### Python

- **Versions**: 3.x, 3.11
- **Tools**:
  - `pip`: Package installer.
  - `Poetry`: Dependency management and packaging.
  - `setuptools`: Library for building and distributing Python packages.

#### Node.js

- **Version**: 20.x
- **Tools**:
  - `npm`: Node package manager.
  - `yarn`: Alternative package manager.

#### Go

- **Version**: Latest stable (1.x)
- **Description**: Open-source programming language that makes it easy to build simple, reliable, and efficient software.

#### .NET

- **Version**: SDK 7.0
- **Description**: Free, cross-platform, open-source developer platform for building many different types of applications.

### Core Utilities

| Tool Name  | Version | Description                                | Link                                     |
|------------|---------|--------------------------------------------|------------------------------------------|
| `git`      | Latest  | Distributed version control system         | [Git](https://git-scm.com/)              |
| `gh`       | Latest  | GitHub CLI for interacting with GitHub     | [GitHub CLI](https://cli.github.com/)    |
| `jq`       | Latest  | Command-line JSON processor                | [jq](https://stedolan.github.io/jq/)     |
| `direnv`   | Latest  | Environment variable management            | [Direnv](https://direnv.net/)            |
| `starship` | Latest  | Fast, customizable shell prompt            | [Starship](https://starship.rs/)         |
| `tmux`     | Latest  | Terminal multiplexer                       | [tmux](https://github.com/tmux/tmux)     |
| `nix`      | Latest  | Package manager and build system           | [Nix](https://nixos.org/)                |
| `runme`    | Latest  | Execute commands directly from README.md   | [Runme](https://runme.dev/)              |
| `task`     | Latest  | Task runner and build tool                 | [Task](https://taskfile.dev/)            |
| `lazygit`  | Latest  | Simple terminal UI for git commands        | [lazygit](https://github.com/jesseduffield/lazygit)|

### Development Tools

| Tool Name     | Version | Description                                 | Link                                        |
|---------------|---------|---------------------------------------------|---------------------------------------------|
| `neovim`      | Latest  | Vim-based text editor with extended features| [Neovim](https://neovim.io/)                |
| `LazyVim`     | Latest  | Neovim configuration framework              | [LazyVim](https://www.lazyvim.org/)         |
| `code-server` | Latest  | Run VSCode in the browser                   | [code-server](https://coder.com/)           |
| `ttyd`        | Latest  | Share terminal over the web                 | [ttyd](https://tsl0922.github.io/ttyd/)     |

### Cloud Native Tools

| Tool Name    | Version | Description                            | Link                                      |
|--------------|---------|----------------------------------------|-------------------------------------------|
| `kubectl`    | Latest  | Kubernetes command-line tool           | [kubectl](https://kubernetes.io/docs/tasks/tools/) |
| `k9s`        | Latest  | Terminal UI for Kubernetes clusters    | [k9s](https://k9scli.io/)                 |
| `helm`       | Latest  | Kubernetes package manager             | [Helm](https://helm.sh/)                  |
| `kubectx`    | Latest  | Switch between clusters                | [kubectx](https://github.com/ahmetb/kubectx)|
| `kubens`     | Latest  | Switch between namespaces              | [kubens](https://github.com/ahmetb/kubectx)|
| `krew`       | Latest  | Package manager for kubectl plugins    | [krew](https://krew.sigs.k8s.io/)         |
| `Pulumi`     | Latest  | Infrastructure as Code SDK             | [Pulumi](https://www.pulumi.com/)         |
| `pulumictl`  | Latest  | Pulumi control utility                 | [pulumictl](https://github.com/pulumi/pulumictl)|
| `esc`        | Latest  | Pulumi environment service CLI         | [esc](https://github.com/pulumi/esc)      |
| `kind`       | Latest  | Run local Kubernetes clusters          | [kind](https://kind.sigs.k8s.io/)         |
| `cilium`     | Latest  | CLI for installing and managing Cilium | [Cilium](https://cilium.io/)              |
| `istioctl`   | Latest  | Istio service mesh CLI                 | [Istioctl](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/)|
| `clusterctl` | Latest  | Kubernetes Cluster API CLI             | [Cluster API](https://cluster-api.sigs.k8s.io/)|
| `talosctl`   | Latest  | CLI tool for managing Talos clusters   | [Talos](https://www.talos.dev/)           |

## Configuration and Environment

### Environment Variables

- `DEVCONTAINER`: Indicates the current devcontainer variant.
- `PATH`: Includes common binary directories and language-specific paths.
- `NIX_INSTALLER_EXTRA_CONF`: Nix configuration for system builds.
- `REGISTRY_AUTH_FILE`: Path to Docker registry authentication.
- `BIN`: Default binary installation directory (`/usr/local/bin`).
- `INSTALL`: Default binary install command (`install -m 755 -o root -g root`).
- `STARSHIP_CONTAINER`: Container name for Starship prompt.

### User and Permission Model

- **Users**:
  - `vscode` (UID 1000): Primary user with sudo privileges.
  - `runner` (UID 1001): Secondary user for GitHub Actions compatibility.
- **Groups**:
  - `sudo`: For administrative privileges.
  - `docker`: For Docker access.
- **Permissions**:
  - Password-less sudo for `vscode` and `runner`.
  - Proper file permissions set for home directories and configuration files.

### Volume Mounts and Ports

- **Workspace Mount**:
  - Mount your code into the container using `-v "$(pwd):/workspace"`.
- **Exposed Ports**:
  - `8080`: Exposed for code-server (VSCode in browser).
  - `1313`: Exposed for Hugo server (in `hugo` variant).
- **Docker-in-Docker**:
  - Requires `--privileged` flag to run Docker inside the container.

### Shell Customizations

- **Starship Prompt**:
  - Configured with a custom theme and displays the container name.
- **Tmux**:
  - Pre-configured with plugins and custom settings.
  - Session management and automatic start scripts.
- **Neovim**:
  - Configured with LazyVim, LSP support, and essential plugins.
  - Custom key mappings and settings.

## Usage

### Quick Start Guides

#### Running the Slim Variant

```bash
docker run -it --rm \
  --name devcontainer \
  --hostname devcontainer \
  --entrypoint bash \
  ghcr.io/containercraft/devcontainer:slim
```

#### Accessing Neovim

```bash
docker run -it --rm \
  --name neovim \
  --hostname neovim \
  --entrypoint bash \
  -v "$(pwd):/workspace" \
  ghcr.io/containercraft/devcontainer:nvim
```

#### Using Docker-in-Docker

```bash
docker run --privileged --rm -d \
  --name dind \
  --hostname dind \
  ghcr.io/containercraft/devcontainer:dind
```

### Volume and Network Configuration

- **Mounting Code**:
  - Use `-v "$(pwd):/workspace"` to mount your current directory into the container.
- **Persisting Data**:
  - Use Docker volumes to persist data across container restarts.
  - Example: `-v mydata:/path/in/container`
- **Network Ports**:
  - Map container ports to host ports using the `-p` flag.
  - Example: `-p 8080:8080` maps container port 8080 to host port 8080.

## Technical Specifications

### Container Configuration

- **Base Images**:
  - Based on official Ubuntu images and Microsoft's devcontainers.
- **User Space**:
  - Users `vscode` and `runner` with proper UID and GID.
  - Home directories set up with necessary configurations.
- **Directory Structure**:
  - `/home/vscode`: Home directory for primary user.
  - `/workspace`: Default working directory (when mounted).
  - `/usr/local/bin`: Default directory for installed binaries.

### Tool Chain Details

- **Updates**:
  - Tools are installed using the latest stable releases from official sources.
  - Regular updates are made to keep the toolchain current.
- **Compatibility**:
  - Configured to work seamlessly with common development tools and workflows.
  - Supports integration with VSCode extensions and Neovim plugins.
- **Default Configurations**:
  - Pre-set configurations for tools like Neovim, tmux, and Starship.
  - Environment variables and shell aliases for improved productivity.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the [Adaptive Public License Version 1.0](LICENSE).
