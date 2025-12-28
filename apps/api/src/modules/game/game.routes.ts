// ===========================================
// IAção API - Game Routes
// ===========================================

import { Router, Request, Response } from 'express';
import type { Router as IRouter } from 'express';
import { ApiResponse } from '../../types';

export const gameRoutes: IRouter = Router();

// Placeholder routes - will be implemented in later stories
gameRoutes.get('/load', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Load game state - Coming soon' },
  });
});

gameRoutes.post('/save', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Save game state - Coming soon' },
  });
});

gameRoutes.post('/choice', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Record choice - Coming soon' },
  });
});

gameRoutes.post('/mission/complete', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Complete mission - Coming soon' },
  });
});
