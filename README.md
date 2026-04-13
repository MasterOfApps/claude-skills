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
| project-wizard | `/project-wizard` | Project inception wizard — 50 questions across 9 categories. Creates CLAUDE.md, constitution, design system, and project brief. |

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

### Step 3: Install speckit

This sets up the `.specify/` directory structure with templates, scripts, and integrations:

```bash
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
specify init --here --force --ai claude
```

### Step 4: Sync Claude Code configuration

Start Claude Code in the project directory:

```bash
claude
```

Then paste the contents of the **sync-prompt** into the Claude session. The sync-prompt lives in the Claude template repo:

```
/Users/jool/repos/Claude/scripts/sync-prompt.md
```

Copy everything between the `---` markers and paste it into the Claude session. This will:

- Create `CLAUDE.md` with critical rules, execution mode, workflow, verification
- Set up `.claude/rules/` (dotnet, frontend, security, specs, tests, allium)
- Set up `.claude/docs/` (testing, conventions, security, git, deployment, etc.)
- Set up `.claude/agents/` (dotnet-reviewer, security-scanner, test-runner, db-agent)
- Set up `.claude/skills/` (code-review, explore-codebase, tla, allium, deploy-checklist)
- Set up `.claude/settings.json` with hooks
- Install external skills (anthropics/skills, superpowers, trailofbits, qa-test, dotnet, vercel, playwright)
- Ask which tech stack you're using and remove irrelevant files

**Important:** The sync will ask about your tech stack — answer based on what the project will use.

### Step 5: Preserve the constitution

Speckit created a default constitution during `specify init`. The sync may have touched it. If you want to keep speckit's scaffolding and let the wizard write the real constitution:

```bash
# No action needed — the wizard overwrites .specify/memory/constitution.md with your real principles
```

If speckit was already initialized with content you want to keep, back it up before running the wizard:

```bash
cp .specify/memory/constitution.md .specify/memory/constitution-backup.md
```

### Step 6: Run the project wizard

Now you have the full Claude Code infrastructure in place. Run the wizard to define your project:

```
/project-wizard
```

Or with a pitch:

```
/project-wizard An issue tracking system for municipalities
```

The wizard will:
1. Read all the files that were just set up (CLAUDE.md, rules, docs, settings)
2. Ask ~50 questions across 9 categories
3. Generate/update:
   - `CLAUDE.md` — project-specific section
   - `.specify/memory/constitution.md` — core principles
   - `design-system/MASTER.md` — visual identity
   - `PROJECT-BRIEF.md` — stakeholder description

After this, every Claude session in the project knows the full context, and you can start writing feature specs with `/speckit-specify`.

### Quick reference — the full sequence

```bash
# 1. Create project
mkdir my-project && cd my-project

# 2. Install speckit
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
specify init --here --force --ai claude

# 3. Start Claude and sync config
claude
# → Paste sync-prompt from /Users/jool/repos/Claude/scripts/sync-prompt.md

# 4. Run the wizard (in the same or new Claude session)
# /project-wizard An issue tracking system for municipalities

# 5. Start building
# /speckit-specify
```

## Adding New Skills

1. Create a directory: `my-skill/SKILL.md`
2. Follow the [Agent Skills standard](https://agentskills.io)
3. Run `bash install.sh my-skill` to test
4. Commit and push
