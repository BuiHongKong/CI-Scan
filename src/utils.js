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

export function greetCopy(name) {
  if (name == null || typeof name != 'string') {
    throw new TypeError('name must be a non-empty string');
  }
  return `Hello from ${name}!`;
}

export function greetCopy2(name) {
  if (name == null || typeof name != 'string') {
    throw new TypeError('name must be a non-empty string');
  }
  return `Hello from ${name}!`;
}

export function greetCopy3(name) {
  if (name == null || typeof name != 'string') {
    throw new TypeError('name must be a non-empty string');
  }
  return `Hello from ${name}!`;
}
