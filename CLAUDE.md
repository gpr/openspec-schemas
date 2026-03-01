# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Purpose

This is an OpenSpec custom schema repository. It provides alternative schemas that extend the upstream `spec-driven` schema with additional workflow semantics. `team-spec-driven` is the reference implementation. Additional schemas can be added following the same conventions.

## Setup

This repo uses [mise](https://mise.jdx.dev/) to manage tools. Run:

```sh
mise trust && mise install
```

This installs Node and the `openspec` CLI (via npm).

## Repository Structure

Schemas are self-contained directories. A symlink in `openspec/schemas/` lets the CLI discover them (e.g. for `openspec schema validate`).

```
.
├── mise.toml                # Tool versions (node, openspec CLI)
├── openspec/
│   └── schemas/
│       └── <schema-name> -> ../../<schema-name>   # Symlink for CLI discovery
└── <schema-name>/
    ├── schema.yaml          # Artifact pipeline, instructions, dependency chain, apply phase
    ├── CLAUDE.md            # Specific instructions for maintaining the custom schema
    └── templates/           # One .md file per artifact
        └── *.md
```

`schema.yaml` defines the artifact pipeline, instructions for each phase, and the apply-phase execution model. Templates provide the structural skeleton for each artifact.

## schema.yaml Reference

### Top-Level Fields

| Field | Type | Required | Description |
| ------- | ------ | ---------- | ------------- |
| `name` | string | yes | kebab-case schema name |
| `version` | integer | yes | schema version number |
| `description` | string | yes | human-readable description |
| `artifacts` | list | yes | ordered artifact definitions |
| `apply` | object | yes | apply-phase configuration |

### Artifact Fields

| Field | Type | Required | Description |
| ------- | ------ | ---------- | ------------- |
| `id` | string | yes | unique identifier, referenced in `requires` |
| `generates` | string | yes | output filename (supports globs: `specs/**/*.md`) |
| `description` | string | yes | human-readable purpose |
| `template` | string | yes | filename in `templates/` directory |
| `instruction` | string | yes | multiline AI generation instructions |
| `requires` | list | yes | artifact IDs this depends on (`[]` for none) |

### Apply Fields

| Field | Type | Required | Description |
| ------- | ------ | ---------- | ------------- |
| `requires` | list | yes | artifact IDs that must exist before apply phase |
| `tracks` | string | yes | file parsed for `- [ ]` checkboxes to track progress |
| `instruction` | string | no | instructions for apply-phase execution |

### Minimal Skeleton

```yaml
name: my-schema
version: 1
description: Short description of the workflow

artifacts:
  - id: proposal
    generates: proposal.md
    description: Initial proposal
    template: proposal.md
    instruction: |
      ...
    requires: []

  - id: tasks
    generates: tasks.md
    description: Implementation checklist
    template: tasks.md
    instruction: |
      ...
    requires: [proposal]

apply:
  requires: [tasks]
  tracks: tasks.md
  instruction: |
    ...
```

## Artifact Composition Rules

Every schema must include at least **proposal** and **tasks** artifacts. Additional artifacts (specs, design, or custom) are optional.

| Artifact | Required | Role |
| ---------- | ---------- | ------ |
| `proposal` | **yes** | Root artifact. No dependencies. Defines why and what. |
| `tasks` | **yes** | Terminal artifact. Feeds the apply phase via `- [ ]` checkboxes. |
| `specs` | no | Detailed requirements between proposal and tasks. |
| `design` | no | Technical design between proposal and tasks. |
| custom | no | Any artifact following the same field schema. |

### Dependency Chain Rules

- Dependencies form a **DAG** (directed acyclic graph). No circular references.
- `proposal` is always the root (`requires: []`).
- `tasks` is always the terminal artifact — listed in `apply.requires` and tracked by `apply.tracks`.
- Intermediate artifacts can depend on any earlier artifact(s).

Valid dependency chains:

```text
proposal → tasks                           # minimal
proposal → specs → tasks                   # 3 artifacts
proposal → specs ─┐
proposal → design ┴→ tasks                 # fan-in
```

## User Configuration

Users customize schemas in their project config. See [OpenSpec customization docs](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md).

```yaml
# openspec/config.yaml
schema: <schema-name>

context: |
  <project context injected into all artifact prompts>

rules:
  <artifact_id>:
    [<artifact-specific rules>]
```

When generating any artifact, context, rules, template, and instructions are injected into the AI prompt in that order.

## Creating a New Schema

Bootstrap with the CLI:

```sh
openspec schema init --no-default --description "<description>" --artifacts <artifacts> <schema-name>
```

`--artifacts` is a comma-separated list (e.g. `proposal,specs,tasks`). At minimum include `proposal` and `tasks`.

After bootstrapping:

1. Fill in `schema.yaml` artifact instructions and the `apply` section
2. Fill in each template in `templates/`
3. Create the symlink for CLI discovery:

   ```sh
   ln -s ../../<schema-name> openspec/schemas/<schema-name>
   ```

4. Validate:

   ```sh
   openspec schema validate <schema-name>
   ```

Use `team-spec-driven/` as the reference implementation.

## Validation

There are no build tools, linters, or unit tests. Validate schemas with these two steps:

### 1. Structural validation

```sh
openspec schema validate <schema-name>
```

Checks that `schema.yaml` fields, templates, and dependency chain are well-formed.

### 2. Instruction review

Create a throwaway change, then inspect the rendered instructions for each artifact:

```sh
openspec new change <schema-name>-test --schema <schema-name>
openspec instructions proposal --change <schema-name>-test
```

Review the output to confirm that templates, instructions, and any user context/rules merge correctly. Repeat for other artifacts (`specs`, `design`, `tasks`) as needed.

Clean up when done:

```sh
rm -rf openspec/changes/<schema-name>-test
```

## Key Constraints

Things that break silently if wrong:

- **Scenario headings must be `####`** (exactly 4 hashtags). Using `###` or bullets causes scenarios to be silently dropped.
- **Task checkboxes must be `- [ ]`** format. The apply phase parses these to track progress — other formats are invisible.
- **Spec files require YAML front matter** with `name`, `description`, `component`, and `dependencies` fields.
- **Symlink must exist** in `openspec/schemas/` for CLI discovery. Without it, `openspec schema validate` cannot find the schema.
