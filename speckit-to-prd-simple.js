#!/usr/bin/env node
/**
 * speckit-to-prd-simple.js - Simple regex-based converter (no AI required)
 * Use this as a fallback when Copilot CLI is not available
 * 
 * Usage: node speckit-to-prd-simple.js <path-to-spec-folder>
 */

import fs from 'fs/promises';
import path from 'path';

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// Parse spec.md for user stories
function parseSpec(content) {
  const stories = [];
  const storyRegex = /### User Story (\d+) - (.+?) \(Priority: P(\d+)\)([\s\S]*?)(?=### User Story \d+|## Quality Gates|$)/g;
  
  let match;
  while ((match = storyRegex.exec(content)) !== null) {
    const [, id, title, priority, body] = match;
    
    // Extract acceptance criteria
    const criteriaMatch = body.match(/\*\*Acceptance Scenarios\*\*:([\s\S]*?)(?=###|##|$)/);
    const acceptanceCriteria = [];
    
    if (criteriaMatch) {
      const scenarioRegex = /\d+\.\s+\*\*Given\*\*(.*?)\*\*When\*\*(.*?)\*\*Then\*\*(.*?)(?=\n\d+\.|$)/gs;
      let scenarioMatch;
      
      while ((scenarioMatch = scenarioRegex.exec(criteriaMatch[1])) !== null) {
        const [, given, when, then] = scenarioMatch;
        acceptanceCriteria.push(
          `Given${given.trim()}, When${when.trim()}, Then${then.trim()}`
        );
      }
    }
    
    stories.push({
      id: parseInt(id),
      title: title.trim(),
      priority: parseInt(priority),
      acceptanceCriteria,
      passes: false
    });
  }
  
  return stories;
}

// Parse tasks.md and map to user stories
function parseTasks(content) {
  const tasksByStory = {};
  const taskRegex = /\[T\d+\]\s+\[P\d+\]\s+\[US(\d+)\]\s+(.+)/g;
  
  let match;
  while ((match = taskRegex.exec(content)) !== null) {
    const [, storyId, task] = match;
    const id = parseInt(storyId);
    
    if (!tasksByStory[id]) {
      tasksByStory[id] = [];
    }
    tasksByStory[id].push(`Task: ${task.trim()}`);
  }
  
  return tasksByStory;
}

// Detect quality check based on tech stack
function detectQualityCheck(content) {
  const lower = content.toLowerCase();
  
  if (lower.includes('typescript') || lower.includes('react') || lower.includes('next')) {
    return 'npm run typecheck && npm test && npm run build && npm run lint';
  } else if (lower.includes('python')) {
    return 'python -m pytest && python -m mypy .';
  } else if (lower.includes('rust')) {
    return 'cargo test && cargo clippy';
  } else if (lower.includes('go')) {
    return 'go test ./... && go vet ./...';
  }
  
  return 'npm test';
}

async function convertSpecKitToPrd(specFolderPath) {
  log('\n╔════════════════════════════════════════╗', 'cyan');
  log('║   Spec Kit → Ralph PRD Converter      ║', 'cyan');
  log('║        (Simple Regex Parser)           ║', 'cyan');
  log('╚════════════════════════════════════════╝\n', 'cyan');
  
  const specPath = path.join(specFolderPath, 'spec.md');
  const tasksPath = path.join(specFolderPath, 'tasks.md');
  
  // Read spec.md
  log(`Reading: ${specPath}`, 'yellow');
  const specContent = await fs.readFile(specPath, 'utf-8');
  
  // Extract project name and description
  const nameMatch = specContent.match(/^# (.+)/m);
  const name = nameMatch ? nameMatch[1].trim() : 'Project';
  
  const overviewMatch = specContent.match(/## Overview\s+([\s\S]*?)(?=##|$)/);
  const description = overviewMatch ? overviewMatch[1].trim().split('\n')[0] : '';
  
  // Parse user stories
  const userStories = parseSpec(specContent);
  
  // Parse tasks if available
  let tasksByStory = {};
  try {
    await fs.access(tasksPath);
    log(`Reading: ${tasksPath}`, 'yellow');
    const tasksContent = await fs.readFile(tasksPath, 'utf-8');
    tasksByStory = parseTasks(tasksContent);
  } catch {
    log('tasks.md not found (optional)', 'yellow');
  }
  
  // Merge tasks into acceptance criteria
  userStories.forEach(story => {
    if (tasksByStory[story.id]) {
      story.acceptanceCriteria.push(...tasksByStory[story.id]);
    }
  });
  
  // Generate branch name
  const folderName = path.basename(specFolderPath);
  const branchName = `ralph/${folderName}`;
  
  // Detect quality check
  const qualityCheck = detectQualityCheck(specContent);
  
  // Build PRD
  const prd = {
    name,
    description,
    branchName,
    qualityCheck,
    userStories
  };
  
  // Validate
  if (userStories.length === 0) {
    throw new Error('No user stories found in spec.md');
  }
  
  // Write prd.json
  const outputPath = path.join(process.cwd(), 'prd.json');
  await fs.writeFile(outputPath, JSON.stringify(prd, null, 2));
  
  log(`\n✓ Generated: ${outputPath}`, 'green');
  log(`\nProject: ${prd.name}`, 'cyan');
  log(`Branch: ${prd.branchName}`, 'cyan');
  log(`User Stories: ${prd.userStories.length}`, 'cyan');
  log(`Quality Check: ${prd.qualityCheck}`, 'cyan');
  log(`\nReady to run Ralph!`, 'yellow');
  log(`  npm run ralph\n`, 'cyan');
}

// CLI
const args = process.argv.slice(2);

if (args.length === 0) {
  log('\nUsage: node speckit-to-prd-simple.js <path-to-spec-folder>', 'yellow');
  log('Example: node speckit-to-prd-simple.js specs/001-restaurant-chatbot\n', 'cyan');
  process.exit(1);
}

convertSpecKitToPrd(args[0]).catch(error => {
  log(`\nERROR: ${error.message}`, 'red');
  process.exit(1);
});
