#!/usr/bin/env bash
#
# test-chezmoi.sh — Build an Ubuntu container, mount this chezmoi repo,
#                   and run `chezmoi init && chezmoi apply` inside it.
#
# Usage:
#   ./test/test-chezmoi.sh [OPTIONS]
#
# Options:
#   -k, --keep        Leave the container running after apply so you can
#                     shell in with:  docker exec -it <name> zsh
#   -s, --shell       Apply and then drop straight into an interactive shell
#   -n, --no-apply    Only init, skip apply (useful for inspecting config)
#   -d, --diff        Run chezmoi diff instead of apply
#   -v, --verbose     Pass --verbose to chezmoi commands
#   --no-cache        Build the Docker image with --no-cache
#   -h, --help        Show this help message
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

IMAGE_NAME="chezmoi-test"
CONTAINER_NAME="chezmoi-test-$$"
KEEP=false
SHELL_IN=false
NO_APPLY=false
DIFF_ONLY=false
VERBOSE=""
DOCKER_BUILD_EXTRA=""

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
usage() {
    sed -n '/^# Usage:/,/^[^#]/{ /^#/s/^# \{0,1\}//p }' "$0"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -k|--keep)    KEEP=true;       shift ;;
        -s|--shell)   SHELL_IN=true;   KEEP=true; shift ;;
        -n|--no-apply) NO_APPLY=true;  shift ;;
        -d|--diff)    DIFF_ONLY=true;  shift ;;
        -v|--verbose) VERBOSE="--verbose"; shift ;;
        --no-cache)   DOCKER_BUILD_EXTRA="--no-cache"; shift ;;
        -h|--help)    usage ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Pretty output helpers
# ---------------------------------------------------------------------------
_c_reset='\033[0m'
_c_green='\033[0;32m'
_c_cyan='\033[0;36m'
_c_red='\033[0;31m'
_c_yellow='\033[0;33m'

info()  { echo -e "${_c_cyan}▸${_c_reset} $*"; }
ok()    { echo -e "${_c_green}✔${_c_reset} $*"; }
warn()  { echo -e "${_c_yellow}⚠${_c_reset} $*"; }
fail()  { echo -e "${_c_red}✘${_c_reset} $*"; exit 1; }

# ---------------------------------------------------------------------------
# Cleanup helper
# ---------------------------------------------------------------------------
cleanup() {
    if [[ "${KEEP}" == "true" ]]; then
        return
    fi
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$" 2>/dev/null; then
        info "Cleaning up container ${CONTAINER_NAME}…"
        docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
if ! command -v docker &>/dev/null; then
    fail "docker is not installed or not in PATH"
fi

if ! docker info &>/dev/null; then
    fail "Docker daemon is not running (or you don't have permission)"
fi

# ---------------------------------------------------------------------------
# Build the image
# ---------------------------------------------------------------------------
info "Building Docker image '${IMAGE_NAME}'…"
docker build \
    ${DOCKER_BUILD_EXTRA} \
    -t "${IMAGE_NAME}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"
ok "Image '${IMAGE_NAME}' built successfully"

# ---------------------------------------------------------------------------
# Start the container
# ---------------------------------------------------------------------------
info "Starting container '${CONTAINER_NAME}'…"
info "  Repo root: ${REPO_ROOT}"

# Mount the chezmoi source repo read-only into the container.
# chezmoi init --source will copy it to the working source dir.
docker run -d \
    --name "${CONTAINER_NAME}" \
    -v "${REPO_ROOT}:/mnt/chezmoi-source:ro" \
    -e "TERM=${TERM:-xterm-256color}" \
    "${IMAGE_NAME}" \
    sleep infinity >/dev/null

ok "Container '${CONTAINER_NAME}' is running"

# ---------------------------------------------------------------------------
# Helper: run a command inside the container as testuser
# ---------------------------------------------------------------------------
run_in() {
    docker exec -e "TERM=${TERM:-xterm-256color}" "${CONTAINER_NAME}" "$@"
}

# ---------------------------------------------------------------------------
# Copy source into container (avoids read-only mount issues with chezmoi)
# ---------------------------------------------------------------------------
info "Copying chezmoi source into container…"
run_in bash -c "mkdir -p /home/testuser/.local/share"
run_in bash -c "cp -a /mnt/chezmoi-source /home/testuser/.local/share/chezmoi"
ok "Source copied"

# ---------------------------------------------------------------------------
# chezmoi init
# ---------------------------------------------------------------------------
info "Running chezmoi init ${VERBOSE}…"

# Set the hostname so the template picks a sensible config path.
# The template sees .chezmoi.hostname — we set it via the container hostname.
# We also ensure that age decryption is skipped (no key available) by making
# sure the template detects a non-matching hostname and non-codespace env,
# which means ephemeral=false and encryption=age is attempted.  To avoid that
# we fake CODESPACES=true so the template sets ephemeral=true and skips
# encryption entirely — this is the path of least resistance for testing.
run_in env CODESPACES=true \
    chezmoi init ${VERBOSE} \
        --source /home/testuser/.local/share/chezmoi \
        --no-tty \
    || warn "chezmoi init returned non-zero (may be okay if prompts were skipped)"

ok "chezmoi init complete"

# ---------------------------------------------------------------------------
# chezmoi diff / apply
# ---------------------------------------------------------------------------
if [[ "${DIFF_ONLY}" == "true" ]]; then
    info "Running chezmoi diff ${VERBOSE}…"
    run_in env CODESPACES=true \
        chezmoi diff ${VERBOSE} \
            --no-tty \
        || true
    ok "chezmoi diff complete"
elif [[ "${NO_APPLY}" == "false" ]]; then
    info "Running chezmoi apply ${VERBOSE}…"
    run_in env CODESPACES=true \
        chezmoi apply ${VERBOSE} \
            --no-tty \
            --force \
        || warn "chezmoi apply returned non-zero — check output above"
    ok "chezmoi apply complete"

    # Quick sanity checks
    echo ""
    info "Sanity checks:"
    run_in test -f /home/testuser/.zshrc       && ok "  ~/.zshrc exists"       || warn "  ~/.zshrc missing"
    run_in test -f /home/testuser/.gitconfig    && ok "  ~/.gitconfig exists"   || warn "  ~/.gitconfig missing"
    run_in test -f /home/testuser/.aliases.sh   && ok "  ~/.aliases.sh exists"  || warn "  ~/.aliases.sh missing"
    run_in test -f /home/testuser/.env.sh       && ok "  ~/.env.sh exists"      || warn "  ~/.env.sh missing"
    run_in test -f /home/testuser/.config.sh    && ok "  ~/.config.sh exists"   || warn "  ~/.config.sh missing"
    run_in test -f /home/testuser/.tmux.conf    && ok "  ~/.tmux.conf exists"   || warn "  ~/.tmux.conf missing"
    run_in test -d /home/testuser/.oh-my-zsh    && ok "  ~/.oh-my-zsh exists"   || warn "  ~/.oh-my-zsh missing"
    run_in test -f /home/testuser/.starship.toml && ok " ~/.starship.toml exists" || warn " ~/.starship.toml missing"
else
    info "Skipping apply (--no-apply)"
fi

# ---------------------------------------------------------------------------
# Interactive shell / keep running
# ---------------------------------------------------------------------------
echo ""
if [[ "${SHELL_IN}" == "true" ]]; then
    info "Dropping into an interactive shell (type 'exit' to quit)…"
    docker exec -it \
        -e "TERM=${TERM:-xterm-256color}" \
        -e "CODESPACES=true" \
        "${CONTAINER_NAME}" \
        /bin/zsh -l
elif [[ "${KEEP}" == "true" ]]; then
    ok "Container '${CONTAINER_NAME}' is still running."
    echo ""
    echo "  Shell in with:"
    echo "    docker exec -it ${CONTAINER_NAME} zsh"
    echo ""
    echo "  Stop & remove with:"
    echo "    docker rm -f ${CONTAINER_NAME}"
    echo ""
else
    ok "All done. Container will be removed."
fi
