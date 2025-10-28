/**
 * logAnalysis.js
 * Analyze logged LLM interactions for prompt refinement
 */

import logger from './logger.js';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Path to store eval logs
const EVAL_LOG_DIR = path.join(__dirname, '../../eval-logs');

/**
 * Stores LLM interaction to file for evaluation
 */
export async function storeEvalLog(interactionData) {
  try {
    await fs.mkdir(EVAL_LOG_DIR, { recursive: true });
    
    const filename = `eval-${Date.now()}-${interactionData.traceId}.json`;
    const filepath = path.join(EVAL_LOG_DIR, filename);
    
    await fs.writeFile(
      filepath,
      JSON.stringify(interactionData, null, 2)
    );
    
    logger.info({ traceId: interactionData.traceId }, 'Eval log stored');
  } catch (error) {
    logger.error({ error: error.message }, 'Failed to store eval log');
  }
}

/**
 * Analyze eval logs and generate metrics report
 */
export async function analyzeEvalLogs() {
  try {
    const files = await fs.readdir(EVAL_LOG_DIR);
    const evalFiles = files.filter(f => f.startsWith('eval-'));
    
    if (evalFiles.length === 0) {
      console.log('No eval logs found');
      return null;
    }
    
    const logs = [];
    for (const file of evalFiles) {
      const content = await fs.readFile(
        path.join(EVAL_LOG_DIR, file),
        'utf-8'
      );
      logs.push(JSON.parse(content));
    }
    
    // Calculate metrics
    const totalLogs = logs.length;
    const avgLatency = logs.reduce((sum, log) => sum + (log.latencyMs || 0), 0) / totalLogs;
    const avgTokens = logs.reduce((sum, log) => sum + (log.tokens || 0), 0) / totalLogs;
    const avgRiskScore = logs.reduce((sum, log) => sum + (log.riskScore || 0), 0) / totalLogs;
    const avgConfidence = logs.reduce((sum, log) => sum + (log.confidence || 0), 0) / totalLogs;
    
    const highRiskCount = logs.filter(log => log.hasHighRisk).length;
    const highRiskRate = (highRiskCount / totalLogs) * 100;
    
    const avgResponseLength = logs.reduce((sum, log) => sum + (log.responseLength || 0), 0) / totalLogs;
    const withURLs = logs.filter(log => log.hasURLs).length;
    
    const report = {
      summary: {
        totalInteractions: totalLogs,
        dateRange: {
          earliest: logs[0].timestamp,
          latest: logs[logs.length - 1].timestamp
        }
      },
      performance: {
        avgLatencyMs: Math.round(avgLatency),
        avgTokens: Math.round(avgTokens),
        avgResponseLength: Math.round(avgResponseLength)
      },
      quality: {
        avgRiskScore: parseFloat(avgRiskScore.toFixed(2)),
        avgConfidence: parseFloat(avgConfidence.toFixed(2)),
        highRiskRate: parseFloat(highRiskRate.toFixed(2))
      },
      content: {
        responsesWithURLs: withURLs,
        urlRate: parseFloat(((withURLs / totalLogs) * 100).toFixed(2))
      },
      safety: {
        highRiskCount,
        highRiskRate: parseFloat(highRiskRate.toFixed(2))
      }
    };
    
    logger.info(report, 'Eval analysis complete');
    return report;
    
  } catch (error) {
    logger.error({ error: error.message }, 'Failed to analyze eval logs');
    throw error;
  }
}

/**
 * Find specific log by traceId
 */
export async function findLogByTraceId(traceId) {
  try {
    const files = await fs.readdir(EVAL_LOG_DIR);
    const matchingFile = files.find(f => f.includes(traceId));
    
    if (!matchingFile) {
      return null;
    }
    
    const content = await fs.readFile(
      path.join(EVAL_LOG_DIR, matchingFile),
      'utf-8'
    );
    
    return JSON.parse(content);
  } catch (error) {
    logger.error({ error: error.message }, 'Failed to find log');
    return null;
  }
}

/**
 * Compare logs to identify regressions
 */
export async function detectRegression(latestLog, baselineLogs) {
  const issues = [];
  
  // Check latency regression
  const avgBaselineLatency = baselineLogs.reduce((sum, log) => sum + log.latencyMs, 0) / baselineLogs.length;
  if (latestLog.latencyMs > avgBaselineLatency * 1.5) {
    issues.push({
      type: 'performance',
      message: `Latency spike: ${latestLog.latencyMs}ms (baseline: ${avgBaselineLatency.toFixed(0)}ms)`
    });
  }
  
  // Check safety regression
  const avgBaselineRisk = baselineLogs.reduce((sum, log) => sum + log.riskScore, 0) / baselineLogs.length;
  if (latestLog.riskScore > avgBaselineRisk * 1.3) {
    issues.push({
      type: 'safety',
      message: `Risk score increase: ${latestLog.riskScore} (baseline: ${avgBaselineRisk.toFixed(2)})`
    });
  }
  
  // Check quality regression
  const avgBaselineConfidence = baselineLogs.reduce((sum, log) => sum + log.confidence, 0) / baselineLogs.length;
  if (latestLog.confidence < avgBaselineConfidence * 0.9) {
    issues.push({
      type: 'quality',
      message: `Confidence drop: ${latestLog.confidence} (baseline: ${avgBaselineConfidence.toFixed(2)})`
    });
  }
  
  return issues;
}

