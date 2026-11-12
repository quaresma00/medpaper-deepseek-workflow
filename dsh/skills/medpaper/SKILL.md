---
name: medpaper
description: Drives the gated, resumable 25-stage medical/clinical research paper workflow — from a research idea through feasibility, full-census public-dataset acquisition, verified PubMed references, analysis with replay proofs, reader-facing three-line tables and R-first figures, per-section medical writing, independent subagent review, SCIE journal selection, and a submission package. Use whenever the task involves a medical research idea, a clinical manuscript, an original article, pharmacovigilance or public dataset mining, PubMed literature retrieval, journal selection, or a submission package. Run the driver (medpaper.ps1) and obey the active stage card; never follow the workflow from memory.
compatibility: Windows pwsh; uv + Python 3.13 (paper venv); R 4.3+ for new medical figures; Pandoc; network for PubMed/Crossref/Unpaywall and official journal guidelines.
metadata:
  entrypoint: "pwsh <workflow-root>/medpaper-helpers/medpaper.ps1 status"
---

# medpaper workflow (DeepSeek Harness edition)

The paper is the folder with `pipeline/pipeline.toml` and `.venv` (created by
`medpaper new`). Drive it through the driver; env vars (PYTHONUTF8, NCBI_API_KEY,
NCBI_API_EMAIL) are injected automatically.

## Invocation

```powershell
# inside the paper workspace:
medpaper                    # status + active stage card (the "one command" entry)
medpaper check              # run current-stage gates
medpaper advance -n "note"  # close the stage and advance
medpaper card --details     # detailed stage card when needed
medpaper handoff            # bounded resume after context compaction
medpaper new -Slug <name> -IdeaFile <idea.md> [-DataDir <dir>]   # new paper
```

If `medpaper` is not on PATH, call the script directly:
`pwsh <workflow-root>/medpaper-helpers/medpaper.ps1 <command> [args]`

## Execution loop

`status → card → do the stage work → check → advance --note "..."` — gates are not
turn boundaries; red gates are fixed before advancing. Execution order is tables
(S10) → figures (S11) → Results (S09) → reconcile (S12) despite stable IDs.

## Rules that always apply

- Full census acquisition: no LIMIT/head()/sample()/first-N; every source reconciled
  with source totals and hashes (data_manifest.py); never force-waived.
- References: formal citations only via fresh PubMed EFetch verification
  (pubmed/verify.py); never hand-write library/verified/bib/ris files.
- Numbers: own-study numbers come only from executed 03_analysis/results/*.json;
  prior-study numbers need registered full-text source claims.
- Language: every written section is de-AI'd and medically polished in place
  (no snake_case, p.value, JSON keys, analysis-report phrasing in reader-facing text).
- Human checkpoints: S19 and S24 require the exact statement 我确认这一版 bound to
  the current files; journal choice and author facts come from the user.
- Early stop: if a stage shows the study is not worth continuing, report
  GO/PIVOT/STOP advice to the user immediately instead of pushing forward.

Full execution documentation: `MEDPAPER-WORKFLOW.md` in the workflow root.
Engine (read-only): AGENTS.md, pipeline/pipeline.toml, pipeline/stages/, reference/.
