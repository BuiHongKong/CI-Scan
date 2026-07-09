/**
 * DEMO ONLY — intentional issues so security scans fail. Revert before production.
 */

// Gitleaks: fake GitHub PAT pattern (not a real token)
export const DEMO_LEAKED_TOKEN = 'ghp_0000000000000000000000000000000000000000';

// ESLint: unused variable
const unusedLintFailure = 'this triggers no-unused-vars';

// CodeQL / Sonar: dangerous eval usage
export function runUserCode(input) {
  // eslint-disable-next-line no-eval
  return eval(input);
}

// Sonar: hardcoded credential smell
export function getDemoDbPassword() {
  return 'SuperSecretDemoPassword123!';
}
