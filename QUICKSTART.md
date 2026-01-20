# Quick Start Guide

## Initial Setup

1. **Install dependencies**:
   ```bash
   # Install GitHub Copilot CLI
   npm install -g @github/copilot
   
   # Install jq
   # macOS:
   brew install jq
   
   # Linux:
   sudo apt-get install jq
   
   # Windows (WSL):
   sudo apt-get install jq
   ```

2. **Initialize git** (if not already):
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

3. **Run setup**:
   ```bash
   ./setup.sh
   ```

## Create Your First PRD

```bash
node create-prd.js
```

You'll be prompted for:
- Feature name (e.g., "Landing Page")
- Project name
- Description
- Number of user stories (3-10 recommended)
- Quality check command
- Git branch name

This generates `prd.json`.

## Run Ralph Loop

```bash
./ralph.sh
```

Ralph will:
1. Read `prd.json` and `progress.txt`
2. Pick the highest priority incomplete story
3. Implement it using GitHub Copilot CLI
4. Commit changes
5. Update `prd.json` to mark story complete
6. Repeat until all stories are done

## Monitor Progress

- **Check status**: `cat prd.json | jq '.userStories[] | {id, title, passes}'`
- **View learnings**: `cat progress.txt`
- **See commits**: `git log --oneline`

## Tips

- Start with 3-5 user stories for your first run
- Keep stories small and focused
- Each iteration is a fresh Copilot instance
- Review `progress.txt` to see what Ralph learned
- You can edit `prd.json` between iterations

## Example Workflow

```bash
# 1. Setup
./setup.sh

# 2. Create PRD
node create-prd.js
# Answer: "Simple calculator web app"
# Stories: 3

# 3. Review PRD
cat prd.json

# 4. Run Ralph (max 10 iterations)
./ralph.sh

# 5. Check results
git log --oneline
cat progress.txt
```

## Troubleshooting

**"copilot not found"**
- Install: `npm install -g @github/copilot`
- Authenticate: `copilot`

**"jq not found"**
- Install: `brew install jq` (macOS) or `apt-get install jq` (Linux)

**"Not a git repo"**
- Run: `git init`

**Ralph not progressing**
- Check `progress.txt` for errors
- Review last commit: `git log -1 --stat`
- Verify story criteria in `prd.json`
