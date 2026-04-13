# Claude Skills

Shared Claude Code skills for Johan & David.

## Install

```bash
git clone git@github.com:MasterOfApps/claude-skills.git
cd claude-skills
bash install.sh
```

To install a single skill:

```bash
bash install.sh project-wizard
```

## Update

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
- Works on macOS and Linux

## Adding New Skills

1. Create a directory: `my-skill/SKILL.md`
2. Follow the [Agent Skills standard](https://agentskills.io)
3. Run `bash install.sh my-skill` to test
4. Commit and push
