## 1. Update Tasks Template

- [x] 1.1 Replace `templates/tasks.md` with role-grouped format (Implementation, Tests, Documentation headings)
- [x] 1.2 Update the tasks artifact `instruction` in `schema.yaml` to direct role-based grouping and explain the format

## 2. Update Design Template

- [x] 2.1 Add "Parallelization Strategy" section to `templates/design.md` with Independent Concerns, Conflict Zones, and Role Assignments subsections
- [x] 2.2 Update the design artifact `instruction` in `schema.yaml` to reference the new section

## 3. Rewrite Apply Phase

- [x] 3.1 Rewrite the `apply.instruction` in `schema.yaml` with the role-based team orchestration algorithm (team creation, role-teammate spawning, parallel execution, cross-challenge phase, fix loop)
- [x] 3.2 Include threshold-based team activation logic (skip team for small changes)
- [x] 3.3 Include graceful degradation fallback for single-agent mode

## 4. Update Proposal Template

- [x] 4.1 Add concurrency considerations guidance to the Impact section in `templates/proposal.md`

## 5. Validate

- [x] 5.1 Run `openspec schema validate claude-spec-driven` to verify schema integrity
- [x] 5.2 Create a throwaway test change and inspect rendered instructions for each artifact
