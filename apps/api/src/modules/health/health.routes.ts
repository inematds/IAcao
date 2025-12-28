// ===========================================
// IAção API - Health Routes
// ===========================================

import { Router, Request, Response } from 'express';
import type { Router as IRouter } from 'express';
import { prisma } from '../../config/database';
import { ApiResponse } from '../../types';

export const healthRoutes: IRouter = Router();

interface HealthStatus {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  uptime: number;
  services: {
    database: 'connected' | 'disconnected';
  };
}

healthRoutes.get('/', async (req: Request, res: Response<ApiResponse<HealthStatus>>) => {
  let dbStatus: 'connected' | 'disconnected' = 'disconnected';

  try {
    await prisma.$queryRaw`SELECT 1`;
    dbStatus = 'connected';
  } catch {
    dbStatus = 'disconnected';
  }

  const health: HealthStatus = {
    status: dbStatus === 'connected' ? 'healthy' : 'unhealthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    services: {
      database: dbStatus,
    },
  };

  const statusCode = health.status === 'healthy' ? 200 : 503;

  res.status(statusCode).json({
    success: health.status === 'healthy',
    data: health,
  });
});
