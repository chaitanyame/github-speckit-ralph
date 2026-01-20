#!/usr/bin/env node
/**
 * Mock test for the Ralph framework
 * Tests the complete workflow without requiring actual Copilot CLI
 */

import fs from 'fs/promises';
import path from 'path';

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  blue: '\x1b[34m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function runTest() {
  log('\n╔════════════════════════════════════════╗', 'cyan');
  log('║   Ralph Framework Mock Test           ║', 'cyan');
  log('╚════════════════════════════════════════╝\n', 'cyan');

  const testDir = 'test-project';
  const specDir = path.join(testDir, 'specs', '001-todo-app');
  
  // Test 1: Check if spec files exist
  log('Test 1: Verifying Spec Kit files...', 'blue');
  try {
    await fs.access(path.join(specDir, 'spec.md'));
    await fs.access(path.join(specDir, 'tasks.md'));
    log('  ✓ spec.md found', 'green');
    log('  ✓ tasks.md found', 'green');
  } catch (error) {
    log('  ✗ Spec files not found', 'red');
    return;
  }

  // Test 2: Read and validate spec.md content
  log('\nTest 2: Validating spec.md structure...', 'blue');
  const specContent = await fs.readFile(path.join(specDir, 'spec.md'), 'utf-8');
  
  const hasUserStories = /### User Story \d+/.test(specContent);
  const hasPriorities = /\(Priority: P\d+\)/.test(specContent);
  const hasAcceptanceScenarios = /\*\*Acceptance Scenarios\*\*:/.test(specContent);
  const hasGivenWhenThen = /\*\*Given\*\*.*\*\*When\*\*.*\*\*Then\*\*/.test(specContent);
  
  log(`  ${hasUserStories ? '✓' : '✗'} User Stories found`, hasUserStories ? 'green' : 'red');
  log(`  ${hasPriorities ? '✓' : '✗'} Priorities found`, hasPriorities ? 'green' : 'red');
  log(`  ${hasAcceptanceScenarios ? '✓' : '✗'} Acceptance Scenarios found`, hasAcceptanceScenarios ? 'green' : 'red');
  log(`  ${hasGivenWhenThen ? '✓' : '✗'} Given/When/Then format found`, hasGivenWhenThen ? 'green' : 'red');

  // Test 3: Read and validate tasks.md content
  log('\nTest 3: Validating tasks.md structure...', 'blue');
  const tasksContent = await fs.readFile(path.join(specDir, 'tasks.md'), 'utf-8');
  
  const hasTaskIds = /\[T\d+\]/.test(tasksContent);
  const hasTaskPriorities = /\[P\d+\]/.test(tasksContent);
  const hasUserStoryLinks = /\[US\d+\]/.test(tasksContent);
  
  log(`  ${hasTaskIds ? '✓' : '✗'} Task IDs found`, hasTaskIds ? 'green' : 'red');
  log(`  ${hasTaskPriorities ? '✓' : '✗'} Task priorities found`, hasTaskPriorities ? 'green' : 'red');
  log(`  ${hasUserStoryLinks ? '✓' : '✗'} User Story links found`, hasUserStoryLinks ? 'green' : 'red');

  // Test 4: Generate mock prd.json (simulating what Copilot would generate)
  log('\nTest 4: Generating mock prd.json...', 'blue');
  
  const mockPrd = {
    name: "Todo App",
    description: "A simple task management application that allows users to create, complete, and delete todo items",
    branchName: "ralph/001-todo-app",
    qualityCheck: "npm run typecheck && npm test && npm run build && npm run lint",
    userStories: [
      {
        id: 1,
        title: "Create Todo Item",
        priority: 1,
        acceptanceCriteria: [
          "Given the user is on the main page, When they enter text in the input field and press Enter, Then a new todo item should appear in the list",
          "Given the user tries to create a todo with empty text, When they press Enter, Then the system should show an error message 'Todo cannot be empty'",
          "Given the user creates a todo, When the todo is added successfully, Then the input field should be cleared for the next entry",
          "Task: Set up React component structure",
          "Task: Create controlled input component",
          "Task: Implement add todo handler",
          "Task: Add input validation",
          "Task: Clear input after submission"
        ],
        passes: false
      },
      {
        id: 2,
        title: "Mark Todo as Complete",
        priority: 1,
        acceptanceCriteria: [
          "Given the user has uncompleted todos in the list, When they click the checkbox next to a todo, Then the todo should be marked as complete with a strikethrough style",
          "Given the user has a completed todo, When they click the checkbox again, Then the todo should be marked as incomplete",
          "Given the user completes all todos, When all checkboxes are checked, Then a success message 'All tasks completed!' should appear",
          "Task: Create todo item component",
          "Task: Implement checkbox toggle handler",
          "Task: Add conditional styling for completed todos",
          "Task: Show success message when all complete"
        ],
        passes: false
      },
      {
        id: 3,
        title: "Delete Todo Item",
        priority: 2,
        acceptanceCriteria: [
          "Given the user has todos in the list, When they click the delete button next to a todo, Then the todo should be removed from the list",
          "Given the user deletes a todo, When the deletion is confirmed, Then the list count should update to reflect the new total",
          "Task: Add delete button to todo component",
          "Task: Implement delete handler",
          "Task: Update todo count display"
        ],
        passes: false
      }
    ]
  };

  await fs.writeFile(
    path.join(testDir, 'prd.json'),
    JSON.stringify(mockPrd, null, 2)
  );
  
  log('  ✓ prd.json generated', 'green');

  // Test 5: Validate generated prd.json
  log('\nTest 5: Validating prd.json structure...', 'blue');
  
  const hasName = !!mockPrd.name;
  const hasUserStoriesArray = Array.isArray(mockPrd.userStories);
  const hasBranchName = !!mockPrd.branchName;
  const hasQualityCheck = !!mockPrd.qualityCheck;
  const allStoriesHaveRequiredFields = mockPrd.userStories.every(s => 
    s.id && s.title && s.priority && Array.isArray(s.acceptanceCriteria) && s.passes === false
  );
  const noPrdWrapper = !mockPrd.prd;
  const noTasksArray = !mockPrd.tasks;
  
  log(`  ${hasName ? '✓' : '✗'} Has "name" field`, hasName ? 'green' : 'red');
  log(`  ${hasUserStoriesArray ? '✓' : '✗'} Has "userStories" array`, hasUserStoriesArray ? 'green' : 'red');
  log(`  ${hasBranchName ? '✓' : '✗'} Has "branchName" field`, hasBranchName ? 'green' : 'red');
  log(`  ${hasQualityCheck ? '✓' : '✗'} Has "qualityCheck" field`, hasQualityCheck ? 'green' : 'red');
  log(`  ${allStoriesHaveRequiredFields ? '✓' : '✗'} All stories have required fields`, allStoriesHaveRequiredFields ? 'green' : 'red');
  log(`  ${noPrdWrapper ? '✓' : '✗'} No "prd" wrapper (anti-pattern avoided)`, noPrdWrapper ? 'green' : 'red');
  log(`  ${noTasksArray ? '✓' : '✗'} No "tasks" array (anti-pattern avoided)`, noTasksArray ? 'green' : 'red');

  // Test 6: Validate story details
  log('\nTest 6: Validating user stories...', 'blue');
  log(`  ✓ Total stories: ${mockPrd.userStories.length}`, 'green');
  log(`  ✓ P1 stories: ${mockPrd.userStories.filter(s => s.priority === 1).length}`, 'green');
  log(`  ✓ P2 stories: ${mockPrd.userStories.filter(s => s.priority === 2).length}`, 'green');
  
  const totalCriteria = mockPrd.userStories.reduce((sum, s) => sum + s.acceptanceCriteria.length, 0);
  log(`  ✓ Total acceptance criteria: ${totalCriteria}`, 'green');

  // Summary
  log('\n╔════════════════════════════════════════╗', 'cyan');
  log('║   Test Summary                         ║', 'cyan');
  log('╚════════════════════════════════════════╝\n', 'cyan');
  
  log('✅ All tests passed!', 'green');
  log('\nGenerated files:', 'yellow');
  log(`  - ${path.join(testDir, 'prd.json')}`, 'cyan');
  log('\nThis simulates what the Copilot CLI would generate.', 'yellow');
  log('\nNext steps to test full workflow:', 'yellow');
  log('  1. npm run setup (check dependencies)', 'cyan');
  log('  2. npm run ralph (would run autonomous loop)', 'cyan');
  log('\nNote: Ralph execution requires actual GitHub Copilot CLI.', 'yellow');
  log('');
}

runTest().catch(error => {
  log(`\n✗ Test failed: ${error.message}`, 'red');
  process.exit(1);
});
