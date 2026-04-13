#!/usr/bin/env bash
# Claude Skills — Master Installer
# Installs all skills from this repo into ~/.claude/skills/
#
# Usage:
#   bash install.sh              # Install all skills
#   bash install.sh project-wizard  # Install one specific skill

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"

mkdir -p "${SKILLS_DIR}"

install_skill() {
    local skill_name="$1"
    local src="${REPO_DIR}/${skill_name}"
    local dest="${SKILLS_DIR}/${skill_name}"

    if [ ! -f "${src}/SKILL.md" ]; then
        echo "  SKIP  ${skill_name} (no SKILL.md found)"
        return
    fi

    if [ -d "${dest}" ]; then
        rm -rf "${dest}"
    fi

    cp -r "${src}" "${dest}"
    echo "  OK    ${skill_name} → ${dest}"
}

echo "=== Claude Skills Installer ==="
echo "Source: ${REPO_DIR}"
echo "Target: ${SKILLS_DIR}"
echo ""

if [ $# -gt 0 ]; then
    # Install specific skill(s)
    for skill in "$@"; do
        if [ -d "${REPO_DIR}/${skill}" ]; then
            install_skill "${skill}"
        else
            echo "  ERROR ${skill} not found in ${REPO_DIR}"
        fi
    done
else
    # Install all skills (directories containing SKILL.md)
    count=0
    for skill_dir in "${REPO_DIR}"/*/; do
        skill_name="$(basename "${skill_dir}")"
        if [ -f "${skill_dir}/SKILL.md" ]; then
            install_skill "${skill_name}"
            ((count++))
        fi
    done
    echo ""
    echo "Installed ${count} skill(s)."
fi

echo ""
echo "Done. Start Claude Code and use /skill-name to invoke."
