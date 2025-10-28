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
import {
  sanitizeInput,
  assessContentRisk,
  filterLLMOutput,
  validateDataQuality,
  isSafeToReturn,
  createFallbackResponse,
  addSafetyGuidelines,
  logLLMInteraction,
} from '../services/safety.js';

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
  const startTime = Date.now();
  let plan = null;
  
  try {
    const { profile, preferences } = req.body;

    // Validate input
    if (!profile) {
      const error = new Error('Missing required field: profile');
      error.statusCode = 400;
      throw error;
    }

    assertValid(profile, validateProfile, 'Profile');

    // Sanitize user inputs for safety
    profile.name = sanitizeInput(profile.name);
    profile.targetRole = sanitizeInput(profile.targetRole);
    profile.stage = sanitizeInput(profile.stage);

    logger.info({ traceId: req.traceId }, 'Generating routine');

    // Build prompt with safety guidelines
    const { system, user, schema } = buildRoutinePrompt(profile, preferences);
    const safeSystemPrompt = addSafetyGuidelines(system);
    
    let responseText;
    let riskAssessment;
    
    try {
      // Call OpenAI with safety-enhanced prompt
      responseText = await respondWithSchema({
        model: config.openaiModel,
        schema,
        system: safeSystemPrompt,
        user,
      });

      // Assess response risk
      riskAssessment = assessContentRisk(responseText);

      // Parse and validate response
      plan = tryParseJson(responseText);
      assertValid(plan, validatePlan, 'Generated plan');

      // Filter unsafe content from plan
      plan = filterLLMOutput(plan, 'plan');

      // Validate data quality (including time budget)
      const qualityCheck = validateDataQuality(plan, 'plan', profile);
      if (!qualityCheck.valid) {
        logger.warn({ traceId: req.traceId, issues: qualityCheck.issues }, 'Low quality data detected');
      }

      // Check if safe to return
      if (!isSafeToReturn(plan, riskAssessment)) {
        logger.warn({ traceId: req.traceId, riskLevel: riskAssessment.level }, 'Unsafe content detected, using fallback');
        plan = createFallbackResponse('routine', profile);
      }

      // Log LLM interaction for safety evaluation
      logLLMInteraction({
        traceId: req.traceId,
        model: config.openaiModel,
        prompt: user,
        response: responseText,
        riskAssessment,
        latency: Date.now() - startTime,
      });

      logger.info({ traceId: req.traceId, riskLevel: riskAssessment.level }, 'Routine generated successfully');

      res.json({ plan });
    } catch (openaiError) {
      // Fallback on API failure
      logger.error({ traceId: req.traceId, error: openaiError.message }, 'OpenAI error, using fallback');
      plan = createFallbackResponse('routine', profile);
      res.json({ plan });
    }
  } catch (error) {
    // Final fallback on any error
    if (!plan) {
      plan = createFallbackResponse('routine', req.body.profile);
      res.json({ plan });
    } else {
      next(error);
    }
  }
});

/**
 * POST /generate/prep
 * Generates an interview prep pack from user profile.
 */
router.post('/prep', async (req, res, next) => {
  const startTime = Date.now();
  let prep = null;
  
  try {
    const { profile } = req.body;

    // Validate input
    if (!profile) {
      const error = new Error('Missing required field: profile');
      error.statusCode = 400;
      throw error;
    }

    assertValid(profile, validateProfile, 'Profile');

    // Sanitize user inputs for safety
    profile.name = sanitizeInput(profile.name);
    profile.targetRole = sanitizeInput(profile.targetRole);
    profile.stage = sanitizeInput(profile.stage);

    logger.info({ traceId: req.traceId }, 'Generating prep pack');

    // Build prompt with safety guidelines
    const { system, user, schema } = buildPrepPrompt(profile);
    const safeSystemPrompt = addSafetyGuidelines(system);
    
    let responseText;
    let riskAssessment;
    
    try {
      // Call OpenAI with safety-enhanced prompt
      responseText = await respondWithSchema({
        model: config.openaiModel,
        schema,
        system: safeSystemPrompt,
        user,
      });

      // Assess response risk
      riskAssessment = assessContentRisk(responseText);

      // Parse and validate response
      prep = tryParseJson(responseText);
      assertValid(prep, validatePrep, 'Generated prep pack');

      // Filter unsafe content from prep
      prep = filterLLMOutput(prep, 'prep');

      // Validate data quality
      const qualityCheck = validateDataQuality(prep, 'prep');
      if (!qualityCheck.valid) {
        logger.warn({ traceId: req.traceId, issues: qualityCheck.issues }, 'Low quality data detected');
      }

      // Check if safe to return
      if (!isSafeToReturn(prep, riskAssessment)) {
        logger.warn({ traceId: req.traceId, riskLevel: riskAssessment.level }, 'Unsafe content detected, using fallback');
        prep = createFallbackResponse('prep', profile);
      }

      // Log LLM interaction for safety evaluation
      logLLMInteraction({
        traceId: req.traceId,
        model: config.openaiModel,
        prompt: user,
        response: responseText,
        riskAssessment,
        latency: Date.now() - startTime,
      });

      logger.info({ traceId: req.traceId, riskLevel: riskAssessment.level }, 'Prep pack generated successfully');

      res.json({ prep });
    } catch (openaiError) {
      // Fallback on API failure
      logger.error({ traceId: req.traceId, error: openaiError.message }, 'OpenAI error, using fallback');
      prep = createFallbackResponse('prep', profile);
      res.json({ prep });
    }
  } catch (error) {
    // Final fallback on any error
    if (!prep) {
      prep = createFallbackResponse('prep', req.body.profile);
      res.json({ prep });
    } else {
      next(error);
    }
  }
});

/**
 * POST /reroll/:section
 * Re-generates a specific section of an existing plan.
 */
router.post('/:section', async (req, res, next) => {
  const startTime = Date.now();
  let result = null;
  
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

    // Sanitize inputs
    if (profile.name) profile.name = sanitizeInput(profile.name);
    if (profile.targetRole) profile.targetRole = sanitizeInput(profile.targetRole);

    logger.info({ traceId: req.traceId, section }, 'Rerolling section');

    try {
      // Build prompt with safety guidelines
      const { system, user, schema } = buildRerollPrompt(
        section,
        profile,
        currentPlan
      );
      const safeSystemPrompt = addSafetyGuidelines(system);
      
      const responseText = await respondWithSchema({
        model: config.openaiModel,
        schema,
        system: safeSystemPrompt,
        user,
      });

      // Assess response risk
      const riskAssessment = assessContentRisk(responseText);

      // Parse response (will be an object with single key matching section)
      result = tryParseJson(responseText);

      // Filter unsafe content
      if (result[section]) {
        result[section] = filterLLMOutput(result[section], section);
      }

      // Validate that result has the expected section key
      if (!result[section]) {
        const error = new Error(`Response missing expected section: ${section}`);
        error.statusCode = 502;
        throw error;
      }

      // Check if safe to return
      if (!isSafeToReturn(result[section], riskAssessment)) {
        logger.warn({ traceId: req.traceId, section, riskLevel: riskAssessment.level }, 'Unsafe content detected');
        throw new Error('Unsafe content generated');
      }

      // Log interaction
      logLLMInteraction({
        traceId: req.traceId,
        model: config.openaiModel,
        prompt: user,
        response: responseText,
        riskAssessment,
        latency: Date.now() - startTime,
      });

      logger.info({ traceId: req.traceId, section, riskLevel: riskAssessment.level }, 'Section rerolled successfully');

      res.json(result);
    } catch (openaiError) {
      logger.error({ traceId: req.traceId, section, error: openaiError.message }, 'Reroll error');
      // Return current plan's existing data for that section
      if (currentPlan && currentPlan[section]) {
        result = { [section]: currentPlan[section] };
        res.json(result);
      } else {
        throw openaiError;
      }
    }
  } catch (error) {
    next(error);
  }
});

export default router;

