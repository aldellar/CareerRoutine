/**
 * prepPrompt.js
 * Generates prompts and schema for interview prep pack generation.
 */

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load prep schema
const prepSchemaPath = join(__dirname, '../schemas/prep.schema.json');
const prepSchema = JSON.parse(readFileSync(prepSchemaPath, 'utf-8'));

// Remove $schema field for OpenAI API
const cleanSchema = { ...prepSchema };
delete cleanSchema.$schema;

const SYSTEM_PROMPT = `You are an expert technical interview coach specializing in CS interviews.

Your task is to generate a comprehensive interview preparation pack tailored to the candidate's profile.

CRITICAL REQUIREMENTS:
- Output ONLY valid JSON matching the provided schema
- No markdown, no code blocks, no commentary, no extra fields
- Create a structured outline of key preparation areas
- Design a focused 5-day drill plan (Monday-Friday)
- Provide 5-7 high-quality starter practice questions
- Include 5+ curated resources with valid URLs
- Tailor all content to the target role and current stage`;

/**
 * Generates prep pack generation prompts and schema.
 * 
 * @param {object} profile - User profile
 * @returns {object} { system, user, schema }
 */
export function buildPrepPrompt(profile) {
  const constraintsText = profile.constraints?.length
    ? `\nConstraints: ${profile.constraints.join(', ')}`
    : '';

  const userPrompt = `Generate a comprehensive interview prep pack for:

Name: ${profile.name}
Current Stage: ${profile.stage}
Target Role: ${profile.targetRole}
Daily Time Budget: ${profile.timeBudgetHoursPerDay} hours${constraintsText}

REQUIREMENTS:

1. PREP OUTLINE:
   Create 4-6 sections covering key areas:
   - Data Structures & Algorithms (arrays, trees, graphs, DP, etc.)
   - Role-specific skills (e.g., iOS/Swift, system design, frontend frameworks)
   - Behavioral & leadership principles
   - System design basics (if applicable to role)
   - Resume & portfolio tips
   Each section should have 3-5 specific items to study/practice.

2. WEEKLY DRILL PLAN (Mon-Fri):
   Design a 5-day practice routine:
   - Mon: Warm-up problems (arrays, strings)
   - Tue: Medium difficulty (trees, graphs)
   - Wed: Role-specific (e.g., iOS UI challenges, API design)
   - Thu: Hard problems or system design
   - Fri: Mock interview simulation
   Each day should have 2-4 specific drills.

3. STARTER QUESTIONS:
   Provide 5-7 practice questions appropriate for ${profile.targetRole}:
   - Mix of easy/medium difficulty
   - Cover common patterns (two pointers, sliding window, BFS/DFS, etc.)
   - Include role-specific questions if applicable
   - Each question should be clearly stated

4. RESOURCES:
   Curate 5+ high-quality resources:
   - LeetCode collections or problem lists
   - YouTube channels or specific videos
   - Books or courses
   - Role-specific documentation or tutorials
   - Provide real, working URLs

Output the complete prep pack as valid JSON.`;

  return {
    system: SYSTEM_PROMPT,
    user: userPrompt,
    schema: cleanSchema,
  };
}

