# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this directory.

## What This Is

An OpenSpec schema defining the `team-spec-driven` workflow. It produces four artifact types in sequence:

**proposal.md** → **specs/\*\*/\*.md** → **design.md** → **tasks.md** → apply phase

Each artifact has a template in `templates/` and its instruction + dependency chain in `schema.yaml`. The apply phase reads tasks.md and tracks progress by parsing checkboxes.

## Component-Based Team Rules

The project's CLAUDE.md contains a Mermaid C4 Component diagram (`<components>`). The schema uses this to drive a **contract-first parallel team model**: the Leader defines cross-component contracts first, then Teammates work on their components in parallel.

| Artifact | Rule |
|----------|------|
| proposal | Map capabilities to `<components>` from C4 diagram; identify cross-component contracts |
| spec | YAML front matter with `component` field; contract specs owned by Leader |
| design | Component Dependency Map, File Ownership Table, per-component design sections |
| tasks | Group 0: Contracts (Leader, first); Groups 1-N: one per component (parallel Teammates) |

These rules are embedded in `schema.yaml` instruction fields.
