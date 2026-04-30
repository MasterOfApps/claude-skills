#!/usr/bin/env bash
# Spec-Driven Dev with Claude - macOS Installer
# Installs project-wizard and project-update skills into ~/.claude/skills/.
# Auto-installs uv (needed by /project-wizard) and Claude Code CLI if missing.
# No git required.
#
# Usage (Terminal on macOS):
#   curl -fsSL https://raw.githubusercontent.com/MasterOfApps/claude-skills/main/spec-driven-dev-with-claude-mac.sh | bash

set -euo pipefail

REPO_RAW_URL='https://raw.githubusercontent.com/MasterOfApps/claude-skills/main'
SKILLS_DIR="${HOME}/.claude/skills"
SKILLS=(project-wizard project-update)

# --- Colors (best-effort; fall back to plain text if not a TTY) ---------------
if [ -t 1 ]; then
    C_CYAN=$'\033[36m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'; C_GRAY=$'\033[90m'; C_RESET=$'\033[0m'
else
    C_CYAN=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_GRAY=''; C_RESET=''
fi

section() { printf '\n%s=== %s ===%s\n' "$C_CYAN" "$1" "$C_RESET"; }
ok()      { printf '  %s[OK]%s   %s\n' "$C_GREEN"  "$C_RESET" "$1"; }
skip()    { printf '  %s[SKIP]%s %s\n' "$C_GRAY"   "$C_RESET" "$1"; }
warn()    { printf '  %s[WARN]%s %s\n' "$C_YELLOW" "$C_RESET" "$1"; }
fail()    { printf '  %s[FAIL]%s %s\n' "$C_RED"    "$C_RESET" "$1"; }

have() { command -v "$1" >/dev/null 2>&1; }

section 'Spec-Driven Dev with Claude - macOS Installer'
printf '%sCreated by Johan Olofsson - Noisy Cricket%s\n' "$C_GRAY" "$C_RESET"
echo
echo 'About to install / update the following on this machine:'
echo '  - uv             (only if not already installed)'
echo '  - Claude Code    (only if not already installed)'
echo '  - project-wizard skill   (always refreshed to latest)'
echo '  - project-update skill   (always refreshed to latest)'
echo
echo "Source : ${REPO_RAW_URL}"
echo "Target : ${SKILLS_DIR}"
echo
echo 'Safe to re-run: tools are only installed if missing. Skills are always refreshed to the latest version.'
echo

# When piped (curl ... | bash) stdin is the script itself; read from /dev/tty so the prompt is interactive.
if [ -e /dev/tty ]; then
    printf 'Continue? (y/N) '
    read -r confirm < /dev/tty
else
    printf 'Continue? (y/N) '
    read -r confirm
fi
case "${confirm}" in
    y|Y|yes|Yes|YES) ;;
    *)
        echo
        printf '%sCancelled. No changes were made.%s\n' "$C_YELLOW" "$C_RESET"
        exit 0
        ;;
esac

# --- Step 1: Ensure target directory exists -----------------------------------
section 'Step 1 / 5 - Prepare Claude config directory'
if [ ! -d "${SKILLS_DIR}" ]; then
    mkdir -p "${SKILLS_DIR}"
    ok "Created ${SKILLS_DIR}"
else
    ok "Found ${SKILLS_DIR}"
fi

# --- Step 2: Ensure uv is installed -------------------------------------------
section 'Step 2 / 5 - Check / install uv'
if have uv; then
    ok 'uv already installed'
else
    echo '  uv not found - installing it now (needed by /project-wizard for speckit)...'
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        # uv installs into ~/.local/bin or ~/.cargo/bin — make it reachable in this session
        export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"
        if have uv; then
            ok 'uv installed and available'
        else
            warn 'uv installed but not yet on PATH - open a new terminal, then re-run this installer.'
        fi
    else
        fail 'Could not install uv automatically'
        echo '  Install it manually with:'
        echo '    curl -LsSf https://astral.sh/uv/install.sh | sh'
    fi
fi

# --- Step 3: Download skills --------------------------------------------------
section 'Step 3 / 5 - Download / refresh skills from GitHub'
synced=0
for skill in "${SKILLS[@]}"; do
    skill_dir="${SKILLS_DIR}/${skill}"
    skill_file="${skill_dir}/SKILL.md"
    source_url="${REPO_RAW_URL}/${skill}/SKILL.md"
    action='installed'
    [ -f "${skill_file}" ] && action='updated'

    mkdir -p "${skill_dir}"
    if curl -fsSL "${source_url}" -o "${skill_file}"; then
        ok "${skill} ${action} -> ${skill_file}"
        synced=$((synced + 1))
    else
        fail "${skill} - could not download from ${source_url}"
    fi
done

if [ "${synced}" -eq 0 ]; then
    echo
    fail 'No skills were synced. Check your internet connection and try again.'
    exit 1
fi

# --- Step 4: Check / install Claude Code --------------------------------------
section 'Step 4 / 5 - Check / install Claude Code'
if have claude; then
    ok 'Claude Code CLI (claude) already installed'
else
    echo '  Claude Code CLI not found - installing it now...'
    if curl -fsSL https://claude.ai/install.sh | bash; then
        # Claude Code installs into ~/.local/bin — make it reachable in this session
        export PATH="${HOME}/.local/bin:${PATH}"
        if have claude; then
            ok 'Claude Code installed and available'
        else
            warn 'Claude Code installed but not yet on PATH - open a new terminal, then type "claude" to start.'
        fi
    else
        fail 'Could not install Claude Code automatically'
        echo '  Install it manually with:'
        echo '    curl -fsSL https://claude.ai/install.sh | bash'
        echo '  Or download from: https://claude.com/claude-code'
    fi
fi

# --- Step 5: Done -------------------------------------------------------------
section 'Step 5 / 5 - Done'
echo
printf '%sSynced %d skill(s) (latest version from GitHub):%s\n' "$C_GREEN" "$synced" "$C_RESET"
for skill in "${SKILLS[@]}"; do
    if [ -f "${SKILLS_DIR}/${skill}/SKILL.md" ]; then
        printf '  %s- /%s%s\n' "$C_GREEN" "$skill" "$C_RESET"
    fi
done

echo
printf '%sNext steps:%s\n' "$C_CYAN" "$C_RESET"
echo '  1. cd into the folder where you keep your project screenshots / notes'
echo '  2. Start Claude Code:        claude'
echo '  3. Run the wizard:           /project-wizard'
echo '     (or, if you already have a project: /project-update)'
echo
printf '%sHappy building!%s\n' "$C_CYAN" "$C_RESET"
