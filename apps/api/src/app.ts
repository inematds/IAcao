// ===========================================
// IAção API - Express App
// ===========================================

import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import pinoHttp from 'pino-http';

import { config } from './config';
import { connectDatabase } from './config/database';
import { logger } from './utils/logger';
import { errorHandler } from './middleware/errorHandler';
import { notFoundHandler } from './middleware/notFoundHandler';

// Routes
import { healthRoutes } from './modules/health/health.routes';
import { authRoutes } from './modules/auth/auth.routes';
import { userRoutes } from './modules/user/user.routes';
import { gameRoutes } from './modules/game/game.routes';
import { aiRoutes } from './modules/ai/ai.routes';

export async function createApp(): Promise<Express> {
  const app = express();

  // Connect to database
  await connectDatabase();

  // Security middleware
  app.use(helmet());
  app.use(
    cors({
      origin: config.corsOrigins.split(','),
      credentials: true,
    })
  );

  // Body parsing
  app.use(express.json({ limit: '10kb' }));
  app.use(express.urlencoded({ extended: true }));

  // Request logging
  app.use(
    pinoHttp({
      logger,
      autoLogging: {
        ignore: req => req.url === '/health',
      },
    })
  );

  // API Routes
  const apiPrefix = '/api/v1';

  app.use('/health', healthRoutes);
  app.use(`${apiPrefix}/auth`, authRoutes);
  app.use(`${apiPrefix}/users`, userRoutes);
  app.use(`${apiPrefix}/game`, gameRoutes);
  app.use(`${apiPrefix}/ai`, aiRoutes);

  // Error handling
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
