# 3DGS House Scanner — AI Agents

Read CONVENTIONS.md before any GitHub or git operation.

## Project
Create a 3D map of a house using Gaussian Splatting, supporting 3D modeling and 2D floor plans. Build tools for processing photos/videos into renderable 3D scenes with both cloud-hosted and local processing options.
Stack: Python (Nerfstudio), PowerShell (Windows tooling), HTML (web interface)

## Commands
| Action | Command |
|--------|---------|
| Run    | `python -m nerfstudio.scripts.train splatfacto` or `.\extract-frames.ps1` |
| Test   | N/A (script-based project) |
| Build  | N/A (interpreted scripts) |
| Lint   | `pylint` for Python, `ScriptAnalyzer` for PowerShell |
| Preflight | `pylint scripts/ && ScriptAnalyzer scripts/*.ps1` |
| CI     | `gh pr checks` (when a PR is open) |

## Architecture
The project has three main components:
1. **PowerShell/Python tooling** - extract-frames.ps1, train-splat.bat, and Nerfstudio integration
2. **Web front-end** - index.html with tab navigation, checklists, and service links
3. **Documentation** - README-POWERSHELL.md with full setup guide

All components work together to provide a complete workflow: photo capture → frame extraction → 3DGS training → PLY export → web viewer.

## Conventions
- PowerShell scripts use `.ps1` extension with mandatory parameters
- Batch files use `.bat` extension with argument validation
- All scripts support full and relative paths
- Output files go to `output/` or `results/` directories
- Web UI is single-file HTML with inline CSS
- All documentation uses Markdown in `specs/` directory

## Never
- Never dismiss reproducible gate failures as pre-existing or out of scope
- Never proceed on red Preflight or red CI — invoke quick-fix or fix-bug first
- Never modify specs/ files directly without following the bigpowers workflow
- Never commit large binary files (use .gitignore pattern)
- Never hardcode local paths (use environment variables or arguments)

## Agent Rules
- **Workflow Mandate:** You MUST use the bigpowers skills (e.g., `plan-work`, `develop-tdd`, `orchestrate-project`) to perform tasks. DO NOT write code directly in response to a user prompt like "build this feature".
- **Always Green:** Preflight and CI must be green before forward work. Reproducible gate failures require **fix-or-log** (quick-fix → fix-bug) per CONVENTIONS § Discovered Defects.
- Read specs/ before writing code.
- All planning and specifications MUST be written to `specs/` (`product/SCOPE_LATEST.yaml`, `release-plan.yaml`, `epics/`) before any code is generated.
- Write the minimum code that solves the stated problem. Nothing extra.
- Run tests after every change. Show evidence before declaring done.
- One clarifying question beats a wrong assumption baked into 200 lines.

<!-- BEGIN bigpowers:project -->
<!-- END bigpowers:project -->

<!-- BEGIN bigpowers:context-routing -->
| Glob | Sub AGENTS.md |
|------|---------------|
| `specs/`* | `specs/AGENTS.md` (planning docs) |
| `scripts/`* | `scripts/AGENTS.md` (tooling scripts) |
| `*.ps1` | `powershell/AGENTS.md` (PowerShell rules) |
| `*.bat` | `batch/AGENTS.md` (Batch file rules) |
<!-- END bigpowers:context-routing -->

<!-- BEGIN bigpowers:learned-preferences -->
## Learned User Preferences
(Empty - no learned preferences yet)

## Workspace Facts
(Empty - no workspace facts yet)
<!-- END bigpowers:learned-preferences -->

<!-- BEGIN bigpowers:tooling -->
<!-- END bigpowers:tooling -->
