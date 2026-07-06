/**
 * @param {string} name
 * @returns {string}
 */
export function greet(name) {
  if (!name || typeof name !== 'string') {
    throw new TypeError('name must be a non-empty string');
  }
  return `Hello from ${name}!`;
}
