# Ralph + GitHub Spec Kit

**Professional spec-driven development** meets **autonomous AI execution**.

Use [GitHub Spec Kit](https://github.com/github/spec-kit) to create detailed specifications through AI conversation, then let Ralph autonomously execute them using GitHub Copilot CLI.

---

## Why This Integration?

- ✅ **Spec Kit**: Mature, conversational spec creation with multi-agent support
- ✅ **Ralph**: Autonomous execution loop that works through user stories systematically
- ✅ **Best of Both**: Professional planning + autonomous implementation
- ✅ **AI-Powered Conversion**: Uses Copilot CLI like ralph-tui (not brittle regex)

**Conversion Philosophy**: Following ralph-tui's approach, we use AI skills for conversion instead of regex parsing. This provides schema validation, format flexibility, and helpful error messages.

---

## Quick Start

```bash
# 1. Verify dependencies
npm run setup

# 2. Create spec with Spec Kit (in your AI editor like VS Code)
uvx --from git+https://github.com/github/spec-kit.git specify init my-project
# Then use: /speckit.specify, /speckit.plan, /speckit.tasks

# 3. Convert Spec Kit output to Ralph format
npm run convert specs/001-my-project

# 4. Run Ralph autonomous execution
npm run ralph
```

Or use the guided launcher:
```bash
npm run start    # Interactive workflow
```

---

## Prerequisites

### All Platforms
- **[GitHub Copilot CLI](https://docs.github.com/en/copilot/using-github-copilot/using-github-copilot-in-the-command-line)** - For autonomous execution
- **Active Copilot subscription** - Required for AI assistance
- **Node.js 18+** - For Ralph scripts (`node --version`)
- **Git repository** - Ralph commits progress automatically
- **[uv/uvx](https://github.com/astral-sh/uv)** - For Spec Kit (`pip install uv`)

### Platform-Specific
- **Unix/Mac/Linux**: `jq` for JSON parsing (`brew install jq` or `apt-get install jq`)
- **Windows**: PowerShell 5.1+ (built-in, no jq needed)

---

## Complete Workflow

### Step 1: Create Specification with Spec Kit

Initialize your project:
```bash
uvx --from git+https://github.com/github/spec-kit.git specify init restaurant-chatbot
cd restaurant-chatbot
```

In your AI editor (VS Code, Cursor, etc.), use Spec Kit commands:

1. **`/speckit.specify`** - Have a conversation to create `spec.md` with:
   - User stories with acceptance criteria
   - Priority levels (P1, P2, P3)
   - Success metrics

2. **`/speckit.plan`** - Generate `plan.md` with:
   - Technical architecture
   - Implementation approach
   - Technology choices

3. **`/speckit.tasks`** - Create `tasks.md` with:
   - Actionable task breakdown
   - Parallelization markers

All files go to `specs/###-project-name/` folder.

### Step 2: Convert to Ralph Format

```bash
# Convert Spec Kit output to prd.json (AI-powered via Copilot CLI)
npm run convert specs/001-restaurant-chatbot
```

**How it works:** Uses GitHub Copilot CLI (like ralph-tui) to intelligently convert Spec Kit specs to prd.json format. This AI-powered approach:
- Handles format variations gracefully
- Validates schema automatically
- Maps user stories with priorities
- Extracts acceptance criteria from Given/When/Then scenarios
- More robust than regex parsing

This generates `prd.json` in the current directory.
   - Story-to-task mapping

Output structure:
```
restaurant-chatbot/
├── specs/001-restaurant-chatbot/
│   ├── spec.md      # User stories & acceptance criteria
│   ├── plan.md      # Technical plan
│   └── tasks.md     # Task breakdown
```

### Step 2: Convert to Ralph Format

```bash
# In the Ralph project directory
node speckit-to-prd.js path/to/specs/001-restaurant-chatbot

# Or using npm script
npm run convert path/to/specs/001-restaurant-chatbot
```

This generates `prd.json` that Ralph understands:
```json
{
  "projectName": "Restaurant Chatbot",
  "description": "AI-powered chatbot for restaurants",
  "branchName": "ralph/001-restaurant-chatbot",
  "qualityCheck": "npm run build && npm test",
  "userStories": [
    {
      "id": 1,
      "title": "User can ask about menu items",
      "priority": 1,
      "acceptanceCriteria": [
        "Chatbot responds to menu queries",
        "Answers include prices and descriptions"
      ],
      "passes": false
    }
  ]
}
```

### Step 3: Run Ralph Autonomous Execution

```bash
# Platform auto-detection
npm run ralph

# Or direct execution
bash ralph.sh              # Unix/Mac/Linux
powershell -File ralph.ps1 # Windows
```

Ralph will:
1. Load `prd.json` user stories
2. Work through them by priority (P1 → P2 → P3)
3. Use GitHub Copilot CLI for each story
4. Commit progress after each iteration
5. Check quality gates before marking complete
6. Track learnings in `progress.txt`

---

## Configuration

Ralph supports configuration via **command-line parameters** or **environment variables**.

| Parameter | Environment Variable | Default | Description |
|-----------|---------------------|---------|-------------|
| `--model` / `-m` | `COPILOT_MODEL` | gpt-4 | AI model to use |
| `--max-iterations` / `-i` | `MAX_ITERATIONS` | 10 | Maximum attempts per feature |
| `--temperature` / `-t` | `COPILOT_TEMPERATURE` | 0.7 | Creativity level (0.0-1.0) |

**Priority:** Command-line parameters > Environment variables > Defaults

### Configuration Examples

**Use defaults:**
```bash
./ralph.sh
.\ralph.ps1
```

**Using command-line parameters (recommended):**
```bash
# Unix/Mac/Linux
./ralph.sh --model claude-3.5-sonnet --max-iterations 20
./ralph.sh -m gpt-4 -i 15 -t 0.5

# Windows PowerShell
.\ralph.ps1 -Model claude-3.5-sonnet -MaxIterations 20
.\ralph.ps1 -Model gpt-4 -MaxIterations 15 -Temperature 0.5
```

**Using environment variables:**
```bash
# Unix/Mac/Linux - one-time override
MAX_ITERATIONS=20 COPILOT_MODEL="claude-3.5-sonnet" ./ralph.sh

# Unix/Mac/Linux - session-wide
export MAX_ITERATIONS=15
export COPILOT_MODEL="gpt-4"
export COPILOT_TEMPERATURE=0.5
./ralph.sh

# Windows PowerShell - one-time override
$env:MAX_ITERATIONS=20; $env:COPILOT_MODEL="claude-3.5-sonnet"; .\ralph.ps1

# Windows PowerShell - session-wide
$env:MAX_ITERATIONS=15
$env:COPILOT_MODEL="gpt-4"
$env:COPILOT_TEMPERATURE=0.5
.\ralph.ps1
```

**Help information:**
```bash
./ralph.sh --help
.\ralph.ps1 -Help
```

### Supported Models

- **`gpt-4`** - Best for complex reasoning and code generation (default)
- **`gpt-3.5-turbo`** - Faster, more cost-effective for simpler tasks
- **`claude-3.5-sonnet`** - Alternative model with strong reasoning
- **`o1-preview`** - Advanced reasoning (slower, best for complex problems)

### Temperature Guide

- **0.0-0.3** - Deterministic, focused (best for bug fixes)
- **0.4-0.7** - Balanced creativity (default, good for features)
- **0.8-1.0** - More creative (experimental solutions)

---

---

## Usage Examples

### Complete Workflow (Recommended)

```bash
# Interactive guided launcher
npm run start

# Follow the prompts to:
# 1. Verify dependencies
# 2. Choose Spec Kit workflow or convert existing spec
# 3. Run Ralph execution
```

### Manual Step-by-Step

```bash
# 1. Create spec with Spec Kit in your AI editor
uvx --from git+https://github.com/github/spec-kit.git specify init my-app
# Use /speckit.specify, /speckit.plan, /speckit.tasks

# 2. Convert to Ralph format
node speckit-to-prd.js specs/001-my-app

# 3. Run Ralph (10 iterations default)
npm run ralph

# Or with custom iterations
bash ralph.sh 20                        # Unix/Mac
powershell -File ralph.ps1 -MaxIterations 20  # Windows
```

### Platform-Specific Commands

```bash
# Auto-detect platform (works everywhere)
npm run setup
npm run convert specs/001-my-app
npm run ralph

# Explicit platform (if auto-detection doesn't work)
npm run setup:unix   # or setup:win
npm run ralph:unix   # or ralph:win
npm run start:unix   # or start:win
```

---

## Advanced Usage

### Custom PRD Without Spec Kit

You can manually create `prd.json` if you prefer:

```json
{
  "projectName": "My Project",
  "description": "Project description",
  "branchName": "ralph/my-feature",
  "qualityCheck": "npm test",
  "userStories": [
    {
      "id": 1,
      "title": "Story title",
      "priority": 1,
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2"
      ],
      "passes": false
    }
  ]
}
```

Then run `npm run ralph` directly.

### Archiving & Branch Management

Ralph automatically archives previous runs when you change branches:
```
archive/
├── 2026-01-19-old-feature/
│   ├── prd.json
│   └── progress.txt
```

### Customizing Copilot Instructions

Edit [prompt.md](prompt.md) to change how Copilot approaches each iteration:
- Modify coding standards
- Add framework-specific guidance
- Change commit message format
- Adjust quality criteria

---

## Troubleshooting

### "copilot command not found"

```bash
# Install GitHub Copilot CLI
npm install -g @githubnext/github-copilot-cli

# Authenticate
copilot auth
```

### "jq command not found" (Unix/Mac/Linux only)

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq  # Debian/Ubuntu
sudo yum install jq      # RedHat/CentOS
```

### "uvx command not found"

```bash
# Install uv (for Spec Kit)
pip install uv

# Or with pipx
pipx install uv
```

### Ralph Runs But Nothing Happens

1. Check `prd.json` exists and has valid user stories
2. Verify Copilot CLI is authenticated: `copilot auth status`
3. Check `progress.txt` for errors
4. Ensure you're in a git repository: `git status`

### Spec Kit Conversion Fails

```bash
# Verify Spec Kit files exist
ls specs/001-my-project/
# Should show: spec.md, plan.md, tasks.md

# Check spec.md has user stories
grep "## User Story" specs/001-my-project/spec.md

# Run converter with full path
node speckit-to-prd.js "$(pwd)/specs/001-my-project"
```

---

## Contributing

This project combines two powerful tools:
- **[GitHub Spec Kit](https://github.com/github/spec-kit)** - Spec creation framework
- **[copilot-ralph](https://github.com/brenbuilds1/copilot-ralph)** - Original Ralph loop

Contributions welcome for:
- Improved Spec Kit parsing (edge cases)
- Better quality check detection
- Additional platform support
- Documentation improvements

---

## License

MIT

---

## Credits

- **Spec Kit** by GitHub - Spec-driven development framework
- **copilot-ralph** by [brenbuilds1](https://github.com/brenbuilds1) - Original autonomous loop concept
- **ralph-tui** by [subsy](https://github.com/subsy) - PRD creation inspiration

## How It Works

### 1. Structured PRD Creation

Run `npm run create-prd` to start a **7-phase guided conversation**:

- **Phase 1**: Project Overview (name, description, audience)
- **Phase 2**: Quick or Detailed Mode selection
- **Phase 3**: Technology preferences
- **Phase 4**: Features discussion (the main phase)
- **Phase 4L**: Auto-calculates user story count
- **Phase 5**: Technical details summary
- **Phase 6**: Success criteria
- **Phase 7**: Review and generate prd.json

The tool asks structured questions, adapts based on your answers, and automatically generates 3-7 focused user stories.

### 2. Autonomous Ralph Loop

Run `./ralph.sh` to execute the generated stories autonomously:

- Ralph works through each user story sequentially
- Fresh context each iteration (uses `prd.json` + `progress.txt`)
- Commits progress after each story
- Runs quality checks before marking stories complete
- Stops when all stories pass or max iterations reached

### 3. Memory & State

- **prd.json**: User stories with acceptance criteria
- **progress.txt**: Learnings from each iteration
- **Git history**: Committed changes for each story

## Files

### Core Scripts

| File | Purpose | Platform |
|------|---------|----------|
| `create-prd.js` | 7-phase PRD creation wizard | Cross-platform (Node.js) |
| `start.sh` | Complete workflow launcher | Unix/Mac/Linux |
| `start.ps1` | Complete workflow launcher | Windows |
| `setup.sh` | Verify dependencies | Unix/Mac/Linux |
| `setup.ps1` | Verify dependencies | Windows |
| `ralph.sh` | Main autonomous execution loop | Unix/Mac/Linux |
| `ralph.ps1` | Main autonomous execution loop | Windows |
| `prompt.md` | Instructions for each Copilot iteration | All platforms |

### Generated Files

| File | Purpose |
|------|---------|
| `prd.json` | User stories with acceptance criteria |
| `progress.txt` | Learnings accumulated across iterations |
| `archive/` | Previous runs when branch changes |

### Supporting Files

| File | Purpose |
|------|---------|
| `lib/prompts.js` | Terminal utilities for interactive prompts |
| `prd.json.example` | Example PRD structure |

## Example PRD

```json
{
  "projectName": "Task Manager",
  "description": "Simple task management app with tags and due dates",
  "branchName": "ralph/task-manager",
  "qualityCheck": "npm test",
  "userStories": [
    {
      "id": "US-001",
      "title": "Create task with title and description",
      "priority": 1,
      "description": "Users can add new tasks with title and optional description",
      "acceptanceCriteria": [
        "Form accepts task title (required)",
        "Form accepts task description (optional)",
        "Task is saved to database",
        "User sees confirmation message"
      ],
      "passes": false
    }
  ]
}
```

## Best Practices

- **Keep stories small**: Each story should be completable in one Ralph iteration (~30 min)
- **Make criteria testable**: Use specific, verifiable acceptance criteria
- **Review prd.json**: Edit the generated file before running ralph.sh if needed
- **Monitor progress.txt**: Check learnings to understand what Ralph has tried
- **Use quality checks**: Configure meaningful test commands for validation

## Credits

- [copilot-ralph](https://github.com/brenbuilds1/copilot-ralph) - Original Ralph loop implementation
- [ralph-tui](https://github.com/subsy/ralph-tui) - PRD creation inspiration
- [glm_autocoder](https://github.com/chaitanyame/glm_autocoder) - Conversational spec creation pattern

## License

MIT
