# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this directory.

## What This Is

An OpenSpec schema defining the `claude-spec-driven` workflow. It produces four artifact types in sequence:

**proposal.md** → **specs/\*\*/\*.md** → **design.md** → **tasks.md** → apply phase

Each artifact has a template in `templates/` and its instruction + dependency chain in `schema.yaml`. The apply phase reads tasks.md and tracks progress by parsing checkboxes.

## Role-Based Team Rules

This schema uses **role-based parallelism**: within each implementation step, work is split by role (Implementation, Tests, Documentation) rather than by component.

| Artifact | Rule |
|----------|------|
| proposal | Identify capabilities; include Concurrency Considerations under Impact |
| spec | One spec file per capability; delta operations for modifications |
| design | Parallelization Strategy with Independent Concerns, Conflict Zones, Role Assignments |
| tasks | Steps are sequential; roles within a step are parallel (`### Implementation` / `### Tests` / `### Documentation`) |

### Apply Phase

- **Step-sequential**: Complete step N before starting step N+1.
- **Role-parallel**: Within a step, Implementation, Tests, and Documentation proceed concurrently with file ownership boundaries.
- **Self-review**: Each role agent self-reviews before reporting completion. No separate cross-challenge phase.
- **Coordinator owns tasks.md**: Only the coordinator edits checkboxes — teammates report via `SendMessage` to avoid write races.
- **Final verification**: After all steps complete, parallel verification agents (one per mandate) review the change against proposal, specs, design, and tasks independently.
- **Per-step decision**: Each step is assessed individually — multi-role steps use Team Mode; single-role steps use Single-Agent Mode.

## Key Constraints

Things that break silently if wrong:

- **Scenario headings must be `####`** (exactly 4 hashtags). Using `###` or bullets causes scenarios to be silently dropped.
- **Task checkboxes must be `- [ ]`** format. The apply phase parses these to track progress — other formats are invisible.
