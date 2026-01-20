# Project Structure with Spec Kit + Ralph

This shows the complete folder structure when using this framework for a real project.

## Complete Directory Layout

```
my-restaurant-chatbot/              # Your actual project
├── specs/                          # Spec Kit specifications (git-tracked)
│   ├── 001-chat-reservations/
│   │   ├── spec.md                 # User stories, acceptance criteria
│   │   ├── plan.md                 # Technical architecture
│   │   └── tasks.md                # Task breakdown
│   ├── 002-menu-recommendations/
│   │   ├── spec.md
│   │   ├── plan.md
│   │   └── tasks.md
│   └── 003-multilingual-support/
│       └── spec.md
│
├── src/                            # Your actual code (created by Ralph)
│   ├── components/
│   │   ├── ChatInterface.tsx
│   │   ├── ReservationForm.tsx
│   │   └── MenuDisplay.tsx
│   ├── services/
│   │   ├── reservationService.ts
│   │   ├── menuService.ts
│   │   └── translationService.ts
│   ├── utils/
│   │   ├── dateParser.ts
│   │   └── languageDetector.ts
│   └── index.ts
│
├── tests/                          # Tests written by Ralph
│   ├── components/
│   ├── services/
│   └── integration/
│
├── archive/                        # Previous Ralph runs (git-ignored)
│   ├── 2026-01-15-001-chat-reservations/
│   │   ├── prd.json
│   │   └── progress.txt
│   └── 2026-01-18-002-menu-recommendations/
│       ├── prd.json
│       └── progress.txt
│
├── .tmp/                           # Temporary converter files (git-ignored)
│   └── conversion-prompt.txt
│
├── node_modules/                   # Dependencies (git-ignored)
│
├── prd.json                        # Current Ralph PRD (git-tracked during active work)
├── progress.txt                    # Current Ralph progress log (git-tracked)
├── .ralph-last-branch             # Branch tracking (git-ignored)
│
├── ralph.sh                        # Ralph framework (from this repo)
├── ralph.ps1
├── setup.sh
├── setup.ps1
├── start.sh
├── start.ps1
├── speckit-to-prd.js
├── test-converter.js
├── prompt.md
│
├── package.json                    # Your project + framework scripts
├── tsconfig.json                   # Your project config
├── .gitignore
└── README.md
```

## Workflow Example

### Phase 1: Create Specification with Spec Kit

```bash
# Initialize Spec Kit in your project
cd my-restaurant-chatbot
uvx --from git+https://github.com/github/spec-kit.git specify init .

# Use AI editor (VS Code, Cursor, etc.) with Spec Kit commands
# /speckit.specify - Creates specs/001-chat-reservations/spec.md
# /speckit.plan    - Creates specs/001-chat-reservations/plan.md
# /speckit.tasks   - Creates specs/001-chat-reservations/tasks.md
```

**Result:** `specs/001-chat-reservations/` folder with complete specification

### Phase 2: Convert to Ralph Format

```bash
# Convert Spec Kit output to prd.json
npm run convert specs/001-chat-reservations
```

**Generated files:**
- `prd.json` - Ralph-compatible PRD with user stories
- `.tmp/conversion-prompt.txt` - Temporary AI prompt (auto-deleted)

### Phase 3: Run Ralph Autonomous Loop

```bash
# Ralph executes the PRD autonomously
npm run ralph

# Or with more iterations
bash ralph.sh 20
```

**What Ralph creates:**
- `src/` - Implementation code
- `tests/` - Test files
- `progress.txt` - Iteration logs and learnings
- Git commits - One per completed user story
- `prd.json` - Updated with `passes: true` for completed stories

### Phase 4: Next Feature

```bash
# Create new spec
# /speckit.specify - Creates specs/002-menu-recommendations/

# Convert and run
npm run convert specs/002-menu-recommendations
npm run ralph
```

**What happens:**
- Old `prd.json` + `progress.txt` archived to `archive/2026-01-19-001-chat-reservations/`
- New `prd.json` created for feature 002
- Ralph starts fresh on new feature

## File Ownership

### Created by You (Manual)
- `specs/*/spec.md` - Via Spec Kit AI commands
- `specs/*/plan.md` - Via Spec Kit AI commands
- `specs/*/tasks.md` - Via Spec Kit AI commands
- `package.json` - Your project dependencies

### Created by Converter (AI-Generated)
- `prd.json` - From Spec Kit specs via Copilot CLI
- `.tmp/*` - Temporary prompt files (auto-cleanup)

### Created by Ralph (AI-Generated)
- `src/**/*` - Your application code
- `tests/**/*` - Your test files
- `progress.txt` - Iteration logs and learnings
- Git commits - Feature implementation history

### Framework Files (From This Repo)
- `ralph.sh`, `ralph.ps1` - Main autonomous loop
- `setup.sh`, `setup.ps1` - Dependency checker
- `start.sh`, `start.ps1` - Guided launcher
- `speckit-to-prd.js` - AI-powered converter
- `prompt.md` - Ralph agent instructions

## Git Tracking Strategy

### Tracked (Committed)
```gitignore
# Spec Kit specifications
specs/

# Current work
prd.json
progress.txt

# Framework
ralph.sh
ralph.ps1
setup.sh
setup.ps1
start.sh
start.ps1
speckit-to-prd.js
prompt.md
package.json
README.md

# Your code (created by Ralph)
src/
tests/
```

### Ignored (.gitignore)
```gitignore
# Ralph archives (local history)
archive/

# Temporary files
.tmp/
.ralph-last-branch

# Dependencies
node_modules/

# Build outputs
dist/
build/
```

## Multi-Feature Timeline

```
Week 1: Feature 001 (Chat Reservations)
├── Day 1: Spec Kit → specs/001-chat-reservations/spec.md
├── Day 2: Convert → prd.json (3 user stories)
├── Day 3-4: Ralph runs → src/components/, src/services/
└── Day 5: Complete → All stories pass: true

Week 2: Feature 002 (Menu Recommendations)
├── Archive 001 → archive/2026-01-20-001-chat-reservations/
├── Spec Kit → specs/002-menu-recommendations/spec.md
├── Convert → prd.json (4 user stories)
└── Ralph runs → Builds on existing src/

Week 3: Feature 003 (Multilingual Support)
├── Archive 002 → archive/2026-01-27-002-menu-recommendations/
├── Spec Kit → specs/003-multilingual-support/spec.md
└── Ralph runs → Adds i18n to existing code
```

## Comparison: With vs Without Spec Kit

### Without Spec Kit (Manual PRD)
```
my-project/
├── prd.json              # You write this manually
├── ralph.sh
└── src/                  # Ralph builds this
```
**Pros:** Simpler, direct
**Cons:** Manual PRD writing, no structured planning

### With Spec Kit (Integrated)
```
my-project/
├── specs/                # Spec Kit creates these (AI conversation)
│   └── 001-feature/
│       ├── spec.md       # Detailed, reviewed specifications
│       ├── plan.md       # Architecture decisions documented
│       └── tasks.md      # Task breakdown
├── prd.json              # Auto-generated from spec.md
├── ralph.sh
└── src/                  # Ralph builds this
```
**Pros:** Professional specs, AI-assisted planning, auditable decisions
**Cons:** Extra conversion step, more files

## Real-World Example Sizes

**Small Project (SaaS Feature):**
```
specs/001-user-auth/
├── spec.md           (~150 lines, 3 user stories)
├── plan.md           (~100 lines)
└── tasks.md          (~50 lines, 12 tasks)

prd.json              (1 KB, 3 stories)
src/                  (~500 lines created by Ralph)
tests/                (~300 lines created by Ralph)
```

**Medium Project (E-commerce Module):**
```
specs/001-shopping-cart/
├── spec.md           (~400 lines, 8 user stories)
├── plan.md           (~250 lines)
└── tasks.md          (~120 lines, 35 tasks)

prd.json              (3 KB, 8 stories)
src/                  (~2000 lines created by Ralph)
tests/                (~1200 lines created by Ralph)
```

## Key Benefits of This Structure

1. **Separation of Concerns**
   - `specs/` = Planning (human-reviewed AI conversations)
   - `prd.json` = Execution format (machine-readable)
   - `src/` = Implementation (AI-generated code)

2. **Version Control**
   - Specs tracked in git = Audit trail of decisions
   - Ralph commits = Implementation history
   - Archive = Local experimentation history

3. **Iterative Development**
   - Each feature = New spec folder
   - Ralph archives previous runs
   - Build incrementally on existing codebase

4. **Team Collaboration**
   - Specs are reviewable before implementation
   - Ralph logs show what was tried
   - Git history shows evolution

5. **Flexibility**
   - Can edit prd.json manually if needed
   - Can re-convert from specs if requirements change
   - Can run Ralph multiple times on same PRD
