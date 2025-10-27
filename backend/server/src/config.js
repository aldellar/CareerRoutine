/**
 * config.js
 * Loads environment variables and exports application configuration.
 */

import dotenv from 'dotenv';

// Load .env file
dotenv.config();

// Validate required environment variables
const requiredEnvVars = ['OPENAI_API_KEY'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`Missing required environment variable: ${envVar}`);
  }
}

// Parse CORS origins from comma-separated string
const parseCorsOrigins = (str) => {
  if (!str) return ['http://localhost:3000', 'http://localhost:8081'];
  return str.split(',').map((origin) => origin.trim());
};

// Export configuration object
const config = {
  // Server
  port: parseInt(process.env.PORT || '8081', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  
  // OpenAI
  openaiApiKey: process.env.OPENAI_API_KEY,
  openaiModel: process.env.OPENAI_MODEL || 'gpt-4o-mini',
  openaiTimeoutMs: parseInt(process.env.OPENAI_TIMEOUT_MS || '60000', 10),  // 60 seconds for complex generation
  
  // CORS
  allowedOrigins: parseCorsOrigins(process.env.CORS_ORIGIN),
  
  // Rate limiting
  rateWindowMs: parseInt(process.env.RATE_WINDOW_MS || '60000', 10),
  rateMax: parseInt(process.env.RATE_MAX || '60', 10),
};

export default config;

