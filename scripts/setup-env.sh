#!/usr/bin/env bash
#
# setup-env.sh — write Zettle build environment variables to your shell profile.
#
# Idempotent: re-running replaces the managed block instead of appending a
# duplicate. Prompts for each value; press Enter to keep the current one (shown
# in brackets) or accept the documented default.
#
# Usage:
#   ./scripts/setup-env.sh              # writes to the profile for your shell
#   PROFILE=~/.zshenv ./scripts/setup-env.sh   # override target file
#
set -euo pipefail

BEGIN_MARKER="# >>> zettle_flutter env >>>"
END_MARKER="# <<< zettle_flutter env <<<"

# Pick the profile file: explicit override, else per-shell default.
if [ -n "${PROFILE:-}" ]; then
  profile="$PROFILE"
elif [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = "zsh" ]; then
  profile="$HOME/.zshrc"
else
  profile="$HOME/.bashrc"
fi

# Read the currently-exported value so re-runs can offer it as the default.
current() { printf '%s' "${!1:-}"; }

# Shell-escape a value for safe embedding in the profile. printf %q emits a
# form that reproduces the exact literal when the profile is sourced, so spaces,
# metacharacters, or $(...) can never execute or mangle the file.
shell_quote() { printf '%q' "$1"; }

# prompt VAR "description" "fallback-default"
prompt() {
  local var="$1" desc="$2" fallback="$3" cur shown reply
  cur="$(current "$var")"
  shown="${cur:-$fallback}"
  printf '%s\n  [%s]: ' "$desc" "$shown" >&2
  read -r reply
  printf '%s' "${reply:-$shown}"
}

echo "Configuring Zettle build environment -> $profile"
echo

github_token="$(prompt GITHUB_TOKEN 'GitHub PAT with read:packages scope (Zettle Maven repo)' '')"
app_id="$(prompt ZETTLE_APP_ID 'Android applicationId' 'com.ovatu.zettle_example')"
redirect_scheme="$(prompt ZETTLE_REDIRECT_SCHEME 'OAuth redirect scheme (e.g. myapp)' 'your-scheme')"
redirect_host="$(prompt ZETTLE_REDIRECT_HOST 'OAuth redirect host (e.g. callback)' 'your-host')"

if [ -z "$github_token" ]; then
  echo "error: GITHUB_TOKEN is required (needs read:packages scope)." >&2
  exit 1
fi

block="$(cat <<EOF
$BEGIN_MARKER
export GITHUB_TOKEN=$(shell_quote "$github_token")
export ZETTLE_APP_ID=$(shell_quote "$app_id")
export ZETTLE_REDIRECT_SCHEME=$(shell_quote "$redirect_scheme")
export ZETTLE_REDIRECT_HOST=$(shell_quote "$redirect_host")
$END_MARKER
EOF
)"

touch "$profile"

if grep -qF "$BEGIN_MARKER" "$profile"; then
  # Replace existing managed block, preserving everything else.
  tmp="$(mktemp)"
  awk -v b="$BEGIN_MARKER" -v e="$END_MARKER" '
    $0 == b { skip = 1 }
    skip && $0 == e { skip = 0; next }
    !skip { print }
  ' "$profile" > "$tmp"
  printf '%s\n' "$block" >> "$tmp"
  mv "$tmp" "$profile"
  echo "Updated existing block in $profile"
else
  printf '\n%s\n' "$block" >> "$profile"
  echo "Appended block to $profile"
fi

echo
echo "Done. Apply now with:  source $profile"
