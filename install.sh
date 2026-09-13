#!/usr/bin/env bash

set -euo pipefail

REPOSITORY=https://github.com/Reaan06/reaan-dots.git
DESTINATION=${IMPASTO_DIR:-$HOME/reaan-dots}

usage() {
    cat <<'EOF'
Usage: install.sh [options]

Install Impasto from this checkout, or clone it to ${IMPASTO_DIR:-$HOME/reaan-dots}
when this script is run from stdin.

Options are forwarded to `setup install`, including:
  --skip-packages   leave packages alone
  --skip-system     leave / alone
  --skip-plugins    do not build the plugins
  --noconfirm       answer every question with its default
  -n, --dry-run     say what would change, and change nothing
EOF
}

if (($# == 1)) && [[ $1 == '-h' || $1 == '--help' ]]; then
    usage
    exit 0
fi

repo=
script=${BASH_SOURCE[0]:-}
if [[ -f $script ]]; then
    script_dir=$(cd -- "$(dirname -- "$script")" && pwd)
    if repo=$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null) &&
        [[ $repo == "$script_dir" ]]; then
        :
    else
        repo=
    fi
fi

if [[ -z $repo ]]; then
    command -v git >/dev/null 2>&1 || {
        printf 'install.sh: git is required to bootstrap Impasto\n' >&2
        exit 1
    }

    if [[ -e $DESTINATION ]]; then
        checkout=$(git -C "$DESTINATION" rev-parse --show-toplevel 2>/dev/null || true)
        if [[ -z $checkout || $checkout != "$(cd -- "$DESTINATION" && pwd)" ]]; then
            printf 'install.sh: %s exists but is not a git checkout; choose another IMPASTO_DIR\n' \
                "$DESTINATION" >&2
            exit 1
        fi
        repo=$checkout
    else
        printf 'Cloning Impasto into %s\n' "$DESTINATION"
        git clone "$REPOSITORY" "$DESTINATION"
        repo=$(cd -- "$DESTINATION" && pwd)
    fi
fi

[[ -x $repo/setup ]] || {
    printf 'install.sh: setup was not found in %s\n' "$repo" >&2
    exit 1
}

exec "$repo/setup" install "$@"
