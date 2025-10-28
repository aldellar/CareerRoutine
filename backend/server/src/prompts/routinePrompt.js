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
- All duration values must be in hours (e.g., 1.5, 2.0, 0.5)
- Task durations MUST sum exactly to the user's daily time budget - no more, no less
- Example: 2 hours/day → tasks like [0.5, 0.5, 1.0] or [0.75, 0.75, 0.5]
- Respect the user's time budget and available days strictly
- Divide the daily time budget into 3-5 focused tasks (based on budget size)
- Always include Applications/Networking tasks
- Mix: DS&A → Role-specific → Portfolio/Applications
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
1. CRITICAL: Task durations MUST sum exactly to ${profile.timeBudgetHoursPerDay} hours per day
   Example: If user has 2 hours/day, tasks could be: [0.5h, 0.5h, 1.0h] = 2 hours total
2. Split ${profile.timeBudgetHoursPerDay} hours into 3-5 tasks per day based on budget
   - 2 hours/day → 3-4 tasks
   - 3-4 hours/day → 4-5 tasks
3. Each task duration should be 0.5 to 1.5 hours (not more than 2 hours)
4. Cover Monday through Friday with daily focus areas:
   - Data Structures & Algorithms practice
   - Role-specific preparation (e.g., iOS/Swift for iOS roles, system design)
   - Portfolio projects or code reviews
   - Applications and networking (DAILY - at least 0.5 hours)
5. For days NOT in available days [${profile.availableDays.join(', ')}], create empty arrays
6. Double-check: Sum of all task durations = ${profile.timeBudgetHoursPerDay} hours for each active day
7. Suggest 3-6 weekly milestones (e.g., "Complete 10 medium LC problems")
8. Provide 4-8 curated resources with actual URLs (LeetCode, YouTube, books, courses)
9. Set weekOf to: ${weekOf}
10. Set version to 1

Output the complete plan as valid JSON.`;

  return {
    system: SYSTEM_PROMPT,
    user: userPrompt,
    schema: cleanSchema,
  };
}

