/**
 * safety.js
 * LLM safety and reliability service - treating safety as a first-class product feature.
 * 
 * Implements:
 * - Input validation and sanitization
 * - Output content filtering
 * - Risk detection and assessment
 * - Fallback/deferral strategies
 * - Safety logging for evaluation
 */

import logger from '../utils/logger.js';

/**
 * RISKY CONTENT PATTERNS
 * Patterns that indicate potentially unsafe or irrelevant LLM responses
 */
const RISKY_PATTERNS = {
  // Inappropriate content markers
  inappropriate: [
    /violence/i,
    /harmful/i,
    /illegal/i,
    /spam/i,
    /phishing/i,
  ],
  
  // Off-topic content (not interview prep related)
  offtopic: [
    /financial advice/i,
    /medical advice/i,
    /legal advice/i,
    /investment/i,
    /crypto/i,
    /unrelated topic/i,
  ],
  
  // Suspicious URLs or links
  suspiciousURLs: [
    /http[s]?:\/\/bit\.ly/i,
    /http[s]?:\/\/tinyurl/i,
    /http[s]?:\/\/(?!.*\.(com|org|edu|io|gov|net))/i,
  ],
  
  // Low-quality or hallucinated content indicators
  lowQuality: [
    /placeholder/i,
    /example\.com/i,
    /lorem ipsum/i,
    /test data/i,
    /\[TODO\]/i,
    /\[FIXME\]/i,
  ],
  
  // Malformed structured data
  malformed: [
    /undefined/i,
    /null/i,
    /NaN/i,
  ],
};

/**
 * Content risk levels
 */
export const RiskLevel = {
  SAFE: 'safe',
  LOW_RISK: 'low_risk',
  MEDIUM_RISK: 'medium_risk',
  HIGH_RISK: 'high_risk',
};

/**
 * Assesses content risk level
 * @param {string} content - Content to assess
 * @returns {object} Risk assessment with level and reasons
 */
export function assessContentRisk(content) {
  if (!content || typeof content !== 'string') {
    return {
      level: RiskLevel.HIGH_RISK,
      reasons: ['Empty or invalid content'],
      confidence: 0,
    };
  }

  const reasons = [];
  let riskScore = 0;

  // Check each risk category
  for (const [category, patterns] of Object.entries(RISKY_PATTERNS)) {
    for (const pattern of patterns) {
      if (pattern.test(content)) {
        reasons.push(`${category}: ${pattern.source}`);
        riskScore += category === 'inappropriate' ? 10 : 
                    category === 'offtopic' ? 5 : 
                    category === 'suspiciousURLs' ? 8 :
                    category === 'lowQuality' ? 3 : 2;
      }
    }
  }

  // Determine risk level
  let level;
  if (riskScore === 0) {
    level = RiskLevel.SAFE;
  } else if (riskScore <= 5) {
    level = RiskLevel.LOW_RISK;
  } else if (riskScore <= 10) {
    level = RiskLevel.MEDIUM_RISK;
  } else {
    level = RiskLevel.HIGH_RISK;
  }

  // Calculate confidence based on content quality
  const confidence = calculateContentConfidence(content);

  return {
    level,
    reasons,
    riskScore,
    confidence,
  };
}

/**
 * Calculates content confidence score
 * @param {string} content - Content to analyze
 * @returns {number} Confidence score 0-1
 */
function calculateContentConfidence(content) {
  let confidence = 1.0;

  // Deduct for suspicious patterns
  if (/\[.*\]/.test(content)) confidence -= 0.1; // Placeholder brackets
  if (content.length < 50) confidence -= 0.2; // Too short
  if (content.length > 10000) confidence -= 0.1; // Unusually long
  if (!/^[\u0000-\u007F]*$/.test(content)) confidence += 0.05; // Non-ASCII is okay for international content
  if (/http/i.test(content) && !/https:\/\//.test(content)) confidence -= 0.15; // Insecure URLs

  return Math.max(0, Math.min(1, confidence));
}

/**
 * Sanitizes user input to prevent prompt injection
 * @param {string} input - User input to sanitize
 * @returns {string} Sanitized input
 */
export function sanitizeInput(input) {
  if (!input || typeof input !== 'string') return '';

  // Remove potential prompt injection patterns
  let sanitized = input
    .replace(/```/g, '') // Remove code blocks
    .replace(/---/g, '')  // Remove separators
    .replace(/===/g, '')  // Remove separators
    .replace(/\[INST\]/gi, '') // Remove Llama-style prompts
    .replace(/\[\/INST\]/gi, '')
    .trim()
    .substring(0, 2000); // Limit length

  // Check for attempt to override system instructions
  if (/You are now|Ignore previous|Forget|Override|System prompt/i.test(sanitized)) {
    logger.warn('Potential prompt injection detected', { input: sanitized.substring(0, 100) });
    sanitized = sanitized.replace(/You are now|Ignore previous|Forget|Override|System prompt/gi, '');
  }

  return sanitized;
}

/**
 * Validates URLs in content for safety
 * @param {string|array} urls - URL or array of URLs to validate
 * @returns {object} Validation result with safe URLs
 */
export function validateURLs(urls) {
  if (!urls) return { valid: [], invalid: [] };

  const urlArray = Array.isArray(urls) ? urls : [urls];
  const valid = [];
  const invalid = [];

  for (const url of urlArray) {
    if (!url || typeof url !== 'string') {
      invalid.push(url);
      continue;
    }

    try {
      const urlObj = new URL(url);
      
      // Allow only http/https
      if (!['http:', 'https:'].includes(urlObj.protocol)) {
        invalid.push(url);
        continue;
      }

      // Block suspicious domains
      const hostname = urlObj.hostname.toLowerCase();
      const suspiciousDomains = ['bit.ly', 'tinyurl', 't.co', 'goo.gl'];
      if (suspiciousDomains.some(domain => hostname.includes(domain))) {
        invalid.push(url);
        continue;
      }

      valid.push(url);
    } catch (e) {
      invalid.push(url);
    }
  }

  return { valid, invalid };
}

/**
 * Filters and cleans LLM output to remove unsafe content
 * @param {object} data - LLM response data
 * @param {string} dataType - Type of data (plan, prep, etc.)
 * @returns {object} Filtered data
 */
export function filterLLMOutput(data, dataType = 'unknown') {
  if (!data || typeof data !== 'object') {
    return null;
  }

  const filtered = JSON.parse(JSON.stringify(data)); // Deep clone

  // Filter URLs in resources
  if (filtered.resources && Array.isArray(filtered.resources)) {
    filtered.resources = filtered.resources.map(resource => {
      if (resource.url) {
        const urlValidation = validateURLs(resource.url);
        return {
          ...resource,
          url: urlValidation.valid[0] || null, // Use first valid URL or null
        };
      }
      return resource;
    }).filter(resource => resource !== null);
  }

  // Filter URLs in other potential fields
  if (filtered.resourceURLs && Array.isArray(filtered.resourceURLs)) {
    const urlValidation = validateURLs(filtered.resourceURLs);
    filtered.resourceURLs = urlValidation.valid;
  }

  // Validate and clean text fields
  for (const key in filtered) {
    if (typeof filtered[key] === 'string' && filtered[key].length > 0) {
      const riskAssessment = assessContentRisk(filtered[key]);
      if (riskAssessment.level === RiskLevel.HIGH_RISK) {
        logger.warn('High-risk content detected in LLM output', {
          field: key,
          reasons: riskAssessment.reasons,
        });
        filtered[key] = '[Content filtered for safety]';
      }
    }
  }

  return filtered;
}

/**
 * Creates a safe fallback response when LLM fails or returns unsafe content
 * @param {string} type - Type of response needed (routine, prep)
 * @param {object} profile - User profile for context
 * @returns {object} Safe fallback data
 */
export function createFallbackResponse(type, profile) {
  logger.warn('Using fallback response', { type, profileName: profile?.name });

  if (type === 'routine' || type === 'plan') {
    return {
      version: 1,
      weekOf: new Date().toISOString().split('T')[0],
      timeBlocks: {
        Mon: [],
        Tue: [],
        Wed: [],
        Thu: [],
        Fri: [],
      },
      milestones: [
        'Please try generating again when the service is available',
        'In the meantime, review fundamental data structures',
        'Start practicing with online coding platforms',
      ],
      resources: [
        {
          title: 'LeetCode',
          url: 'https://leetcode.com',
          description: 'Practice coding problems',
        },
        {
          title: 'Interview Prep Guide',
          url: 'https://www.interviewbit.com',
          description: 'Comprehensive interview resources',
        },
      ],
    };
  }

  if (type === 'prep') {
    return {
      prepOutline: [
        {
          section: 'Data Structures & Algorithms',
          items: ['Arrays and Strings', 'Linked Lists', 'Trees and Graphs', 'Dynamic Programming'],
        },
      ],
      weeklyDrillPlan: [
        { day: 'Monday', drills: ['Review arrays and strings'] },
        { day: 'Tuesday', drills: ['Practice tree problems'] },
        { day: 'Wednesday', drills: ['Study graph algorithms'] },
        { day: 'Thursday', drills: ['Focus on dynamic programming'] },
        { day: 'Friday', drills: ['Mock interview practice'] },
      ],
      starterQuestions: [
        'Reverse a linked list',
        'Find the maximum element in an array',
        'Implement binary search',
      ],
      resources: [
        {
          title: 'LeetCode',
          url: 'https://leetcode.com',
          description: 'Practice coding problems',
        },
      ],
    };
  }

  return { error: 'Unable to generate content at this time' };
}

/**
 * Logs LLM interaction for safety evaluation
 * @param {object} params - Logging parameters
 * @param {string} params.traceId - Request trace ID
 * @param {string} params.model - LLM model used
 * @param {string} params.prompt - User prompt
 * @param {string} params.response - LLM response
 * @param {object} params.riskAssessment - Risk assessment
 * @param {number} params.tokens - Token count
 * @param {number} params.latency - Request latency in ms
 */
export function logLLMInteraction({
  traceId,
  model,
  prompt,
  response,
  riskAssessment,
  tokens,
  latency,
}) {
  const logEntry = {
    traceId,
    timestamp: new Date().toISOString(),
    model,
    riskLevel: riskAssessment?.level || 'unknown',
    riskScore: riskAssessment?.riskScore || 0,
    confidence: riskAssessment?.confidence || 0,
    tokens: tokens || 0,
    latencyMs: latency || 0,
    promptLength: prompt?.length || 0,
    responseLength: response?.length || 0,
    hasURLs: /http/i.test(response || ''),
    hasHighRisk: riskAssessment?.level === RiskLevel.HIGH_RISK,
  };

  logger.info(logEntry, 'LLM interaction logged for safety evaluation');

  // In production, you could send this to a monitoring service
  // For eval loops and safety improvements
}

/**
 * Determines if content is safe to return to user
 * @param {object} data - Data to check
 * @param {object} riskAssessment - Risk assessment
 * @returns {boolean} True if safe to return
 */
export function isSafeToReturn(data, riskAssessment) {
  if (!data) return false;
  if (riskAssessment?.level === RiskLevel.HIGH_RISK) return false;
  if (riskAssessment?.confidence < 0.5) return false;
  return true;
}

/**
 * Creates an enhanced system prompt with safety guidelines
 * @param {string} basePrompt - Base system prompt
 * @returns {string} Enhanced prompt with safety guidelines
 */
export function addSafetyGuidelines(basePrompt) {
  const safetyGuidelines = `

SAFETY AND RELIABILITY REQUIREMENTS:
- Generate only interview preparation content relevant to technical interviews
- Avoid off-topic content (financial, medical, legal advice)
- Ensure all URLs are safe, valid, and relevant to interview prep
- Do not generate placeholder or example content
- Provide actionable, specific recommendations
- Keep all content professional and appropriate
- Focus strictly on coding interview preparation for software engineering roles
- Do not include any potentially harmful or illegal content
- Ensure all suggested resources are legitimate learning platforms`;

  return basePrompt + safetyGuidelines;
}

/**
 * Validates data quality before returning to user
 * @param {object} data - Data to validate
 * @param {string} expectedType - Expected data type
 * @param {object} profile - Optional user profile for time budget validation
 * @returns {object} Validation result
 */
export function validateDataQuality(data, expectedType = 'unknown', profile = null) {
  const issues = [];

  if (!data || typeof data !== 'object') {
    issues.push('Invalid data structure');
    return { valid: false, issues };
  }

  // Check for required fields based on type
  if (expectedType === 'plan' || expectedType === 'routine') {
    if (!data.timeBlocks) issues.push('Missing timeBlocks');
    if (!data.version) issues.push('Missing version');
    
    // Validate time budget compliance if profile provided
    if (profile && data.timeBlocks && typeof data.timeBlocks === 'object') {
      const timeBudgetIssues = validateTimeBudget(data.timeBlocks, profile.timeBudgetHoursPerDay);
      if (timeBudgetIssues.length > 0) {
        issues.push(...timeBudgetIssues);
        logger.warn('Time budget validation failed', {
          issues: timeBudgetIssues,
          timeBudget: profile.timeBudgetHoursPerDay
        });
      }
    }
  }

  if (expectedType === 'prep') {
    if (!data.prepOutline) issues.push('Missing prepOutline');
    if (!data.resources) issues.push('Missing resources');
  }

  // Check data integrity
  if (JSON.stringify(data).length < 50) {
    issues.push('Data too short, likely incomplete');
  }

  return {
    valid: issues.length === 0,
    issues,
    quality: issues.length > 0 ? 'low' : 'high',
  };
}

/**
 * Validates that time block durations sum correctly to time budget
 * @param {object} timeBlocks - Time blocks object keyed by day
 * @param {number} timeBudgetHours - Expected total hours per day
 * @returns {array} Array of validation issues
 */
function validateTimeBudget(timeBlocks, timeBudgetHours) {
  const issues = [];
  const tolerance = 0.1; // Allow 0.1 hour (6 minutes) tolerance for rounding
  
  for (const [day, blocks] of Object.entries(timeBlocks)) {
    if (!Array.isArray(blocks)) continue;
    if (blocks.length === 0) continue; // Empty days are okay
    
    const totalHours = blocks.reduce((sum, block) => {
      return sum + (block.durationHours || 0);
    }, 0);
    
    const difference = Math.abs(totalHours - timeBudgetHours);
    
    if (difference > tolerance) {
      issues.push(
        `${day}: Total duration is ${totalHours.toFixed(2)}h, expected ${timeBudgetHours}h (difference: ${difference.toFixed(2)}h)`
      );
    }
  }
  
  return issues;
}

