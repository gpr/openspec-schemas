## ADDED Requirements

### Requirement: Cross-challenge phase after parallel work

The apply instruction SHALL include a cross-challenge phase that begins after all role teammates complete their tasks. Each teammate reviews another teammate's output using a circular review assignment.

#### Scenario: Challenge phase triggers after all roles complete

- **WHEN** all role teammates have completed their assigned tasks
- **THEN** the coordinator initiates the cross-challenge phase and assigns each teammate a review target

#### Scenario: Challenge phase skipped for single-agent execution

- **WHEN** the apply phase runs in single-agent mode (no Team spawned)
- **THEN** no cross-challenge phase is executed

### Requirement: Circular review assignment

The cross-challenge phase SHALL use a circular review pattern: implementer reviews tests, tester reviews documentation, documenter reviews implementation.

#### Scenario: Review assignments follow circular pattern

- **WHEN** the cross-challenge phase begins with all three role teammates
- **THEN** the implementer is assigned to review tests, the tester is assigned to review documentation, and the documenter is assigned to review implementation

#### Scenario: Two-role review assignment

- **WHEN** the cross-challenge phase begins with only two role teammates (e.g., implementation and tests)
- **THEN** each teammate reviews the other's output (bidirectional)

### Requirement: Challenge review criteria

Each reviewer SHALL check specific criteria relevant to their expertise and the artifact under review.

#### Scenario: Implementer reviews tests

- **WHEN** the implementer reviews the tester's output
- **THEN** the review checks for coverage gaps, missing edge cases, and test accuracy against the implementation

#### Scenario: Tester reviews documentation

- **WHEN** the tester reviews the documenter's output
- **THEN** the review checks that documentation matches actual behavior and examples are accurate

#### Scenario: Documenter reviews implementation

- **WHEN** the documenter reviews the implementer's output
- **THEN** the review checks for code clarity, naming consistency, and alignment with spec intent

### Requirement: Challenge findings communicated via SendMessage

Reviewers SHALL communicate findings to the coordinator via `SendMessage`. The coordinator collects all findings and creates fix tasks if needed.

#### Scenario: Reviewer reports findings

- **WHEN** a reviewer identifies issues during the cross-challenge phase
- **THEN** the reviewer sends findings via `SendMessage` to the coordinator with specific issues and suggested fixes

#### Scenario: No issues found

- **WHEN** a reviewer finds no issues during the cross-challenge phase
- **THEN** the reviewer sends an approval message via `SendMessage` to the coordinator

### Requirement: Fix tasks created from challenge findings

The coordinator SHALL create new tasks from challenge findings and assign them to the appropriate teammate for resolution.

#### Scenario: Fix tasks assigned to original author

- **WHEN** the coordinator receives challenge findings identifying issues
- **THEN** fix tasks are created and assigned to the teammate who authored the artifact with issues

#### Scenario: All challenges pass

- **WHEN** all reviewers send approval messages with no issues
- **THEN** the coordinator marks the apply phase as complete with no additional fix tasks
