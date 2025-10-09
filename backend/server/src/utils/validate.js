/**
 * validate.js
 * JSON Schema validation using Ajv with formats support.
 */

import Ajv from 'ajv';
import addFormats from 'ajv-formats';

// Initialize Ajv with strict mode and format validation
const ajv = new Ajv({
  allErrors: true,
  strict: true,
  strictSchema: true,
});

// Add format validators (uri, date, etc.)
addFormats(ajv);

/**
 * Compiles a JSON schema into a validator function.
 * @param {object} schema - JSON schema object
 * @returns {function} Validator function
 */
export function compile(schema) {
  return ajv.compile(schema);
}

/**
 * Validates data against a compiled validator and throws if invalid.
 * @param {any} data - Data to validate
 * @param {function} validator - Compiled validator function
 * @param {string} label - Label for error messages
 * @throws {Error} 400 error with validation details
 */
export function assertValid(data, validator, label = 'Data') {
  const valid = validator(data);
  if (!valid) {
    const error = new Error(`${label} validation failed`);
    error.statusCode = 400;
    error.details = validator.errors;
    throw error;
  }
}

/**
 * Custom error class for validation errors.
 */
export class ValidationError extends Error {
  constructor(message, details) {
    super(message);
    this.name = 'ValidationError';
    this.statusCode = 400;
    this.details = details;
  }
}

