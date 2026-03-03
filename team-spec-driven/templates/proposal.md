## Why

<!-- Explain the motivation for this change. What problem does this solve? Why now? -->

## What Changes

<!-- Describe what will change. Be specific about new capabilities, modifications, or removals. -->

## Components Affected

<!-- Read the C4Component diagram from CLAUDE.md. List each affected Component(...) entry. -->

| Component | Container | Cross-Component Relationships |
|-----------|-----------|-------------------------------|
| <!-- Component alias/label --> | <!-- Container_Boundary this component belongs to --> | <!-- Rel(...) edges involving this component --> |

## Contracts

<!-- Cross-component contracts identified from Rel(...) edges. Each becomes a Leader-owned spec. -->
- `contract-<name>`: <!-- brief description of what this contract defines -->

## Capabilities

### New Capabilities
<!-- Capabilities being introduced. Each creates specs/<name>/spec.md.
     Component-scoped: use component prefix (e.g., front-user-auth, api-data-export).
     Contracts: use contract- prefix (e.g., contract-auth-api). -->
- `<component-name>`: <brief description of what this capability covers>

### Modified Capabilities
<!-- Existing capabilities whose REQUIREMENTS are changing (not just implementation).
     Only list here if spec-level behavior changes. Each needs a delta spec file.
     Use existing spec names from openspec/specs/. Leave empty if no requirement changes. -->
- `<existing-name>`: <what requirement is changing>

## Impact

<!-- Affected code, APIs, dependencies, systems -->
