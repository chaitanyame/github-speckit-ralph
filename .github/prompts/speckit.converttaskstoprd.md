Convert Spec Kit specifications and tasks to Ralph's prd.json format for autonomous execution.

---

## Overview

This prompt converts Spec Kit-generated specifications into Ralph's PRD (Product Requirements Document) format. Ralph is an autonomous code implementation framework that executes user stories in sequence.

## Input Requirements

- **spec.md**: Contains user stories with acceptance criteria
- **tasks.md** (optional): Contains task breakdown mapped to user stories

## Output Format

Generates `prd.json` with this structure:

```json
{
  "name": "Project Name",
  "description": "Project description",
  "branchName": "ralph/feature-name",
  "qualityCheck": "npm test && npm run lint",
  "userStories": [
    {
      "id": 1,
      "title": "User Story Title",
      "priority": 1,
      "acceptanceCriteria": [
        "Given..., When..., Then...",
        "Task: Implementation task"
      ],
      "passes": false
    }
  ]
}
```

## Parsing Rules

### User Stories (from spec.md)

Extract stories matching this pattern:
```
### User Story N - Title (Priority: PN)
```

For each story:
- **ID**: User Story number (integer)
- **Title**: Story description
- **Priority**: P1→1, P2→2, P3→3 (convert to integer)
- **Acceptance Criteria**: Parse Given/When/Then scenarios

### Tasks (from tasks.md)

Extract tasks matching this pattern:
```
[T001] [P1] [US1] Task description with file path
```

Map tasks to user stories using the `[USn]` label.

### Quality Check Detection

Auto-detect based on keywords in spec.md:
- **TypeScript/React/Next.js** → `npm run typecheck && npm test && npm run build && npm run lint`
- **Python** → `python -m pytest && python -m mypy .`
- **Rust** → `cargo test && cargo clippy`
- **Go** → `go test ./... && go vet ./...`
- **Default** → `npm test`

## Usage

Run: `/speckit.converttaskstoprd specs/001-feature-name`

The command will:
1. Load spec.md and tasks.md from the specified directory
2. Parse user stories and acceptance criteria
3. Map tasks to user stories
4. Generate prd.json in the current directory
5. You can then execute: `./ralph.sh` or `.\ralph.ps1`

## Integration with Ralph

After generating prd.json, Ralph will:
1. Create a feature branch (`ralph/feature-name`)
2. Execute each user story sequentially
3. Mark acceptance criteria as passing/failing
4. Run quality checks after each story
5. Commit changes incrementally

## Important Notes

- **Priority values** must be integers (1, 2, 3) not strings ("P1", "P2", "P3")
- **Acceptance criteria** is an array of strings combining scenarios + tasks
- **passes** is always `false` initially (Ralph updates this during execution)
- **branchName** must follow `ralph/[folder-name]` pattern
