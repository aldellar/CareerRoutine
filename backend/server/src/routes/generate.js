/**
 * generate.js
 * API routes for generating routines, prep packs, and rerolling sections.
 */

import express from 'express';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { compile, assertValid } from '../utils/validate.js';
import { tryParseJson } from '../utils/jsonFix.js';
import { respondWithSchema } from '../openaiClient.js';
import { buildRoutinePrompt } from '../prompts/routinePrompt.js';
import { buildPrepPrompt } from '../prompts/prepPrompt.js';
import { buildRerollPrompt, getValidSections } from '../prompts/rerollPrompt.js';
import config from '../config.js';
import logger from '../utils/logger.js';

const router = express.Router();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load and compile schemas
const profileSchemaPath = join(__dirname, '../schemas/profile.schema.json');
const planSchemaPath = join(__dirname, '../schemas/plan.schema.json');
const prepSchemaPath = join(__dirname, '../schemas/prep.schema.json');

const profileSchema = JSON.parse(readFileSync(profileSchemaPath, 'utf-8'));
const planSchema = JSON.parse(readFileSync(planSchemaPath, 'utf-8'));
const prepSchema = JSON.parse(readFileSync(prepSchemaPath, 'utf-8'));

const validateProfile = compile(profileSchema);
const validatePlan = compile(planSchema);
const validatePrep = compile(prepSchema);

/**
 * POST /generate/routine
 * Generates a weekly routine plan from user profile.
 */
router.post('/routine', async (req, res, next) => {
  try {
    const { profile, preferences } = req.body;

    // Validate input
    if (!profile) {
      const error = new Error('Missing required field: profile');
      error.statusCode = 400;
      throw error;
    }

    assertValid(profile, validateProfile, 'Profile');

    logger.info({ traceId: req.traceId }, 'Generating routine');

    // Build prompt and call OpenAI
    const { system, user, schema } = buildRoutinePrompt(profile, preferences);
    const responseText = await respondWithSchema({
      model: config.openaiModel,
      schema,
      system,
      user,
    });

    // Parse and validate response
    const plan = tryParseJson(responseText);
    assertValid(plan, validatePlan, 'Generated plan');

    logger.info({ traceId: req.traceId }, 'Routine generated successfully');

    res.json({ plan });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /generate/prep
 * Generates an interview prep pack from user profile.
 */
router.post('/prep', async (req, res, next) => {
  try {
    const { profile } = req.body;

    // Validate input
    if (!profile) {
      const error = new Error('Missing required field: profile');
      error.statusCode = 400;
      throw error;
    }

    assertValid(profile, validateProfile, 'Profile');

    logger.info({ traceId: req.traceId }, 'Generating prep pack');

    // Build prompt and call OpenAI
    const { system, user, schema } = buildPrepPrompt(profile);
    const responseText = await respondWithSchema({
      model: config.openaiModel,
      schema,
      system,
      user,
    });

    // Parse and validate response
    const prep = tryParseJson(responseText);
    assertValid(prep, validatePrep, 'Generated prep pack');

    logger.info({ traceId: req.traceId }, 'Prep pack generated successfully');

    res.json({ prep });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /reroll/:section
 * Re-generates a specific section of an existing plan.
 */
router.post('/:section', async (req, res, next) => {
  try {
    const { section } = req.params;
    const { profile, currentPlan } = req.body;

    // Validate section
    const validSections = getValidSections();
    if (!validSections.includes(section)) {
      const error = new Error(
        `Invalid section: ${section}. Must be one of: ${validSections.join(', ')}`
      );
      error.statusCode = 400;
      throw error;
    }

    // Validate input
    if (!profile || !currentPlan) {
      const error = new Error('Missing required fields: profile, currentPlan');
      error.statusCode = 400;
      throw error;
    }

    assertValid(profile, validateProfile, 'Profile');
    assertValid(currentPlan, validatePlan, 'Current plan');

    logger.info({ traceId: req.traceId, section }, 'Rerolling section');

    // Build prompt and call OpenAI
    const { system, user, schema } = buildRerollPrompt(
      section,
      profile,
      currentPlan
    );
    const responseText = await respondWithSchema({
      model: config.openaiModel,
      schema,
      system,
      user,
    });

    // Parse response (will be an object with single key matching section)
    const result = tryParseJson(responseText);

    // Validate that result has the expected section key
    if (!result[section]) {
      const error = new Error(`Response missing expected section: ${section}`);
      error.statusCode = 502;
      throw error;
    }

    logger.info({ traceId: req.traceId, section }, 'Section rerolled successfully');

    res.json(result);
  } catch (error) {
    next(error);
  }
});

export default router;

