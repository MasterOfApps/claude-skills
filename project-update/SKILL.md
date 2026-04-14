---
name: project-update
description: "Update speckit and sync Claude Code configuration from the template repo. Use on existing projects to pull the latest rules, docs, agents, skills, hooks, and settings. Trigger words: update project, sync config, update claude config, sync rules, update speckit, refresh project."
argument-hint: "[optional: 'speckit-only', 'sync-only', or '--force' to ignore .sync-version cache]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, Glob, Grep
---

# Project Update

You are updating an existing project's speckit installation and Claude Code configuration to the latest version from the template repo.

This skill does NOT run the project wizard interview. It only syncs infrastructure and tooling.

## Input

```text
$ARGUMENTS
```

## Process

### Step 1: Verify prerequisites

Check that the required tools are available:

```bash
command -v uv && echo "[OK] uv found" || echo "[MISSING] uv — install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
command -v specify && echo "[OK] specify found" || echo "[MISSING] specify — will be installed"
```

If `uv` is missing, tell the user to install it and stop.

If `$ARGUMENTS` is `sync-only`, skip to Step 4.

### Step 2: Install/update speckit CLI

```bash
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
```

### Step 3: Reinitialize speckit (with constitution protection)

**Backup constitution if it exists:**

```bash
if [ -f .specify/memory/constitution.md ]; then
  cp .specify/memory/constitution.md .specify/memory/constitution-backup.md
  echo "[BACKUP] Constitution backed up"
else
  echo "[SKIP] No existing constitution to back up"
fi
```

**Reinitialize speckit:**

```bash
specify init --here --force --ai claude
```

**Restore constitution:**

```bash
if [ -f .specify/memory/constitution-backup.md ]; then
  mv .specify/memory/constitution-backup.md .specify/memory/constitution.md
  echo "[RESTORED] Constitution restored from backup"
else
  echo "[SKIP] No backup to restore"
fi
```

If `$ARGUMENTS` is `speckit-only`, skip to Step 7.

### Step 4: Fetch sync-prompt from template repo

```bash
curl -sL https://raw.githubusercontent.com/johanolofsson72/Claude/main/scripts/sync-prompt.md
```

Read the fetched content carefully.

### Step 4b: Version check (saves tokens)

The sync-prompt now has a **Step 0: Version check** that compares the template's current commit SHA against `.claude/.sync-version` in this project. Execute it BEFORE reading any template files:

```bash
TEMPLATE_SHA=$(curl -sL https://api.github.com/repos/johanolofsson72/Claude/commits/main | jq -r '.sha // empty')
LAST_SHA=$(cat .claude/.sync-version 2>/dev/null)
```

**Three possible outcomes:**

1. **SHAs match** → Project is already current. Report "already up to date" and skip to Step 7 (verify) and Step 8 (report). Do NOT fetch template files.
2. **LAST_SHA exists, SHAs differ** → **Incremental sync**. Fetch the changed-files list via GitHub compare API: `curl -sL "https://api.github.com/repos/johanolofsson72/Claude/compare/${LAST_SHA}...${TEMPLATE_SHA}" | jq -r '.files[].filename'`. Then fetch ONLY those changed files instead of all 30+ template files.
3. **No LAST_SHA** → First-time sync. Fetch all template files as before.

If `$ARGUMENTS` contains `--force` or `force`, skip the version check entirely and do a full sync.

**At the end of sync (Step 8b in sync-prompt):** Write the fetched SHA to `.claude/.sync-version` and commit it.

### Step 5: Execute sync-prompt instructions

Execute all instructions between the `---` markers in the fetched sync-prompt. Specifically:

1. **Read template files** — For each file referenced in the sync-prompt, fetch it from the GitHub raw URL:
   - `/Users/jool/repos/Claude/CLAUDE.md` → `curl -sL https://raw.githubusercontent.com/johanolofsson72/Claude/main/CLAUDE.md`
   - `/Users/jool/repos/Claude/.claude/rules/dotnet.md` → `curl -sL https://raw.githubusercontent.com/johanolofsson72/Claude/main/.claude/rules/dotnet.md`
   - `/Users/jool/repos/Claude/.claude/docs/testing.md` → `curl -sL https://raw.githubusercontent.com/johanolofsson72/Claude/main/.claude/docs/testing.md`
   - etc. — translate ALL `/Users/jool/repos/Claude/` paths to `https://raw.githubusercontent.com/johanolofsson72/Claude/main/`

2. **Read this project's files** — Read existing `CLAUDE.md`, `.claude/settings.json`, and all files under `.claude/` in THIS project.

3. **Language migration** — If this project still has Swedish content in Claude Code config files, translate to English per the sync-prompt's instructions.

4. **Analyze and update** — For each template file:

   | Situation | Action |
   |-----------|--------|
   | File does NOT exist in this project | Copy from template |
   | File exists and matches template | Skip |
   | File exists but is older | Update to template version, preserve `# PROJECT-SPECIFIC` blocks |
   | File exists with project-specific content | Merge — template structure + project customizations |

5. **CLAUDE.md merge** — Update: critical rules, execution mode, workflow, verification, context management, reference files. Preserve: project description, tech stack, commands, project-specific principles.

6. **settings.json merge** — UNION of hooks and permissions.deny. Preserve project-specific hooks.

7. **Verify spec testing pipeline** — Ensure rules/specs.md, docs/spec-testing-checklist.md, and the PostToolUse prompt-hook all exist.

8. **Verify Allium + TLA+ pipeline** — Ensure all verification pipeline files exist per sync-prompt instructions.

9. **Install required external skills** — Run the git clone commands for any missing skills (anthropics/skills, superpowers, trailofbits, qa-test, dotnet, vercel, playwright). Skip already-installed ones.

10. **Install TLC model checker** — Verify TLC is available, install if missing.

### Step 6: Ask about tech stack and clean up

Use `AskUserQuestion` to confirm the project's tech stack (the sync-prompt has the exact question). Remove irrelevant files based on the answer.

**IMPORTANT**: If this is a re-sync (files already exist and tech stack was already decided), check if `.claude/rules/dotnet.md` etc. have been previously removed. If they were, don't re-add them — respect the previous tech stack decision. Ask the user:

> This project was previously synced. Should I re-evaluate the tech stack, or keep the current file selection?

### Step 7: Verify

- Verify `settings.json` is valid JSON: `python3 -m json.tool .claude/settings.json`
- Verify CLAUDE.md does not exceed ~200 lines
- Verify reference files in CLAUDE.md point to files that actually exist

### Step 8: Report

```markdown
## Project Update Complete

**Speckit**: [installed/updated/skipped] — version [X]
**Sync source**: johanolofsson72/Claude (main branch)
**Constitution**: [preserved/untouched]

### Files synced:
- [CREATED] filename — reason
- [UPDATED] filename — what changed
- [SKIPPED] filename — already current
- [REMOVED] filename — not relevant for tech stack
- [TRANSLATED] filename — migrated Swedish → English

### Project-specific preserved:
- filename — what was preserved

### Manual review recommended:
- filename — why

Run `/project-wizard` if you need to update the project's core documents (CLAUDE.md project section, constitution, design system, project brief).
```

## Rules

1. NEVER change the project's core logic or application code.
2. ALWAYS preserve project-specific customizations (marked with `# PROJECT-SPECIFIC` or clearly unique to the project).
3. NEVER overwrite the constitution with speckit's default — always backup and restore.
4. If unsure about a merge conflict: report and ask instead of changing.
5. Do NOT commit automatically — let the developer review first.
6. All template file reads MUST go through GitHub raw URLs, not local paths. This ensures the skill works on any machine.
7. Communicate in English.
