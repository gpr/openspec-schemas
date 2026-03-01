# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Purpose

This is an OpenSpec custom schema repository. It provides alternative schemas that extend the upstream `spec-driven` schema with additional workflow semantics. Currently ships one schema: `team-spec-driven`.

## Setup

This repo uses [mise](https://mise.jdx.dev/) to manage tools. Run:

```sh
mise install
```

This installs Node and the `openspec` CLI (via npm).

## Repository Structure

Schemas are self-contained directories. A symlink in `openspec/schemas/` lets the CLI discover them (e.g. for `openspec schema validate`).

```
.
├── mise.toml                # Tool versions (node, openspec CLI)
├── openspec/
│   └── schemas/
│       └── team-spec-driven -> ../../team-spec-driven   # Symlink for CLI discovery
└── <schema-name>/
    ├── schema.yaml          # Artifact pipeline, instructions, dependency chain, apply phase
    ├── CLAUDE.md            # Runtime file injected by OpenSpec (NOT repo guidance)
    └── templates/           # Markdown templates for each artifact type
        ├── proposal.md
        ├── spec.md
        ├── design.md
        └── tasks.md
```

`schema.yaml` defines the artifact pipeline, instructions for each phase, and the apply-phase execution model. Templates provide the structural skeleton for each artifact.

## Artifact and Instructions

See <https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md> for more details.

In the `schema.yaml` the artifact is defined as following:

```yaml
# openspec/schemas/<custom_schema>/schema.yaml
artifacts:
- id: <artifact_id>
    generates: <artifact_id>.md
    description: <artifact_description>
    template: <artifact_id>.md
    instruction: |
      <instruction_to_generate_the_artifact>
    requires: [<required_artifacts>]
```

The user can customise the schema in the project config (`openspec/config.yaml`):

```yaml
# openspec/config.yaml
schema: <custom_schema>

context: |
  <context>

rules:
  <artifact_id>:
    [<rules>]
```

When generating any artifact, your context and rules are injected into the AI prompt:

```markdown
<context>

<rules>

<template>

<instructions>
```

## Validation

The only "test" for this repo:

```sh
openspec schema validate <schema-name>
```

Example: `openspec schema validate team-spec-driven`

There are no build tools, linters, or unit tests.

## Key Constraints

Things that break silently if wrong:

- **Scenario headings must be `####`** (exactly 4 hashtags). Using `###` or bullets causes scenarios to be silently dropped.
- **Task checkboxes must be `- [ ]`** format. The apply phase parses these to track progress — other formats are invisible.
- **Spec files require YAML front matter** with `name`, `description`, `component`, and `dependencies` fields.
