/**
 * openaiClient.js
 * OpenAI client with structured JSON schema responses.
 */

import OpenAI from 'openai';
import config from './config.js';
import logger from './utils/logger.js';

// Initialize OpenAI client
const client = new OpenAI({
  apiKey: config.openaiApiKey,
});

/**
 * Calls OpenAI with structured JSON schema output.
 * 
 * @param {object} params - Request parameters
 * @param {string} params.model - OpenAI model to use
 * @param {object} params.schema - JSON schema for response
 * @param {string} params.system - System prompt
 * @param {string} params.user - User prompt
 * @param {number} params.timeoutMs - Request timeout in milliseconds
 * @returns {Promise<string>} Response text content
 * @throws {Error} On timeout or OpenAI API errors
 */
export async function respondWithSchema({
  model,
  schema,
  system,
  user,
  timeoutMs = config.openaiTimeoutMs,
}) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    logger.info({ model, timeoutMs }, 'Calling OpenAI API');

    const response = await client.chat.completions.create(
      {
        model,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: user },
        ],
        response_format: {
          type: 'json_schema',
          json_schema: {
            name: 'Result',
            strict: true,
            schema,
          },
        },
        temperature: 0.3,
      },
      { signal: controller.signal }
    );

    clearTimeout(timeoutId);

    const content = response.choices[0]?.message?.content;
    if (!content) {
      throw new Error('Empty response from OpenAI');
    }

    logger.info({ 
      tokens: response.usage?.total_tokens 
    }, 'OpenAI API call successful');

    return content;
  } catch (error) {
    clearTimeout(timeoutId);

    if (error.name === 'AbortError') {
      logger.error({ timeoutMs }, 'OpenAI request timed out');
      const timeoutError = new Error('OpenAI request timed out');
      timeoutError.statusCode = 504;
      throw timeoutError;
    }

    logger.error({ error: error.message }, 'OpenAI API call failed');
    
    const apiError = new Error('OpenAI API request failed');
    apiError.statusCode = 502;
    apiError.originalError = error.message;
    throw apiError;
  }
}

