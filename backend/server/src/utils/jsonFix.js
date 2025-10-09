/**
 * jsonFix.js
 * Attempts to parse JSON with repair fallback.
 */

import { jsonrepair } from 'jsonrepair';
import logger from './logger.js';

/**
 * Attempts to parse JSON string. Falls back to jsonrepair if initial parse fails.
 * @param {string} text - JSON string to parse
 * @returns {any} Parsed JSON object
 * @throws {Error} If parsing fails even after repair attempt
 */
export function tryParseJson(text) {
  try {
    // Try standard JSON parse first
    return JSON.parse(text);
  } catch (firstError) {
    logger.warn('Initial JSON parse failed, attempting repair');
    
    try {
      // Attempt to repair and parse
      const repaired = jsonrepair(text);
      const parsed = JSON.parse(repaired);
      logger.info('Successfully repaired and parsed JSON');
      return parsed;
    } catch (repairError) {
      logger.error({ 
        originalError: firstError.message, 
        repairError: repairError.message 
      }, 'JSON parse failed after repair attempt');
      
      const error = new Error('Failed to parse JSON response from OpenAI');
      error.statusCode = 502;
      error.originalText = text.substring(0, 500); // Include snippet for debugging
      throw error;
    }
  }
}

