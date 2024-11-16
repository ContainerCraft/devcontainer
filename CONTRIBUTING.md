# Contributing to ContainerCraft Devcontainer

We appreciate your interest in contributing to the ContainerCraft Devcontainer project! Your contributions help improve the project for everyone. This document outlines the guidelines for contributing to the project.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setting Up the Development Environment](#setting-up-the-development-environment)
- [How to Contribute](#how-to-contribute)
  - [Reporting Issues](#reporting-issues)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Submitting Pull Requests](#submitting-pull-requests)
- [Coding Standards](#coding-standards)
  - [Commit Messages](#commit-messages)
  - [Code Style](#code-style)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

---

## Getting Started

### Prerequisites

- **Docker**: Ensure you have [Docker](https://www.docker.com/get-started) installed on your machine.
- **Git**: Install [Git](https://git-scm.com/downloads) for version control.
- **VSCode (Optional)**: For development with Visual Studio Code, install [VSCode](https://code.visualstudio.com/).

### Setting Up the Development Environment

1. **Fork the Repository**: Click on the "Fork" button on the project's GitHub page to create a copy in your GitHub account.

2. **Clone the Repository**:

   ```bash
   git clone https://github.com/your-username/devcontainer.git
   cd devcontainer
   ```

3. **Build the Docker Image**:

   ```bash
   docker build -t devcontainer:local -f docker/slim/Dockerfile ./docker
   ```

4. **Run the Container**:

   ```bash
   docker run -it --rm \
     --name devcontainer \
     --hostname devcontainer \
     --entrypoint bash \
     devcontainer:local
   ```

## How to Contribute

### Reporting Issues

If you encounter any bugs or have suggestions for improvements, please open an issue on GitHub:

- Navigate to the [Issues](https://github.com/containercraft/devcontainer/issues) tab.
- Click on **New Issue**.
- Provide a clear and descriptive title.
- Include steps to reproduce the issue, if applicable.

### Suggesting Enhancements

We welcome feature requests and ideas to improve the project:

- Open an issue with the label `enhancement`.
- Describe the feature, its benefits, and any implementation ideas.

### Submitting Pull Requests

1. **Create a Branch**:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**: Implement your changes, adhering to the coding standards outlined below.

3. **Commit Changes**:

   ```bash
   git add .
   git commit -m "feat: description of the feature"
   ```

4. **Push to Your Fork**:

   ```bash
   git push origin feature/your-username/your-feature-name
   ```

5. **Open a Pull Request**:

   - Go to the original repository on GitHub.
   - Click on **Pull Requests** and then **New Pull Request**.
   - Select your branch and submit the pull request.

## Coding Standards

### Commit Messages

- Use clear and descriptive commit messages.
- Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

  Examples:

  - `feat: add support for Python 3.9`
  - `fix: resolve issue with Docker build on arm64`
  - `docs: update README with new usage instructions`

### Code Style

- **Dockerfiles**: Follow best practices for writing Dockerfiles.
  - Use multi-stage builds where appropriate.
  - Minimize the number of layers.
  - Clear cache and temporary files to reduce image size.
- **Shell Scripts**:
  - Use `#!/bin/bash` shebang.
  - Ensure scripts are executable (`chmod +x script.sh`).
  - Handle errors gracefully and use `set -e` where appropriate.

## Code of Conduct

We are committed to fostering a welcoming and respectful community. Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before participating.

## License

By contributing to the ContainerCraft Devcontainer project, you agree that your contributions will be licensed under the [Adaptive Public License Version 1.0](LICENSE).
