import { greet } from './utils.js';

const name = process.env.APP_NAME || 'CI-Scan';

// eslint-disable-next-line no-console
console.log(greet(name));
