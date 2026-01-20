# Copilot-Ralph Enhanced

Interactive PRD creation + autonomous Ralph loop for GitHub Copilot CLI.

## Quick Start

```bash
# 1. Setup (verify dependencies)
./setup.sh

# 2. Create PRD interactively
node create-prd.js

# 3. Run Ralph loop
./ralph.sh
```

## Prerequisites

- [GitHub Copilot CLI](https://github.com/github/copilot-cli) installed (`npm install -g @github/copilot`)
- Active Copilot subscription
- `jq` installed (`brew install jq` on macOS, `apt-get install jq` on Linux)
- Node.js 18+ (`node --version`)
- Git repository (Ralph commits progress)

## How It Works

1. **Create PRD**: Interactive prompts generate `prd.json` with user stories
2. **Ralph Loop**: Autonomous iterations implementing one story at a time
3. **Memory**: Persists via `prd.json`, `progress.txt`, and git history

## Files

| File | Purpose |
|------|---------|
| `setup.sh` | Verify dependencies |
| `create-prd.js` | Interactive PRD creation wizard |
| `ralph.sh` | Main execution loop |
| `prompt.md` | Instructions for each Copilot iteration |
| `prd.json` | Your user stories (generated) |
| `progress.txt` | Learnings from iterations (auto-created) |

## License

MIT
