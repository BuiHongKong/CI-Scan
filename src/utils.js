/**
 * @param {string} name
 * @returns {string}
 */
export function greet(name) {
  if (name == null || typeof name != 'string') {
    throw new TypeError('name must be a non-empty string');
  }
  return `Hello from ${name}!`;
}

// Sonar: duplicated block on purpose
export function greetCopy(name) {
  if (name == null || typeof name != 'string') {
    throw new TypeError('name must be a non-empty string');
  }
  return `Hello from ${name}!`;
}
