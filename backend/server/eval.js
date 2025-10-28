#!/usr/bin/env node

/**
 * eval.js
 * Evaluation script for analyzing LLM interaction logs
 * 
 * Usage:
 *   node eval.js                    # Show summary of all logs
 *   node eval.js --latest           # Show latest log
 *   node eval.js --find <traceId>   # Find specific log
 *   node eval.js --risk             # Show high-risk interactions
 *   node eval.js --slow             # Show slowest interactions
 */

import { analyzeEvalLogs, findLogByTraceId, detectRegression } from './src/utils/logAnalysis.js';

const command = process.argv[2];
const arg = process.argv[3];

async function showSummary() {
  const report = await analyzeEvalLogs();
  if (!report) return;
  
  console.log('\n📊 EVALUATION REPORT');
  console.log('═'.repeat(50));
  
  console.log('\n📈 Summary:');
  console.log(`  Total interactions: ${report.summary.totalInteractions}`);
  console.log(`  Date range: ${report.summary.dateRange.earliest.split('T')[0]} → ${report.summary.dateRange.latest.split('T')[0]}`);
  
  console.log('\n⚡ Performance:');
  console.log(`  Avg latency: ${report.performance.avgLatencyMs}ms`);
  console.log(`  Avg tokens: ${report.performance.avgTokens}`);
  console.log(`  Avg response length: ${report.performance.avgResponseLength} chars`);
  
  console.log('\n🎯 Quality:');
  console.log(`  Avg risk score: ${report.quality.avgRiskScore}`);
  console.log(`  Avg confidence: ${report.quality.avgConfidence}`);
  console.log(`  High risk rate: ${report.quality.highRiskRate}%`);
  
  console.log('\n🔗 Content:');
  console.log(`  Responses with URLs: ${report.content.responsesWithURLs}/${report.summary.totalInteractions}`);
  console.log(`  URL rate: ${report.content.urlRate}%`);
  
  console.log('\n✅ Safety:');
  console.log(`  High risk interactions: ${report.safety.highRiskCount}`);
  console.log(`  High risk rate: ${report.safety.highRiskRate}%`);
  
  if (report.quality.highRiskRate > 10) {
    console.log('\n⚠️  WARNING: High risk rate > 10%. Prompt may need refinement.');
  }
  
  if (report.performance.avgLatencyMs > 5000) {
    console.log('\n⚠️  WARNING: Average latency > 5s. Performance may need optimization.');
  }
  
  console.log('\n');
}

async function findLog(traceId) {
  const log = await findLogByTraceId(traceId);
  if (!log) {
    console.log(`No log found with traceId: ${traceId}`);
    return;
  }
  
  console.log('\n📝 LOG DETAILS');
  console.log('═'.repeat(50));
  console.log(`TraceId: ${log.traceId}`);
  console.log(`Timestamp: ${log.timestamp}`);
  console.log(`Model: ${log.model}`);
  console.log(`Latency: ${log.latencyMs}ms`);
  console.log(`Risk Level: ${log.riskLevel}`);
  console.log(`Risk Score: ${log.riskScore}`);
  console.log(`Confidence: ${log.confidence}`);
  console.log(`Tokens: ${log.tokens}`);
  console.log(`\nPrompt length: ${log.promptLength} chars`);
  console.log(`Response length: ${log.responseLength} chars`);
  
  if (log.hasHighRisk) {
    console.log('\n⚠️  HIGH RISK INTERACTION');
  }
  
  console.log('\n');
}

async function showLatest() {
  console.log('Latest log functionality - use --find with traceId from logs');
}

async function showHighRisk() {
  console.log('High risk interactions - coming soon');
}

async function showSlowest() {
  console.log('Slowest interactions - coming soon');
}

// Run command
(async () => {
  try {
    switch (command) {
      case '--latest':
        await showLatest();
        break;
      case '--find':
        await findLog(arg);
        break;
      case '--risk':
        await showHighRisk();
        break;
      case '--slow':
        await showSlowest();
        break;
      default:
        await showSummary();
    }
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
})();

