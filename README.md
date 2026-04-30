# Claude Skills

Shared Claude Code skills: `/project-wizard` and `/project-update`. One-line installer per platform — no git, no GitHub account needed. Re-run any time to refresh skills to the latest version; tools (`uv`, Claude Code) are only installed if missing.

## Install / Update

Pick the line for your operating system, paste it into a terminal, press Enter. Re-running performs an update.

### Windows 11

**First time on a Windows machine?** Follow the step-by-step guide in [START-HERE-WINDOWS.md](START-HERE-WINDOWS.md) — it assumes no prior knowledge.

Otherwise — open **PowerShell as administrator** and paste:

```powershell
irm https://raw.githubusercontent.com/MasterOfApps/claude-skills/main/spec-driven-dev-with-claude-windows.ps1 | iex
```

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/MasterOfApps/claude-skills/main/spec-driven-dev-with-claude-mac.sh | bash
```

### Linux

```bash
curl -fsSL https://raw.githubusercontent.com/MasterOfApps/claude-skills/main/spec-driven-dev-with-claude-linux.sh | bash
```

### What each script does

1. Creates `~/.claude/skills/` if missing.
2. Installs `uv` if missing (needed by `/project-wizard` for speckit).
3. Downloads / refreshes `project-wizard/SKILL.md` and `project-update/SKILL.md` from this repo.
4. Installs Claude Code CLI if missing.
5. Prints the next steps.

Re-running the same command updates the skills to the latest version and skips anything already installed.

## Available Skills

| Skill | Command | Description |
|---|---|---|
| project-wizard | `/project-wizard` | Project inception wizard — installs speckit, syncs config from template repo, then runs 50 questions across 9 categories. Creates `CLAUDE.md`, constitution, design system, and project brief. |
| project-update | `/project-update` | Update speckit and sync Claude Code configuration from the template repo. For existing projects that need the latest rules, docs, agents, skills, and hooks. |

## New project — full sequence

```bash
# 1. Create project folder (or cd into an existing one with screenshots / notes)
mkdir my-project && cd my-project

# 2. Start Claude Code
claude

# 3. Run the wizard (in the Claude prompt)
# /project-wizard An issue tracking system for municipalities

# 4. After the wizard finishes, start writing feature specs
# /speckit-specify
```

## Update an existing project

In the project's directory:

```bash
claude
# /project-update
```

Options:

- `/project-update` — full update (speckit + sync config)
- `/project-update speckit-only` — only update speckit CLI and templates
- `/project-update sync-only` — only sync Claude Code config from template repo

## Adding new skills to this repo

1. Create a directory at the repo root: `my-skill/SKILL.md`
2. Follow the [Agent Skills standard](https://agentskills.io)
3. Add the skill name to the `SKILLS` array in all three installers (`spec-driven-dev-with-claude-windows.ps1`, `spec-driven-dev-with-claude-mac.sh`, `spec-driven-dev-with-claude-linux.sh`)
4. Commit and push to `main` — the next time anyone runs the installer, the new skill is fetched automatically.
