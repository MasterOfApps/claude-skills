# Start Here — Windows 11

Welcome! This guide gets `/project-wizard` and `/project-update` running on your Windows 11 machine in about 5 minutes. Follow each step exactly. **You do not need git or GitHub for any of this.**

If anything looks different from what is described here, stop and ask — do not improvise.

---

## What you need before you start

- [x] A Windows 11 PC
- [x] A folder on your computer where you keep screenshots / notes about the project you want to build (e.g. `C:\Users\YourName\Pictures\MyProjectIdea`)
- [x] An internet connection

That is it. No git. No GitHub account. No Claude Code pre-installed. No previous knowledge. The installer in Step 2 fetches everything for you, including Claude Code itself.

---

## Step 1 — Open Windows PowerShell as Administrator

1. Press the **Windows key** on your keyboard (the one with the four squares).
2. Type the word **`powershell`**.
3. In the search results you will see **Windows PowerShell**.
4. **Right-click** on **Windows PowerShell**.
5. Click **Run as administrator**.
6. A blue (or black) window opens. If Windows asks "Do you want to allow this app to make changes?", click **Yes**.

You should now see a window with text similar to:

```
PS C:\Windows\system32>
```

That blinking line is where you will paste commands. Leave the window open for the rest of this guide.

---

## Step 2 — Install the skills

This single command installs everything you need: the `/project-wizard` skill, the `/project-update` skill, and the `uv` tool that the wizard needs.

**Copy the line below exactly**, then **right-click in the PowerShell window** to paste it, and press **Enter**.

```powershell
irm https://raw.githubusercontent.com/MasterOfApps/claude-skills/main/install-windows.ps1 | iex
```

You will see output like:

```
=== Claude Skills - Windows Installer ===
Source : https://raw.githubusercontent.com/MasterOfApps/claude-skills/main
Target : C:\Users\YourName\.claude\skills

=== Step 1 / 5 - Prepare Claude config directory ===
  [OK]   Created C:\Users\YourName\.claude\skills

=== Step 2 / 5 - Check / install uv ===
  [OK]   uv installed and available

=== Step 3 / 5 - Download skills from GitHub ===
  [OK]   project-wizard -> C:\Users\YourName\.claude\skills\project-wizard\SKILL.md
  [OK]   project-update -> C:\Users\YourName\.claude\skills\project-update\SKILL.md

=== Step 4 / 5 - Check Claude Code ===
  [OK]   Claude Code CLI (claude) found

=== Step 5 / 5 - Done ===
Installed 2 skill(s):
  - /project-wizard
  - /project-update

Happy building!
```

**Do not continue if you do not see `Installed 2 skill(s)` at the end.** If you see `[FAIL]` or `[WARN]` lines, read them carefully — they tell you exactly what is missing. The most common one is **uv installed but not yet on PATH** — if you see that, close the PowerShell window, open a new one as administrator, and paste the command again.

---

## Step 3 — Close PowerShell and open a fresh one

This refreshes the system so that the newly installed `uv` tool is recognized.

1. Close the current PowerShell window (the X in the top-right corner).
2. Repeat **Step 1** to open a new PowerShell as administrator.

---

## Step 4 — Go to your project folder

Replace the example path below with the actual folder where you keep your project screenshots / notes.

Example — if your folder is `C:\Users\Johan\Pictures\MyProjectIdea`:

```powershell
cd "C:\Users\Johan\Pictures\MyProjectIdea"
```

After pressing **Enter**, the prompt should change to show the folder, like:

```
PS C:\Users\Johan\Pictures\MyProjectIdea>
```

**Tip — easy way to get the exact path:** open the folder in File Explorer, click on the address bar at the top, and the full path will be shown. Copy it and paste it after `cd ` (with a space).

---

## Step 5 — Start Claude Code

Type:

```powershell
claude
```

and press **Enter**. Claude Code starts in your project folder. You will see a chat-style prompt.

---

## Step 6 — Run the project wizard

In the Claude prompt, type exactly:

```
/project-wizard
```

and press **Enter**.

The wizard will:

1. Install / update the speckit tool automatically.
2. Sync the latest project rules and templates from the master template repo.
3. Look at any screenshots and files in the folder you are in.
4. Ask you about 50 short questions, **one at a time**, about what you want to build (project name, who it is for, what tech to use, what it should look like, etc.). Just answer them one by one. If you do not know an answer, type "I don't know" and the wizard will recommend something for you.
5. When you are done, the wizard will create three files in your folder:
   - `CLAUDE.md` — instructions for Claude in this project
   - `.specify/memory/constitution.md` — the rules of your project
   - `PROJECT-BRIEF.md` — a human-readable description you can show to others

After that, you have a project ready to build.

---

## Step 7 (later) — Updating an existing project

When the master template gets new rules and you want them in an existing project:

1. Open PowerShell as administrator.
2. `cd` into your project folder (Step 4).
3. `claude` (Step 5).
4. Type `/project-update` and press Enter.

That is the only difference between starting a new project and updating one.

---

## What if something goes wrong?

| What you see | What to do |
|---|---|
| `irm : The remote name could not be resolved` | You have no internet. Connect and try again. |
| `[FAIL] No skills were installed` | Re-run the install command in Step 2. |
| `[WARN] Claude Code CLI (claude) NOT found` | Install Claude Code from <https://claude.com/claude-code>, then close PowerShell, open a new one, and try Step 5 again. |
| `[WARN] uv installed but not yet on PATH` | Close PowerShell, open a new one as administrator, re-run the install command. |
| `claude : The term 'claude' is not recognized` | Same as above — Claude Code is not on PATH yet. Close and reopen PowerShell. |
| The wizard stops at "Phase -1" | `uv` is missing. Re-run Step 2. |
| `/project-wizard` is not in the list of slash commands | Press `Ctrl+C` to exit Claude, then run `claude` again. Skills are loaded when Claude starts. |
| Anything else | Take a screenshot of the whole PowerShell window and send it to Johan O. |

---

## What just happened (in plain words)

- A small file called `SKILL.md` was downloaded for each skill into your user folder under `.claude\skills\`. That is how Claude Code learns new commands.
- A tool called `uv` was installed. It is a fast Python package installer that the wizard uses to install another tool called `specify`. You do not need to think about either of them after this.
- Nothing was changed outside of your own user folder. Nothing was uploaded anywhere. No GitHub account was needed.

That is everything. Welcome aboard.
