---
description: Convert Spec Kit specifications and tasks to Ralph's prd.json format for autonomous execution
mode: speckit.converttaskstoprd
handoffs:
  - label: Start Ralph Execution
    agent: file.view
    prompt: "View prd.json and run Ralph with ./ralph.sh or .\ralph.ps1"
---

## User Input

```text
$ARGUMENTS
```

Optional: Specify feature directory path (e.g., `specs/001-feature-name`) or use current directory.

## Outline

You are converting Spec Kit specifications into Ralph's prd.json format for autonomous code implementation.

### 1. Locate Feature Directory

- If `$ARGUMENTS` is provided, use it as the feature directory path
- Otherwise, search for `spec.md` in:
  - Current directory
  - `./specs/*` subdirectories
  - Prompt user if multiple or none found

### 2. Load Required Documents

**Required Files:**
- `spec.md` - Contains user stories and acceptance criteria
- `tasks.md` - Contains task breakdown (optional but recommended)

**Load these files** and parse their content.

### 3. Parse spec.md Structure

Extract the following from `spec.md`:

**Project Metadata:**
```regex
Title: /^# (.+)/m
Description: First paragraph after "## Overview" section
```

**User Stories:**
```regex
Pattern: ### User Story (\d+) - (.+?) \(Priority: P(\d+)\)
```

For each user story, extract:
- **ID**: User Story number (1, 2, 3...)
- **Title**: Story title text
- **Priority**: P1, P2, or P3
- **Acceptance Criteria**: Parse scenarios under "**Acceptance Scenarios:**"

**Acceptance Scenario Format:**
```regex
Pattern: \d+\.\s+\*\*Given\*\*(.*?)\*\*When\*\*(.*?)\*\*Then\*\*(.*?)
```

Combine as: `"Given{given}, When{when}, Then{then}"`

### 4. Parse tasks.md (if exists)

**Task Format:**
```regex
Pattern: \[T\d+\]\s+\[P\d+\]\s+\[US(\d+)\]\s+(.+)
```

Extract:
- Task ID (T001, T002...)
- Priority (P1, P2, P3)
- User Story reference ([US1], [US2]...)
- Task description

**Map tasks to user stories** by the [USn] label.

If tasks.md doesn't exist, add a note to acceptance criteria: "Task: [From acceptance criteria]"

### 5. Detect Quality Check Command

Analyze spec.md content for technology keywords:

- **TypeScript/React/Next.js** → `npm run typecheck && npm test && npm run build && npm run lint`
- **Python** → `python -m pytest && python -m mypy .`
- **Rust** → `cargo test && cargo clippy`
- **Go** → `go test ./... && go vet ./...`
- **Default** → `npm test`

### 6. Generate prd.json Structure

Create JSON with this **exact structure**:

```json
{
  "name": "[Project title from spec.md]",
  "description": "[First paragraph of Overview section]",
  "branchName": "ralph/[feature-folder-name]",
  "qualityCheck": "[Detected command from step 5]",
  "userStories": [
    {
      "id": 1,
      "title": "[User Story title]",
      "priority": 1,
      "acceptanceCriteria": [
        "Given..., When..., Then...",
        "Task: [Task description if tasks.md exists]"
      ],
      "passes": false
    }
  ]
}
```

**Key Rules:**
- `id` and `priority` are **integers** (not strings)
- `passes` is always `false` initially
- `acceptanceCriteria` is an **array of strings**
- Merge task descriptions into `acceptanceCriteria` array
- `branchName` format: `ralph/[folder-name]` (e.g., `ralph/001-restaurant-hybrid-retrieval`)

### 7. Validate Generated PRD

Check:
- [ ] All required fields present (name, description, branchName, qualityCheck, userStories)
- [ ] At least one user story exists
- [ ] Each user story has id, title, priority, acceptanceCriteria, passes
- [ ] JSON is valid (no syntax errors)
- [ ] Priority values are 1, 2, or 3 (not P1, P2, P3 strings)

### 8. Write prd.json

**Output Location:** `./prd.json` in the current working directory

Write the JSON with 2-space indentation.

### 9. Report Completion

Display summary:

```
╔════════════════════════════════════════╗
║   Spec Kit → Ralph PRD Converter      ║
╚════════════════════════════════════════╝

✓ Generated: prd.json

Project: [name]
Branch: [branchName]
User Stories: [count]
Quality Check: [command]

Ready to run Ralph!
  ./ralph.sh --model gpt-4 --max-iterations 10
  .\ralph.ps1 -Model gpt-4 -MaxIterations 10

Next: Review prd.json and start autonomous execution
```

## Key Constraints

- **Parse markdown carefully**: Spec Kit uses specific formatting (### headers, ** bold markers)
- **Extract [USn] labels**: Tasks reference user stories via [US1], [US2] in task descriptions
- **Preserve priorities as integers**: Convert P1→1, P2→2, P3→3
- **Combine acceptance criteria + tasks**: Merge into single array for Ralph
- **Handle missing tasks.md gracefully**: Use acceptance scenarios only
- **Validate before writing**: Ensure JSON structure matches Ralph's expectations
- **Use absolute paths**: When reading/writing files
- **No placeholders**: Generate complete, ready-to-use prd.json

## Error Handling

**If spec.md not found:**
- Check `specs/*/spec.md` pattern
- List available specs if multiple found
- Prompt user to specify correct path

**If no user stories found:**
- Report error: "No user stories found in spec.md"
- Check format: Must use `### User Story N - Title (Priority: PN)`

**If JSON generation fails:**
- Validate each field before adding
- Report which field caused the error
- Show example of expected format

## Success Criteria

- [x] prd.json created in current directory
- [x] Valid JSON structure
- [x] All user stories converted
- [x] Tasks mapped to stories (if tasks.md exists)
- [x] Quality check detected correctly
- [x] Branch name follows `ralph/[feature]` pattern
- [x] Ready for Ralph execution without modifications
