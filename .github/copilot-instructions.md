# Copilot Instructions — chezmoi dotfiles

## What this is

A [chezmoi](https://www.chezmoi.io/) managed dotfiles repository targeting macOS (primary) and Linux (Debian/Arch). It also supports GitHub Codespaces as an ephemeral environment. The owner is `hilli` (GitHub user).

## Testing changes

```sh
# Docker-based integration test (Ubuntu container, requires Docker running)
./test/test-chezmoi.sh

# Useful flags
./test/test-chezmoi.sh --diff      # diff only, no apply
./test/test-chezmoi.sh --shell     # apply then drop into zsh in the container
./test/test-chezmoi.sh --verbose   # pass --verbose to chezmoi
./test/test-chezmoi.sh --no-apply  # init only, skip apply

# Quick local validation (may fail on secrets/1Password)
chezmoi apply --dry-run
chezmoi diff
```

There is no linter or build step. The test script sets `CODESPACES=true` to bypass age encryption and 1Password dependencies.

## Architecture

### Template data model

`.chezmoi.yaml.tmpl` derives these template variables from hostname and environment:

| Variable      | Purpose                                    |
|---------------|--------------------------------------------|
| `.personal`   | Personal machine (vs work)                 |
| `.ephemeral`  | Throwaway environment (Codespaces)         |
| `.desktop`    | Desktop vs server role                     |
| `.codespaces` | Running in GitHub Codespaces               |
| `.hostname`   | Machine hostname (uses `scutil` on macOS)  |

These variables drive conditional logic throughout templates — package selection, encryption config, editor choice, and which files get ignored (`.chezmoiignore`).

### Key hostnames

`ultra1`, `maclap1`, `minim1`, `minim4` → personal. `nuc1` → personal Linux. Unrecognized hostnames default to non-personal, non-ephemeral.

### Secrets management

- **age encryption** for non-ephemeral environments (`age-key.txt.age` is the encrypted key)
- **1Password CLI** (`op`) for runtime secrets in templates via `onepasswordRead`
- Ephemeral/Codespaces environments skip encryption entirely

### External dependencies (`.chezmoiexternal.yaml`)

Oh-My-Zsh and plugins are pulled as archives, not git submodules. On Linux personal machines, `age` binaries are fetched from GitHub releases.

### Script execution order

chezmoi scripts in `.chezmoiscripts/` follow naming conventions for ordering:

- `run_once_before_*` — one-time setup (Xcode CLT → Homebrew → packages on macOS)
- `run_onchange_before_*` — re-run when source files change (Linux packages)
- `run_onchange_after_*` — post-apply configuration (macOS defaults)
- `run_once_*` — one-time tasks (change shell to zsh)

Platform-specific scripts live in `.chezmoiscripts/darwin/` and `.chezmoiscripts/linux/`.

### Package management

- **macOS**: Multiple Brewfiles — `Brewfile` (shared), `Brewfile.home`, `Brewfile.work`, `Brewfile-mas.*` (Mac App Store), `Brewfile.arm64.home`
- **Linux Debian**: `Aptfile` (one package per line)
- **Linux Arch**: `Pacmanfile`

Package install scripts use sha256sum hashes in comments to trigger re-runs when Brewfiles change.

## Conventions

### chezmoi file naming

Follow [chezmoi's naming conventions](https://www.chezmoi.io/reference/source-state-attributes/):
- `dot_` prefix → `.` in target (e.g., `dot_zshrc.tmpl` → `~/.zshrc`)
- `private_` prefix → 0600 permissions
- `executable_` prefix → 0755 permissions
- `.tmpl` suffix → Go template processing
- `run_once_before_`, `run_onchange_after_`, etc. for scripts

### Templates

Templates use Go's `text/template` syntax with chezmoi's extensions. Common patterns:
- `{{ if eq .chezmoi.os "darwin" }}` for OS-specific blocks
- `{{ if .personal }}` for personal-machine-only content
- `{{ onepasswordRead "op://vault/item/field" }}` for 1Password secrets
- `{{ include "filename" | sha256sum }}` in script comments to trigger re-runs

### Shell configuration structure

The zsh setup sources files in this order: `.zshrc` → `.env.sh` → `.aliases.sh` → `.config.sh` (and `.codespaces.sh` if in Codespaces). Keep this separation when adding new shell configuration.

## MCP tools

Use the `mise` MCP tool to find and temporarily install CLI tools when needed.

## Progress updates

Send progress updates to Discord using the `discord-agent-comm` MCP tool (`discord_message`) at key milestones (starting, completing, errors, questions).
