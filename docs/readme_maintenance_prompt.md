**README.md Documentation Update Requirements & Instructions**

---

### Purpose

Regenerate a comprehensive `README.md` by analyzing all current `README.md` content and reconciling it against all `Dockerfile` contents and auxiliary Docker image build artifacts. Carefully maintain the integrity and completeness of the `README.md` file by ensuring all relevant content is included and up-to-date.

### Core Documentation Requirements

1. **Image Variants**
   - Document all variants and their inheritance chain.
   - List supported architectures (`amd64`, `arm64`).
   - Detail base image specifications.

2. **Tools & Languages**
   - **List all installed tools with versions**:
     - Provide tables for CLI tools, including:
       - Tool Name
       - Version
       - Description
       - Link to official website or repository.
   - **Document language support and versions**.

3. **Configuration & Environment**
   - Document environment variables.
   - Detail user and permission models.
   - Explain volume mounts and ports.
   - Describe shell customizations.

### Feature Documentation

1. **Development Modes**
   - VSCode/Cursor AI integration.
   - Neovim configuration & usage.
   - Remote hosted Code-Server variant.
   - Terminal-based development.
   - Local Docker Desktop / Docker CLI (on Linux).
   - Remote GitHub Codespaces via Remote Containers extension.

2. **Language Support**
   - Python ecosystem.
   - Node.js environment.
   - Go toolchain.
   - .NET framework.

3. **Kubernetes & Cloud Native Tooling**
   - `kubectl` and plugins.
   - Helm CLI.
   - `k9s` interface.
   - Cloud provider CLI tools.
   - Support for adding custom layers via `.devcontainer/Dockerfile` on a per-project basis.

### Usage Documentation

1. **Quick Start Guides**
   - Basic usage examples.
   - Common operations.
   - Configuration examples.
   - Troubleshooting tips.

2. **Volume & Network**
   - Volume mounting strategies.
   - Relevant service by port usage examples.
   - Devcontainer mode Docker-in-Docker support.

### Technical Specifications

1. **Container Configuration**
   - User space setup.
   - Directory structure.

2. **Tool Chain Details**
   - Update procedures.
   - Compatibility notes.
   - Default configurations.

### Documentation Format

1. **Structure**
   - Use clear markdown formatting.
   - Hierarchical organization with headings and subheadings.
   - **Use tables where effective** (e.g., listing CLI tools with versions and descriptions).
   - Include code block examples.
   - Always character escape nested codeblocks with a backslash like so `\````, to remediate chat interface rendering issues. Only the first and last codeblock delimiters are written without the character escaping backslash.

2. **Content Focus**
   - Prioritize end-user value.
   - Cater to professional practitioners.
   - Include quick-start sections.
   - Highlight common use cases.

3. **Enhancements**
   - Use markdown-formatted inline reference hyperlinks.
   - Improve the ordering of sections for better flow.
   - Enhance readability with lists, tables, and formatting.

### Key Tools Documentation

#### Core Utilities

Provide a table listing core utilities with the following columns:

- **Tool Name**
- **Version**
- **Description**
- **Link**

Example:

| Tool Name | Version | Description                                | Link                                     |
|-----------|---------|--------------------------------------------|------------------------------------------|
| `jq`      | Latest  | Command-line JSON processor                | [jq](https://stedolan.github.io/jq/)     |
| `direnv`  | Latest  | Environment variable management            | [direnv](https://direnv.net/)            |
| `starship`| Latest  | Fast, customizable shell prompt            | [Starship](https://starship.rs/)         |
| `git`     | Latest  | Distributed version control system         | [Git](https://git-scm.com/)              |
| `Runme`   | Latest  | Execute commands directly from README.md   | [Runme](https://runme.dev/)              |
| `task`    | Latest  | Task runner and build tool                 | [Task](https://taskfile.dev/)            |
| `kubecolor`| Latest | Colorized `kubectl` output                 | [Kubecolor](https://github.com/hidetatz/kubecolor)|

#### Development Tools

List and describe development tools in a similar table.

#### Shell Tools

List and describe shell tools, focusing on Bash and other relevant shells.

#### Cloud Native Tools

Provide a table for cloud-native tools:

| Tool Name | Version | Description                            | Link                                      |
|-----------|---------|----------------------------------------|-------------------------------------------|
| `kubectl` | Latest  | Kubernetes command-line tool           | [kubectl](https://kubernetes.io/docs/tasks/tools/) |
| `helm`    | Latest  | Kubernetes package manager             | [Helm](https://helm.sh/)                  |
| `k9s`     | Latest  | Terminal UI for Kubernetes clusters    | [k9s](https://k9scli.io/)                 |
| `Pulumi`  | Latest  | Infrastructure as Code SDK             | [Pulumi](https://www.pulumi.com/)         |
| ...       | ...     | ...                                    | ...                                       |

### Quality Requirements

1. **Content Quality**
   - Ensure the `README.md` is comprehensive yet clear.
   - Maintain a well-organized structure.
   - Focus on the needs of practitioners.
   - Keep information current and accurate.

2. **Technical Accuracy**
   - Validate all commands and examples.
   - Note that the devcontainer meets all prerequisites except:
     - VSCode
     - Cursor.dev
     - Docker Desktop / Docker CLI
     - Web Browser

3. **Usability**
   - Make the document easy to navigate.
   - Facilitate quick referencing.
   - Provide clear examples.
   - Include troubleshooting guides.
   - Add a Table of Contents.

4. **SEO Optimization**
   - Use clear and descriptive headings.
   - Include relevant keywords.
   - Apply proper formatting.
   - Use internal linking where appropriate.

### Relevant Reference Files for Context

- `docker/*`

### Output Requirements

Generate a top-level `./README.md` that is:

1. Comprehensive but not overwhelming.
2. Well-organized and scannable.
3. Focused on practitioner value.
4. Up-to-date with current capabilities.
5. Clear about supported features.
6. Explicit about requirements.
7. Rich with correctly written examples that account for overriding the default entrypoint when manually running the container.
8. SEO-friendly for developer discovery.
9. Is nested within normal codeblocks, and the first and last codeblock delimiters are written without the character escaping backslash.
10. Uses markdown rendering safe backslashes to escape nested codeblocks like so '\```' to remediate chat interface rendering issues (Accomodated via find/replace in final draft)
