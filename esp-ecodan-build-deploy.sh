#!/usr/bin/env bash
set -euo pipefail

# Config — adjust if needed
UPSTREAM_REMOTE_URL="https://github.com/gekkekoe/esphome-ecodan-hp.git"
PYTHON_BIN="python3"
VENV_DIR="venv"
YAML_FILE="ecodan-esphome.yaml"
#ESPHOME_DEVICE_IP=""   # Using environment variable echos 'export ESPHOME_DEVICE_IP=192.168.x.x' >> ~/.bashrc
PIP_OPTS="--upgrade"

# Helper output
info(){ printf "\n[INFO] %s\n" "$1"; }
err(){ printf "\n[ERROR] %s\n" "$1" >&2; }

# 1) Ensure running in a git repo
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  err "This script must be run inside a git repository."
  exit 2
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# 2) Add upstream remote if missing, fetch, and merge upstream/main into local main
if git remote get-url upstream >/dev/null 2>&1; then
  info "Upstream remote already exists. Updating URL to configured upstream."
  git remote set-url upstream "$UPSTREAM_REMOTE_URL"
else
  info "Adding upstream remote."
  git remote add upstream "$UPSTREAM_REMOTE_URL"
fi

info "Fetching from upstream..."
git fetch upstream

# Ensure local main branch exists; create from current HEAD if not
if git show-ref --verify --quiet refs/heads/main; then
  info "Checking out local main branch."
  git checkout main
else
  info "Local main branch doesn't exist — creating from current branch as 'main'."
  git checkout -b main
fi

info "Merging upstream/main into local main..."
# Prefer a normal merge so conflicts appear for manual resolution
if git merge --no-edit upstream/main; then
  info "Merge completed successfully."
else
  err "Merge reported conflicts. Please resolve conflicts, then run 'git add' and 'git commit'."
  err "After resolving, re-run this script to continue."
  exit 3
fi

# 3) Ensure we're running in bash (for users running other shells)
if [ -z "${BASH_VERSION:-}" ]; then
  if command -v bash >/dev/null 2>&1; then
    info "Switching to bash for the remainder of the script..."
    exec bash "$0" "$@"
  else
    err "Bash not found. Please run this script using bash."
    exit 4
  fi
fi

# 4) Create/activate python venv and install/update deps
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  err "Python ($PYTHON_BIN) not found in PATH."
  exit 5
fi

info "Creating virtual environment (if missing) at ./$VENV_DIR ..."
$PYTHON_BIN -m venv "$VENV_DIR"

info "Activating virtual environment..."
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

info "Upgrading pip"
python -m pip install $PIP_OPTS pip

info "Installing/updating wheel and esphome"
python -m pip install $PIP_OPTS wheel
python -m pip install $PIP_OPTS esphome

# 5) Build firmware
if [ ! -f "$YAML_FILE" ]; then
  err "YAML file '$YAML_FILE' not found in repository root."
  exit 6
fi

info "Compiling firmware from $YAML_FILE ..."
esphome compile "$YAML_FILE"

info "Build finished."

# 6) Upload if device IP is provided
if [ -n "${ESPHOME_DEVICE_IP}" ]; then
  info "Uploading firmware to device at $ESPHOME_DEVICE_IP ..."
  esphome upload --device "$ESPHOME_DEVICE_IP" "$YAML_FILE"
  info "Upload finished."
else
  info "No ESPHome device IP set in script (ESPHOME_DEVICE_IP). Skipping upload step."
  info "To upload automatically, set ESPHOME_DEVICE_IP variable near top of script."
fi

info "Done. Secrets are expected in secrets.yaml and should not be committed."
