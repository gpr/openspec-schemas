# Team Spec-Driven Schema

[![OpenSpec](https://img.shields.io/badge/OpenSpec-schema-blue?logo=github)](https://github.com/Fission-AI/OpenSpec)

Custom [OpenSpec](https://github.com/Fission-AI/OpenSpec) schemas.

## `team-spec-driven`

It coordinates multi-agent work through contract-first design, component ownership, and parallel execution.

### Overview

Most spec-driven workflows assume a single implementer. `team-spec-driven` extends the standard pipeline with team coordination semantics:

- **Contracts** define cross-component interfaces up front, so parallel work never conflicts.
- **Component ownership** maps every file to exactly one team member, preventing merge conflicts.
- **Parallel execution** lets component groups run concurrently after shared contracts are in place.

The result is a structured path from idea to implementation that scales to teams.

### Artifact Pipeline

```text
proposal → specs → design → tasks → apply
```

| Artifact   | Role           | Output             | Description                                       |
| ---------- | -------------- | ------------------ | ------------------------------------------------- |
| `proposal` | **WHY**        | `proposal.md`      | Motivation, affected components, capabilities     |
| `specs`    | **WHAT**       | `specs/**/*.md`    | One spec per capability with testable scenarios    |
| `design`   | **HOW**        | `design.md`        | Architecture, contracts, file ownership table      |
| `tasks`    | **DO**         | `tasks.md`         | Grouped checklist — contracts first, then parallel |
| `apply`    | **IMPLEMENT**  | —                  | Team executes tasks with coordinated ownership     |

## Links

- [OpenSpec](https://github.com/Fission-AI/OpenSpec) — The spec-driven development framework
- [OpenSpec Docs](https://openspec.dev/) — Official documentation
- [Customization Guide](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md) — Project-level schema configuration
