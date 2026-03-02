## Context

The `claude-spec-driven` schema is a fork of the upstream `spec-driven` schema. It currently produces sequential task lists and a single-agent apply phase. Claude Code provides three capabilities that enable parallel execution:

- **Team**: Multi-agent orchestration — a lead agent spawns teammates, assigns work, and coordinates completion via `TeamCreate`, `Agent` (with `team_name`), `SendMessage`, and `TaskCreate`/`TaskUpdate`.
- **WorkTree**: Git worktree isolation — the change itself runs in a worktree, providing an isolated copy of the repo for the entire change.
- **Agent tool**: Teammates are spawned via the `Agent` tool with `team_name` to join the team.

The schema files that need modification: `schema.yaml` (artifact instructions + apply section) and templates in `templates/`.

## Goals / Non-Goals

**Goals:**

- Tasks template organizes work by role: implementation, tests, documentation
- Apply instruction guides Claude Code to spawn a Team with one teammate per role
- All teammates work within the same worktree (the change's worktree)
- A cross-challenge phase follows parallel work: teammates review each other's output
- Design template includes a Parallelization Strategy section to identify independent concerns and conflict zones
- Schema remains compatible with single-agent execution (graceful degradation when Team is unavailable)

**Non-Goals:**

- Modifying the artifact DAG itself (proposal → specs + design → tasks stays the same)
- Adding new artifacts to the pipeline
- Building tooling or scripts — all changes are to schema.yaml instructions and markdown templates
- Optimizing the artifact-creation phase (proposal/specs/design) for parallelism — only the apply phase changes
- Per-batch worktree isolation — we use 1 worktree per change, not per-task-group

## Decisions

### 1. Step-based task grouping with role splits

Tasks are grouped by incremental visible step. Each step is a shippable increment. Within each step, tasks are split by role (Implementation, Tests, Documentation):

```markdown
## 1. Data Export Module

### Implementation
- [ ] 1.1 Create export module structure
- [ ] 1.2 Implement CSV formatter

### Tests
- [ ] 1.3 Add unit tests for CSV formatter
- [ ] 1.4 Add integration test for export pipeline

### Documentation
- [ ] 1.5 Add API docs for export endpoint

## 2. Export UI

### Implementation
- [ ] 2.1 Add export button to dashboard
- [ ] 2.2 Wire up export API call

### Tests
- [ ] 2.3 Add component test for export button
```

**Why step-first over flat role groups:**

- **Incremental delivery**: Each step produces a visible, testable result. Step 1 is fully done (implemented, tested, documented) before step 2 starts.
- **Natural file separation within each step**: Implementation, tests, and docs for the same step touch different files — minimal conflict risk.
- **Cross-challenge per step**: Review happens at each step boundary, catching issues early rather than after all work is done.
- **Steps are sequential, roles are parallel**: Simple mental model — step ordering handles dependencies, role parallelism handles throughput.
- **No dependency annotations needed**: Steps are implicitly ordered (step 2 builds on step 1). No `<!-- depends: N -->` required.

Tests and docs within a step can be written from specs/design in parallel with implementation (behavior-driven). They don't require the implementation to exist first — only the challenge phase does.

### 2. Apply phase: Step-sequential, role-parallel Team execution

The apply instruction directs Claude Code to:

1. Parse `tasks.md` to identify steps and their role subgroups
2. Create a Team via `TeamCreate` (once, before the first step)
3. For each step:
   a. Spawn one teammate per non-empty role subgroup in a single message (parallel)
   b. Wait for all role teammates to complete this step's tasks
   c. Run cross-challenge for this step
   d. Fix any issues found
   e. Proceed to next step

**Why step-sequential with role-parallel:**

- Steps are inherently ordered (step 2 builds on step 1's output). Sequential between steps is correct.
- Within a step, roles touch different file types. Parallel is safe and fast.
- Cross-challenge per step catches issues early — before they propagate to later steps.
- The Team persists across steps — teammates are reused, not re-spawned.

### 3. Single worktree per change (not per-teammate)

The change already runs in a worktree (e.g., `.claude/worktrees/<name>`). All teammates operate within this same worktree rather than spawning sub-worktrees.

**Why shared worktree:**

- Roles touch different file types (source files vs. test files vs. docs). Conflict risk is low.
- Eliminates the multi-worktree merge problem entirely.
- The tester can immediately run tests against the implementer's code once the challenge phase begins.
- Simpler — no worktree lifecycle management per teammate.

**Risk**: If roles occasionally touch the same files (e.g., implementer and tester both modify a shared fixture), sequential fallback handles it. The design template's "Conflict Zones" section identifies these cases upfront.

### 4. Cross-challenge phase protocol

After parallel work completes, each teammate reviews another's output:

| Reviewer | Reviews | Checks |
|----------|---------|--------|
| Implementer | Tests | Coverage gaps, edge cases, test accuracy |
| Tester | Documentation | Docs match actual behavior, examples work |
| Documenter | Implementation | Code clarity, naming, matches spec intent |

Each reviewer sends findings via `SendMessage`. The coordinator collects findings, creates fix tasks, and assigns them. This continues until all challenges pass.

**Why circular review over centralized:**

- Distributes review load — no single bottleneck.
- Each reviewer has domain expertise relevant to what they're checking.
- Circular ensures every artifact gets reviewed by someone who didn't write it.

### 5. Graceful degradation for single-agent execution

If Team is unavailable or the task list is small enough that parallelism adds overhead:

- The role headings are just `##` headings — a single agent can work through them sequentially.
- The challenge phase becomes self-review: the agent reviews its own work across all three concerns.
- No special markup or annotations needed — the format is backward-compatible.

### 6. Design template: Parallelization Strategy section

The design template gains a new section between Decisions and Risks:

```markdown
## Parallelization Strategy

### Independent Concerns
<!-- Which implementation, test, and documentation work can proceed in parallel? -->

### Conflict Zones
<!-- Files or modules where multiple roles might need to edit the same file -->

### Role Assignments
<!-- Suggested breakdown: what belongs to implementer vs. tester vs. documenter -->
```

This forces the design author to think about role separation before tasks are written.

## Risks / Trade-offs

- **[Tests written from specs may not match implementation details]** → Mitigated by the cross-challenge phase: tester runs tests against actual implementation and adjusts. Tests are written behavior-first (from specs), then validated against code.

- **[Shared worktree file conflicts between roles]** → Mitigated by natural file separation (source vs. test vs. doc files) and the design template's "Conflict Zones" section. Rare conflicts are handled in the challenge phase.

- **[Over-parallelization of small changes]** → Mitigated by graceful degradation: single-role changes run sequentially with no overhead. The schema doesn't force parallelism.

- **[Challenge phase adds time for simple changes]** → The cross-challenge can be skipped for trivial changes (single-file fixes). The apply instruction includes a threshold: if fewer than N tasks, skip team orchestration entirely.

- **[Increased apply instruction complexity]** → The orchestration logic is more complex than sequential execution. → Mitigation: the instruction is structured as a numbered algorithm with clear phases (parallel work → challenge → fix).

## Open Questions

- What is the threshold for skipping team orchestration? (e.g., fewer than 5 tasks → single-agent mode)
- Should the challenge phase be mandatory or optional (user-configurable via `config.yaml` rules)?
- If a challenge finding requires significant rework, does the original author fix it or does the reviewer?
