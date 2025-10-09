/**
 * index.js
 * Main Express server for CareerRoutine API.
 * Stateless, secure, production-ready.
 */

import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { rateLimit } from 'express-rate-limit';
import { v4 as uuidv4 } from 'uuid';
import config from './config.js';
import logger from './utils/logger.js';
import generateRoutes from './routes/generate.js';

const app = express();

// Security middleware
app.use(helmet());

// CORS configuration
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, curl, etc.)
      if (!origin) return callback(null, true);
      
      if (config.allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true,
  })
);

// Body parsing with size limit
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: config.rateWindowMs,
  max: config.rateMax,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later.' },
});
app.use(limiter);

// Request logging and traceId middleware
app.use((req, res, next) => {
  req.traceId = uuidv4();
  
  logger.info({
    traceId: req.traceId,
    method: req.method,
    path: req.path,
    ip: req.ip,
  }, 'Incoming request');
  
  // Log response
  const originalSend = res.send;
  res.send = function (data) {
    logger.info({
      traceId: req.traceId,
      statusCode: res.statusCode,
    }, 'Response sent');
    
    originalSend.call(this, data);
  };
  
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// API routes
app.use('/generate', generateRoutes);
app.use('/reroll', generateRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
  });
});

// Global error handler
app.use((err, req, res, next) => {
  // Determine status code
  const statusCode = err.statusCode || 500;
  
  // Log error
  logger.error({
    traceId: req.traceId,
    error: err.message,
    stack: config.nodeEnv === 'development' ? err.stack : undefined,
    statusCode,
  }, 'Request error');

  // Prepare error response
  const errorResponse = {
    error: err.message || 'Internal Server Error',
    traceId: req.traceId,
  };

  // Include details for validation errors
  if (err.details) {
    errorResponse.details = err.details;
  }

  // Include original error for debugging in dev
  if (config.nodeEnv === 'development' && err.originalError) {
    errorResponse.originalError = err.originalError;
  }

  res.status(statusCode).json(errorResponse);
});

// Start server
const server = app.listen(config.port, () => {
  logger.info({
    port: config.port,
    nodeEnv: config.nodeEnv,
    model: config.openaiModel,
  }, 'Server started successfully');
});

// Graceful shutdown
const shutdown = (signal) => {
  logger.info({ signal }, 'Received shutdown signal');
  
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });

  // Force close after 10s
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Unhandled rejection handler
process.on('unhandledRejection', (reason, promise) => {
  logger.error({ reason, promise }, 'Unhandled Rejection');
});

export default app;

