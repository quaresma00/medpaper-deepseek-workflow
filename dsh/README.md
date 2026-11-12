# dsh/ — DeepSeek Harness integration

How this workflow is invoked inside the DeepSeek Harness (DSH) — the equivalent of
Codex's `$medpaper`, Kiro's skill, and Gemini's global skill, for DeepSeek.

## Three entry mechanisms (all installed by `install.ps1`)

| Mechanism | Location | Effect |
|---|---|---|
| User-level skill | `$DSH_HOME/skills/medpaper/SKILL.md` | `medpaper` appears in every session's skill catalog; the agent loads it automatically when the task mentions medical papers / research ideas / public dataset mining / journal submission |
| User-global AGENTS.md | `$DSH_HOME/AGENTS.md` | Injected into every session as standing instructions: how to enter the workflow and its hard rules |
| Project AGENTS.md | paper workspace root | Injected when a session opens in the paper folder (already shipped by `new-paper.ps1`) |

`$DSH_HOME` defaults to `~/.dsh` (Windows: `C:\Users\<you>\.dsh`).

## Install (one command, any machine)

```powershell
pwsh .\dsh\install.ps1
```

Restart sessions after install; the skill catalog refreshes on new sessions.

## Invoke (after install)

- **New study:** `medpaper new -Slug <name> -IdeaFile <idea.md> [-DataDir <dir>]`
- **Resume:** open the paper workspace in DeepSeek, then just say
  "继续 medpaper" / "medpaper status" — the agent runs the driver.
- **No PATH needed:** the agent also resolves
  `pwsh <workflow-root>/medpaper-helpers/medpaper.ps1 <command>`.
