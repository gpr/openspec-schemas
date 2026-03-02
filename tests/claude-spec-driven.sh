#!/usr/bin/env bash

SCHEMA_NAME=${1:-"claude-spec-driven"}
TEST_CHANGE_NAME="${SCHEMA_NAME}-test"

rm -rf tmp/${TEST_CHANGE_NAME}

mkdir -p tmp/${TEST_CHANGE_NAME}/{openspec/schemas,instructions}
cp -aR $SCHEMA_NAME tmp/${TEST_CHANGE_NAME}/openspec/schemas/

cd tmp/${TEST_CHANGE_NAME}

openspec init --tools claude
openspec new change --schema "$SCHEMA_NAME" "$TEST_CHANGE_NAME"

touch openspec/changes/${TEST_CHANGE_NAME}/{README.md,proposal.md,specs.md,design.md,apply.md}

cat <<EOL > openspec/changes/${TEST_CHANGE_NAME}/tasks.md
# Tasks for ${TEST_CHANGE_NAME}
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3
EOL

openspec instructions --change "$TEST_CHANGE_NAME" proposal > "instructions/proposal.md"
openspec instructions --change "$TEST_CHANGE_NAME" specs > "instructions/specs.md"
openspec instructions --change "$TEST_CHANGE_NAME" design > "instructions/design.md"
openspec instructions --change "$TEST_CHANGE_NAME" tasks > "instructions/tasks.md"
openspec instructions --change "$TEST_CHANGE_NAME" apply > "instructions/apply.md"
