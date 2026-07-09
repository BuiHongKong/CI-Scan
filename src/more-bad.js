/**
 * DEMO ONLY — extra failures for ESLint, CodeQL, SonarQ.
 */

import { execSync } from 'node:child_process';

var legacyVarFailure = 'no-var';

export function debugMe() {
  debugger;
  return legacyVarFailure;
}

export function runShell(cmd) {
  return execSync(cmd, { encoding: 'utf8' });
}

export function emptyCatch() {
  try {
    JSON.parse('{ invalid');
  } catch (e) {
    // swallowed on purpose
  }
}

export function looseEquals(a, b) {
  return a == b;
}
