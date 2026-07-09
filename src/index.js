import { greet } from './utils.js';
import { runUserCode } from './demo-failures.js';

const name = process.env.APP_NAME || 'CI-Scan';

// eslint-disable-next-line no-console
console.log(greet(name));

// Demo path for CodeQL taint-style issue
const userPayload = process.argv[2] || '1+1';
// eslint-disable-next-line no-console
console.log(runUserCode(userPayload));
