#!/usr/bin/env node
/**
 * Interactive PRD Creator for Copilot-Ralph
 * Generates prd.json through terminal prompts
 */

import { writeFile } from 'fs/promises';
import { 
  askQuestion, 
  askNumber, 
  askYesNo,
  printSection,
  printSuccess,
  printError,
  printInfo
} from './lib/prompts.js';

/**
 * Slugify a string for branch names
 */
function slugify(text) {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * Generate user stories from description
 */
function generateUserStories(answers) {
  const stories = [];
  const baseStories = [
    {
      template: "Set up project structure",
      criteria: [
        "Project files created",
        "Dependencies configured",
        "Basic structure in place"
      ]
    },
    {
      template: "Implement core functionality",
      criteria: [
        "Main feature working",
        "Code is tested",
        "Documentation updated"
      ]
    },
    {
      template: "Add user interface",
      criteria: [
        "UI components created",
        "Responsive design",
        "Accessible markup"
      ]
    },
    {
      template: "Polish and finalize",
      criteria: [
        "Code review passed",
        "All tests passing",
        "Ready for deployment"
      ]
    }
  ];

  const storyCount = Math.min(answers.storyCount, 10);
  
  for (let i = 0; i < storyCount; i++) {
    const storyNum = String(i + 1).padStart(3, '0');
    const template = baseStories[i % baseStories.length];
    
    stories.push({
      id: `US-${storyNum}`,
      title: i === 0 ? template.template : `${template.template} (${i + 1})`,
      priority: i + 1,
      description: `Implement: ${template.template.toLowerCase()} for ${answers.featureName}`,
      acceptanceCriteria: template.criteria,
      passes: false
    });
  }
  
  return stories;
}

/**
 * Main PRD creation flow
 */
async function createPRD() {
  console.log('\n');
  printSection('🚀 Ralph PRD Creator');
  console.log('');
  printInfo('Create a Product Requirements Document for your project.');
  printInfo('Press Ctrl+C at any time to cancel.\n');

  const answers = {};

  // Feature name
  printSection('1. Feature Description');
  answers.featureName = await askQuestion(
    'What feature do you want to build?',
    'My Feature'
  );

  // Project name
  answers.projectName = await askQuestion(
    'Project name',
    answers.featureName
  );

  // Description
  answers.description = await askQuestion(
    'Brief description (optional)',
    `Building ${answers.featureName}`
  );

  // Number of stories
  printSection('2. User Stories');
  answers.storyCount = await askNumber(
    'How many user stories to generate?',
    5
  );

  // Quality checks
  printSection('3. Quality Gates');
  printInfo('What commands must pass before considering a story complete?');
  answers.qualityCheck = await askQuestion(
    'Quality check command (e.g., npm test)',
    'echo "No tests configured"'
  );

  // Branch name
  printSection('4. Git Branch');
  const defaultBranch = `ralph/${slugify(answers.featureName)}`;
  answers.branchName = await askQuestion(
    'Git branch name',
    defaultBranch
  );

  // Generate PRD
  printSection('Generating PRD');
  
  const prd = {
    projectName: answers.projectName,
    description: answers.description,
    branchName: answers.branchName,
    qualityCheck: answers.qualityCheck,
    userStories: generateUserStories(answers)
  };

  // Display summary
  console.log('');
  printInfo(`Project: ${prd.projectName}`);
  printInfo(`Branch: ${prd.branchName}`);
  printInfo(`Stories: ${prd.userStories.length}`);
  console.log('');
  
  prd.userStories.forEach(story => {
    console.log(`  ${story.id}: ${story.title}`);
  });
  console.log('');

  // Confirm
  const confirmed = await askYesNo('Generate prd.json?', true);
  
  if (!confirmed) {
    printInfo('Cancelled.');
    process.exit(0);
  }

  // Write file
  try {
    const json = JSON.stringify(prd, null, 2);
    await writeFile('prd.json', json, 'utf-8');
    
    console.log('');
    printSuccess('PRD created: prd.json');
    console.log('');
    printInfo('Next steps:');
    console.log('  1. Review prd.json and edit if needed');
    console.log('  2. Run: ./ralph.sh');
    console.log('');
  } catch (error) {
    printError(`Failed to write prd.json: ${error.message}`);
    process.exit(1);
  }
}

// Run
createPRD().catch(error => {
  console.error('');
  printError(`Error: ${error.message}`);
  process.exit(1);
});
