# 3DGS House Scanner — bigpowers Conventions

Read this before any development work.

## § Always Green / Shift Left

**1-10-100 Rationale:**
- **1** — Fix bugs in your PR (1x effort, highest quality)
- **10** — Fix bugs in CI (10x effort, block all developers)
- **100** — Fix bugs in production (100x effort, block users)

**Definition:**
- **Preflight green** = No lint/test errors, no security issues
- **CI green** = All checks pass on GitHub, no PR failures

**Gate:**
- **Red Preflight or CI** → Invoke `quick-fix` or `fix-bug` first
- **Do not proceed** on red gates under any circumstances

## § Discovered Defects

**Fix-or-Log Ladder:**
1. **quick-fix** — Data-only changes, no logic risk
2. **fix-bug** — Logic changes, requires TDD, bug ticket
3. **log defect** — Out of scope, document in `specs/bugs/BUG-*.md`

**Rules:**
- Separate commits for discovered fixes
- Document all defects in `specs/bugs/registry.yaml`
- Never silence failures — fix or log

## Banned Dismissive Phrases

| Phrase | Why | Fix Instead |
|--------|-----|-------------|
| pre-existing | Ignore root cause | `fix-bug` → prove with tests |
| unrelated to session | Ignore context | `investigate-bug` → map scope |
| not introduced by my changes | Ignore blame | `diagnose-root` → find cause |
| out of scope | Ignore defect | `scope-work` → redefine scope |

## § Defensive Code Categories

- **Timeout** — All subprocess calls must have `timeoutMs` parameter
- **Retry** — External API calls (Nerfstudio, cloud services) retry 3x
- **Graceful degradation** — Fallback to cloud processing if local fails

## § Always Green / Shift Left

**1-10-100 Rationale:**
- **1** — Fix bugs in your PR (1x effort, highest quality)
- **10** — Fix bugs in CI (10x effort, block all developers)
- **100** — Fix bugs in production (100x effort, block users)

**Definition:**
- **Preflight green** = No lint/test errors, no security issues
- **CI green** = All checks pass on GitHub, no PR failures

**Gate:**
- **Red Preflight or CI** → Invoke `quick-fix` or `fix-bug` first
- **Do not proceed** on red gates under any circumstances

## § Discovered Defects

**Fix-or-Log Ladder:**
1. **quick-fix** — Data-only changes, no logic risk
2. **fix-bug** — Logic changes, requires TDD, bug ticket
3. **log defect** — Out of scope, document in `specs/bugs/BUG-*.md`

**Rules:**
- Separate commits for discovered fixes
- Document all defects in `specs/bugs/registry.yaml`
- Never silence failures — fix or log

## Banned Dismissive Phrases

| Phrase | Why | Fix Instead |
|--------|-----|-------------|
| pre-existing | Ignore root cause | `fix-bug` → prove with tests |
| unrelated to session | Ignore context | `investigate-bug` → map scope |
| not introduced by my changes | Ignore blame | `diagnose-root` → find cause |
| out of scope | Ignore defect | `scope-work` → redefine scope |

## § Defensive Code Categories

- **Timeout** — All subprocess calls must have `timeoutMs` parameter
- **Retry** — External API calls (Nerfstudio, cloud services) retry 3x
- **Graceful degradation** — Fallback to cloud processing if local fails

## § Specs Output Convention

- **YAML only** — Use `specs/*.yaml`, not legacy `specs/*.md`
- **Flat epic structure** — `specs/epics/eNN-*.yaml`, not subdirectories
- **Atomic commits** — One story per commit with Conventional Commits

## § Stack Conventions

**Python:**
- Use `venv` instead of conda
- Python 3.10+ for compatibility
- Type hints required for functions with external dependencies

**PowerShell:**
- Mandatory parameters with `param()`
- Error handling with `if ($LASTEXITCODE -ne 0)`
- Support both relative and absolute paths

**Batch:**
- Use full paths in examples
- Check file existence before operations
- Clear error messages with usage examples
