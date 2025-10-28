/**
 * normalizeDurations.js
 * Normalizes time block durations to ensure they sum to the daily time budget.
 */

import logger from './logger.js';

/**
 * Normalizes durations for a day's time blocks to ensure they sum exactly to the daily budget.
 * Uses proportional redistribution if needed.
 * 
 * @param {Array} blocks - Array of time blocks with durationHours
 * @param {number} targetHours - Target total hours per day
 * @returns {Array} Normalized blocks with corrected durationHours
 */
function normalizeDayBlockDurations(blocks, targetHours) {
  if (!blocks || blocks.length === 0) {
    return blocks;
  }

  // Calculate current sum
  const currentSum = blocks.reduce((sum, block) => sum + block.durationHours, 0);

  // Always normalize, even if close, to ensure exact precision
  // This ensures durations always sum exactly to the target
  // If already very close (within 0.001 hours tolerance), we still need to ensure exact sum

  // Calculate scaling factor
  const scaleFactor = targetHours / currentSum;

  // Apply scaling to each block
  const normalized = blocks.map((block) => {
    const normalizedDuration = block.durationHours * scaleFactor;
    return {
      ...block,
      durationHours: parseFloat(normalizedDuration.toFixed(2)),
    };
  });

  // Ensure exact sum by adjusting the last block if needed
  const finalSum = normalized.reduce((sum, block) => sum + block.durationHours, 0);
  const difference = Math.abs(finalSum - targetHours);

  if (difference > 0.01) {
    // Fine-tune the last block to ensure exact sum
    const sumWithoutLast = normalized.slice(0, -1).reduce((sum, block) => sum + block.durationHours, 0);
    const lastBlockTarget = targetHours - sumWithoutLast;
    normalized[normalized.length - 1].durationHours = parseFloat(Math.max(0.1, lastBlockTarget).toFixed(2));
    
    logger.debug(
      { 
        beforeSum, 
        afterSum: normalized.reduce((sum, block) => sum + block.durationHours, 0),
        targetHours,
        adjustment: lastBlockTarget
      }, 
      'Adjusted final block for exact sum'
    );
  }

  return normalized;
}

/**
 * Normalizes all time blocks in a plan to ensure daily budgets are met.
 * 
 * @param {object} plan - The generated plan with timeBlocks
 * @param {object} profile - User profile with timeBudgetHoursPerDay
 * @param {object} traceId - Trace ID for logging
 * @returns {object} Plan with normalized durations
 */
export function normalizePlanDurations(plan, profile, traceId = null) {
  if (!plan || !plan.timeBlocks || !profile || !profile.timeBudgetHoursPerDay) {
    logger.warn(
      { 
        traceId, 
        hasPlan: !!plan, 
        hasTimeBlocks: !!plan?.timeBlocks, 
        hasProfile: !!profile, 
        hasBudget: !!profile?.timeBudgetHoursPerDay 
      },
      'Normalization skipped - missing required data'
    );
    return plan;
  }

  const targetHours = profile.timeBudgetHoursPerDay;
  
  logger.info(
    { 
      traceId, 
      targetHours,
      dayCount: Object.keys(plan.timeBlocks).length 
    },
    'Starting duration normalization'
  );
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  let totalCorrections = 0;

  // Normalize each day
  const normalizedPlan = {
    ...plan,
    timeBlocks: {},
  };

  for (const day of days) {
    const blocks = plan.timeBlocks[day] || [];
    
    if (blocks.length === 0) {
      normalizedPlan.timeBlocks[day] = [];
      continue;
    }

    const beforeSum = blocks.reduce((sum, block) => sum + block.durationHours, 0);
    
    logger.debug(
      { 
        traceId, 
        day, 
        beforeSum, 
        targetHours, 
        blockCount: blocks.length,
        blocks: blocks.map(b => b.durationHours)
      },
      'Processing day'
    );
    
    const normalized = normalizeDayBlockDurations(blocks, targetHours);
    const afterSum = normalized.reduce((sum, block) => sum + block.durationHours, 0);

    normalizedPlan.timeBlocks[day] = normalized;
    
    // Always log the results to verify normalization
    const finalCheck = normalized.reduce((sum, block) => sum + block.durationHours, 0);
    totalCorrections++;
    
    logger.info(
      { 
        traceId, 
        day, 
        beforeSum, 
        finalCheck,
        targetHours,
        normalized: normalized.map(b => b.durationHours)
      },
      'Normalized day durations'
    );
  }

  if (totalCorrections > 0) {
    logger.info(
      { 
        traceId, 
        totalCorrections 
      },
      'Normalized durations across all days'
    );
  }

  return normalizedPlan;
}

/**
 * Gets available days from user profile for validation.
 * 
 * @param {object} profile - User profile
 * @returns {Array<string>} Array of weekday abbreviations
 */
function getAvailableDays(profile) {
  if (!profile.availableDays || !Array.isArray(profile.availableDays)) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  // Map day names to abbreviations
  const dayMap = {
    'Monday': 'Mon',
    'Tuesday': 'Tue',
    'Wednesday': 'Wed',
    'Thursday': 'Thu',
    'Friday': 'Fri',
    'Saturday': 'Sat',
    'Sunday': 'Sun',
  };

  return profile.availableDays.map(day => dayMap[day] || day);
}

