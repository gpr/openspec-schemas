## ADDED Requirements

### Requirement: Role-grouped task template

The tasks template SHALL organize tasks under role-based headings: `## Implementation`, `## Tests`, and `## Documentation`. Each role group contains `- [ ]` checkboxes specific to that concern.

#### Scenario: Tasks generated with role groupings

- **WHEN** the tasks artifact is generated from specs and design
- **THEN** the output contains three `##` sections: Implementation, Tests, and Documentation, each with `- [ ]` checkboxes

#### Scenario: Single-concern change omits empty role groups

- **WHEN** a change only requires implementation (no new tests or docs)
- **THEN** the tasks artifact contains only the `## Implementation` section and omits empty role groups

### Requirement: Team creation during apply phase

The apply instruction SHALL direct Claude Code to create a Team via `TeamCreate` and spawn one teammate per non-empty role group using the `Agent` tool with `team_name`.

#### Scenario: Multi-role change spawns team

- **WHEN** the apply phase begins and `tasks.md` contains more than one role group with pending tasks
- **THEN** a Team is created and one teammate is spawned per role group, each assigned their group's tasks

#### Scenario: Single-role change skips team

- **WHEN** the apply phase begins and `tasks.md` contains only one role group with pending tasks
- **THEN** no Team is created and the coordinator executes tasks sequentially in single-agent mode

### Requirement: Threshold-based team activation

The apply instruction SHALL include a task-count threshold below which team orchestration is skipped in favor of single-agent sequential execution.

#### Scenario: Below threshold runs single-agent

- **WHEN** the total number of pending tasks across all role groups is below the threshold
- **THEN** the coordinator executes all tasks sequentially without spawning a Team

#### Scenario: At or above threshold spawns team

- **WHEN** the total number of pending tasks meets or exceeds the threshold
- **THEN** the coordinator creates a Team and spawns role-based teammates

### Requirement: Shared worktree execution

All teammates SHALL operate within the same worktree (the change's worktree) rather than spawning individual sub-worktrees. The apply instruction SHALL NOT use `isolation: "worktree"` on teammate Agent calls.

#### Scenario: Teammates share worktree

- **WHEN** teammates are spawned for implementation, tests, and documentation
- **THEN** all teammates execute within the same working directory as the coordinator

### Requirement: Parallel execution of role teammates

The coordinator SHALL spawn all role teammates in a single message (multiple `Agent` tool calls) so they execute concurrently.

#### Scenario: Roles execute in parallel

- **WHEN** the coordinator spawns teammates for implementation, tests, and documentation
- **THEN** all three Agent calls are made in a single response, enabling concurrent execution

### Requirement: Design template parallelization strategy section

The design template SHALL include a "Parallelization Strategy" section with subsections: Independent Concerns, Conflict Zones, and Role Assignments.

#### Scenario: Design template includes parallelization section

- **WHEN** the design artifact is generated
- **THEN** the output contains a `## Parallelization Strategy` section with `### Independent Concerns`, `### Conflict Zones`, and `### Role Assignments` subsections

### Requirement: Graceful degradation to single-agent

The apply instruction SHALL fall back to single-agent sequential execution when team orchestration is unavailable or unnecessary, without requiring changes to the task format.

#### Scenario: Role headings work in single-agent mode

- **WHEN** a single agent processes `tasks.md` without team orchestration
- **THEN** the agent works through all role groups sequentially, treating `##` headings as standard task groups
