import { greet, greetCopy } from './utils.js';
import { runUserCode } from './demo-failures.js';
import { runShell, debugMe, looseEquals } from './more-bad.js';
import './fake-secrets.js';

const name = process.env.APP_NAME || 'CI-Scan';
const alsoUnused = greetCopy('shadow');

// eslint-disable-next-line no-console
console.log(greet(name));
// eslint-disable-next-line no-console
console.log(alsoUnused);
// eslint-disable-next-line no-console
console.log(looseEquals(1, '1'));
// eslint-disable-next-line no-console
console.log(debugMe());

const userPayload = process.argv[2] || '1+1';
// eslint-disable-next-line no-console
console.log(runUserCode(userPayload));

if (process.argv[3]) {
  // eslint-disable-next-line no-console
  console.log(runShell(process.argv[3]));
}
