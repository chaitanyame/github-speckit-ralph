/**
 * Terminal prompt utilities using Node.js readline
 */

import readline from 'readline';

/**
 * Create a readline interface
 */
function createInterface() {
  return readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
}

/**
 * Ask a text question
 */
export function askQuestion(question, defaultValue = '') {
  const rl = createInterface();
  
  return new Promise((resolve) => {
    const prompt = defaultValue 
      ? `${question} (${defaultValue}): `
      : `${question}: `;
    
    rl.question(prompt, (answer) => {
      rl.close();
      resolve(answer.trim() || defaultValue);
    });
  });
}

/**
 * Ask a yes/no question
 */
export async function askYesNo(question, defaultYes = true) {
  const defaultText = defaultYes ? 'Y/n' : 'y/N';
  const answer = await askQuestion(`${question} (${defaultText})`);
  
  if (!answer) return defaultYes;
  
  const normalized = answer.toLowerCase();
  return normalized === 'y' || normalized === 'yes';
}

/**
 * Ask a multiple choice question
 */
export async function askChoice(question, choices) {
  console.log(`\n${question}`);
  choices.forEach((choice, index) => {
    console.log(`  ${index + 1}) ${choice}`);
  });
  
  const rl = createInterface();
  
  return new Promise((resolve) => {
    const prompt = `Choose (1-${choices.length}): `;
    
    const askAgain = () => {
      rl.question(prompt, (answer) => {
        const num = parseInt(answer, 10);
        if (num >= 1 && num <= choices.length) {
          rl.close();
          resolve(choices[num - 1]);
        } else {
          console.log('Invalid choice. Try again.');
          askAgain();
        }
      });
    };
    
    askAgain();
  });
}

/**
 * Ask for a number
 */
export async function askNumber(question, defaultValue = 5) {
  const answer = await askQuestion(question, String(defaultValue));
  const num = parseInt(answer, 10);
  return isNaN(num) ? defaultValue : num;
}

/**
 * Print section header
 */
export function printSection(title) {
  console.log('\n' + '='.repeat(60));
  console.log(title);
  console.log('='.repeat(60));
}

/**
 * Print success message
 */
export function printSuccess(message) {
  console.log(`✅ ${message}`);
}

/**
 * Print error message
 */
export function printError(message) {
  console.error(`❌ ${message}`);
}

/**
 * Print info message
 */
export function printInfo(message) {
  console.log(`ℹ️  ${message}`);
}
