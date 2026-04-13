# Claude Skills

Shared Claude Code skills for Johan & David.

## Install skills

```bash
git clone https://github.com/MasterOfApps/claude-skills.git
cd claude-skills
bash install.sh
```

## Update skills

```bash
cd claude-skills
git pull
bash install.sh
```

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| project-wizard | `/project-wizard` | Project inception wizard — installs speckit, syncs config from template repo, then runs 50 questions across 9 categories. Creates CLAUDE.md, constitution, design system, and project brief. |
| project-update | `/project-update` | Update speckit and sync Claude Code configuration from the template repo. For existing projects that need the latest rules, docs, agents, skills, and hooks. |

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- [uv](https://docs.astral.sh/uv/) installed (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- Works on macOS and Linux

---

## New Project — Complete Setup Guide

When starting a brand new project, follow these steps in order.

### Step 1: Install skills (one-time)

If you haven't already:

```bash
git clone https://github.com/MasterOfApps/claude-skills.git
cd claude-skills
bash install.sh
cd ..
```

### Step 2: Create the project directory

```bash
mkdir my-new-project
cd my-new-project
```

### Step 3: Run the project wizard

Start Claude Code and run the wizard:

```bash
claude
```

```
/project-wizard An issue tracking system for municipalities
```

The wizard automatically handles everything:

1. **Installs/updates speckit** — `uv tool install specify-cli` + `specify init`
2. **Syncs Claude Code config** — fetches the latest sync-prompt from [johanolofsson72/Claude](https://github.com/johanolofsson72/Claude) and applies it (rules, docs, agents, skills, hooks, settings)
3. **Preserves constitution** — backs up before speckit init, restores after
4. **Asks about tech stack** — removes irrelevant files
5. **Runs the interview** — 50 questions across 9 categories
6. **Generates foundation docs** — CLAUDE.md, constitution, design system, project brief

After this, every Claude session in the project knows the full context, and you can start writing feature specs with `/speckit-specify`.

### Updating an existing project

To sync an existing project with the latest config (without re-running the interview):

```
/project-update
```

Options:
- `/project-update` — full update (speckit + sync config)
- `/project-update speckit-only` — only update speckit CLI and templates
- `/project-update sync-only` — only sync Claude Code config from template repo

### Quick reference — the full sequence

```bash
# 1. Create project
mkdir my-project && cd my-project

# 2. Start Claude and run the wizard (handles everything)
claude
# /project-wizard An issue tracking system for municipalities

# 3. Start building
# /speckit-specify
```

### Quick reference — update existing project

```bash
cd my-project
claude
# /project-update
```

## Adding New Skills

1. Create a directory: `my-skill/SKILL.md`
2. Follow the [Agent Skills standard](https://agentskills.io)
3. Run `bash install.sh my-skill` to test
4. Commit and push
