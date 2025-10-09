/**
 * rerollPrompt.js
 * Generates prompts and schemas for re-rolling specific plan sections.
 */

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load plan schema for reference
const planSchemaPath = join(__dirname, '../schemas/plan.schema.json');
const planSchema = JSON.parse(readFileSync(planSchemaPath, 'utf-8'));

// Define sub-schemas for each rerollable section
const SECTION_SCHEMAS = {
  timeBlocks: {
    type: 'object',
    additionalProperties: false,
    required: ['timeBlocks'],
    properties: {
      timeBlocks: planSchema.properties.timeBlocks,
    },
  },
  resources: {
    type: 'object',
    additionalProperties: false,
    required: ['resources'],
    properties: {
      resources: planSchema.properties.resources,
    },
  },
  dailyTasks: {
    type: 'object',
    additionalProperties: false,
    required: ['dailyTasks'],
    properties: {
      dailyTasks: planSchema.properties.dailyTasks,
    },
  },
};

const SYSTEM_PROMPT = `You are a focused career coach regenerating a specific section of a weekly routine plan.

CRITICAL REQUIREMENTS:
- Output ONLY valid JSON matching the provided schema
- No markdown, no code blocks, no commentary, no extra fields
- Regenerate ONLY the requested section with fresh content
- Maintain consistency with the user's profile and constraints
- Keep the same style, quality, and structure as the original plan
- Provide variety and new suggestions different from the current version`;

/**
 * Generates reroll prompts and schema for a specific section.
 * 
 * @param {string} section - Section name (timeBlocks, resources, dailyTasks)
 * @param {object} profile - User profile
 * @param {object} currentPlan - Current plan being modified
 * @returns {object} { system, user, schema }
 * @throws {Error} If section is invalid
 */
export function buildRerollPrompt(section, profile, currentPlan) {
  if (!SECTION_SCHEMAS[section]) {
    throw new Error(`Invalid section: ${section}. Must be one of: ${Object.keys(SECTION_SCHEMAS).join(', ')}`);
  }

  const schema = SECTION_SCHEMAS[section];
  
  const constraintsText = profile.constraints?.length
    ? `\nConstraints: ${profile.constraints.join(', ')}`
    : '';

  let userPrompt = '';

  switch (section) {
    case 'timeBlocks':
      userPrompt = `Regenerate the TIME BLOCKS section for a weekly routine plan.

User Profile:
- Name: ${profile.name}
- Stage: ${profile.stage}
- Target Role: ${profile.targetRole}
- Daily Time Budget: ${profile.timeBudgetHoursPerDay} hours
- Available Days: ${profile.availableDays.join(', ')}${constraintsText}

Current Plan Week: ${currentPlan.weekOf}

REQUIREMENTS:
- Create NEW time blocks (45-60 min each with 15-min breaks)
- Allocate ${profile.timeBudgetHoursPerDay} hours per day across 3-4 blocks
- Cover Monday through Friday minimum
- Include: DS&A, Role-specific prep, Portfolio, Applications (daily)
- Use realistic 24-hour format times (e.g., 09:00-09:45)
- Create empty arrays for days not in availableDays
- Make blocks DIFFERENT from current plan but same quality

Current blocks to improve upon:
${JSON.stringify(currentPlan.timeBlocks, null, 2)}

Output ONLY a JSON object with a "timeBlocks" key.`;
      break;

    case 'resources':
      userPrompt = `Regenerate the RESOURCES section for a weekly routine plan.

User Profile:
- Name: ${profile.name}
- Stage: ${profile.stage}
- Target Role: ${profile.targetRole}${constraintsText}

REQUIREMENTS:
- Provide 4-8 NEW curated resources
- Include: LeetCode lists, YouTube channels/videos, books, courses, docs
- All URLs must be valid and accessible
- Tailor to ${profile.targetRole}
- Make resources DIFFERENT from current list but equally valuable

Current resources to replace:
${JSON.stringify(currentPlan.resources, null, 2)}

Output ONLY a JSON object with a "resources" key.`;
      break;

    case 'dailyTasks':
      userPrompt = `Regenerate the DAILY TASKS section for a weekly routine plan.

User Profile:
- Name: ${profile.name}
- Stage: ${profile.stage}
- Target Role: ${profile.targetRole}
- Daily Time Budget: ${profile.timeBudgetHoursPerDay} hours
- Available Days: ${profile.availableDays.join(', ')}${constraintsText}

REQUIREMENTS:
- Create NEW specific daily tasks for Monday-Friday
- 2-4 tasks per day
- Mix of: coding problems, study topics, applications, portfolio work
- Tasks should be actionable and specific
- Align with ${profile.timeBudgetHoursPerDay} hour daily budget
- Make tasks DIFFERENT from current plan but same quality

Current tasks to improve upon:
${JSON.stringify(currentPlan.dailyTasks, null, 2)}

Output ONLY a JSON object with a "dailyTasks" key.`;
      break;
  }

  return {
    system: SYSTEM_PROMPT,
    user: userPrompt,
    schema,
  };
}

/**
 * Gets available section names for reroll.
 * @returns {string[]} Array of valid section names
 */
export function getValidSections() {
  return Object.keys(SECTION_SCHEMAS);
}

