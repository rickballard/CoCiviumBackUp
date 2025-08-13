# Grand Migration Plan — v1 (staging in CoCache)

## Goals
- Centralize design + execution for moving/organizing repos and packages.
- Keep day-to-day work unblocked; changes are incremental and reversible.

## Phases
1. **Inventory & Decisions**
   - List all repos/packages & desired landing spots in CoCache.
   - Pick a move method per unit: copy | git-subtree | git-filter-repo (history).
2. **Dry-run PRs**
   - Create PRs that introduce structure without switching prod flows.
   - Add docs/CI stubs; verify nothing breaks.
3. **Moves**
   - Execute per-unit move with the chosen method.
   - Preserve history when it matters; otherwise copy with attribution.
4. **Wire-ups**
   - Update READMEs, package names, CI paths, release scripts.
5. **Clean-ups**
   - Close/lock archived code paths; add pointers; tag/label issues.

## Guardrails
- Everything via PRs; no force-push.
- Clear ownership: CODEOWNERS + labels.
- Rollback plan noted in each PR.

## Links / Artifacts
- Inventory: docs/migration/INVENTORY.example.yml (copy to INVENTORY.yml and fill)
- Timeline: docs/migration/TIMELINE.md
- Risks: docs/migration/RISKS.md
