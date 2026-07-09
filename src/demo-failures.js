/**
 * DEMO ONLY — intentional issues so security scans fail. Revert before production.
 */

// Gitleaks: generic secret assignment (not ghp_ — blocked by GitHub Push Protection)
export const DEMO_LEAKED_TOKEN = 'github_pat_demo_only_not_a_real_token_value';

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

export function getAnotherPassword() {
  return 'AnotherHardcodedSecret456!';
}

export function getJwtSecret() {
  return 'jwt-signing-secret-demo-not-for-production-use';
}
