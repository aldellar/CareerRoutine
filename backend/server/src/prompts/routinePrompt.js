/**
 * routinePrompt.js
 * Generates prompts and schema for routine generation.
 */

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load plan schema
const planSchemaPath = join(__dirname, '../schemas/plan.schema.json');
const planSchema = JSON.parse(readFileSync(planSchemaPath, 'utf-8'));

// Remove $schema field for OpenAI API (it expects pure JSON Schema)
const cleanSchema = { ...planSchema };
delete cleanSchema.$schema;

const SYSTEM_PROMPT = `You are a focused career coach for CS students and new graduates preparing for technical interviews.

Your task is to generate a structured weekly routine plan that helps them prepare effectively.

CRITICAL REQUIREMENTS:
- Output ONLY valid JSON matching the provided schema
- No markdown, no code blocks, no commentary, no extra fields
- All time values must use 24-hour format (HH:MM)
- Respect the user's time budget and available days strictly
- Create time blocks that are 45-60 minutes with 15-minute breaks
- Include 3-4 focused blocks per day
- Always include daily Applications/Networking time
- Sequence: DS&A → Role-specific → Portfolio/Applications
- Generate blocks for Monday through Friday at minimum
- For days not in availableDays, create empty arrays
- Include 3-6 meaningful weekly milestones
- Provide 4-8 high-quality resources with valid URLs
- Set version to 1`;

/**
 * Generates routine generation prompts and schema.
 * 
 * @param {object} profile - User profile
 * @param {object} preferences - Optional generation preferences
 * @returns {object} { system, user, schema }
 */
export function buildRoutinePrompt(profile, preferences = {}) {
  const today = new Date();
  const monday = new Date(today);
  monday.setDate(today.getDate() - today.getDay() + 1);
  const weekOf = monday.toISOString().split('T')[0];

  const constraintsText = profile.constraints?.length
    ? `\nAdditional constraints: ${profile.constraints.join(', ')}`
    : '';

  const userPrompt = `Generate a weekly interview preparation routine for:

Name: ${profile.name}
Current Stage: ${profile.stage}
Target Role: ${profile.targetRole}
Daily Time Budget: ${profile.timeBudgetHoursPerDay} hours
Available Days: ${profile.availableDays.join(', ')}${constraintsText}

REQUIREMENTS:
1. Create time-boxed study blocks (45-60 min each, 15-min breaks)
2. Allocate ${profile.timeBudgetHoursPerDay} hours per day across 3-4 blocks
3. Cover Monday through Friday with the following daily focus areas:
   - Data Structures & Algorithms practice
   - Role-specific preparation (e.g., iOS/Swift for iOS roles, system design)
   - Portfolio projects or code reviews
   - Applications and networking (DAILY - at least 30 min)
4. For days NOT in available days [${profile.availableDays.join(', ')}], create empty arrays
5. Suggest 3-6 weekly milestones (e.g., "Complete 10 medium LC problems")
6. Provide 4-8 curated resources with actual URLs (LeetCode, YouTube, books, courses)
7. Use realistic times (e.g., 09:00-09:45, 10:00-10:45)
8. Set weekOf to: ${weekOf}
9. Set version to 1

Output the complete plan as valid JSON.`;

  return {
    system: SYSTEM_PROMPT,
    user: userPrompt,
    schema: cleanSchema,
  };
}

