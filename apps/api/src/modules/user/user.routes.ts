// ===========================================
// IAção API - User Routes
// ===========================================

import { Router, Request, Response } from 'express';
import type { Router as IRouter } from 'express';
import { ApiResponse } from '../../types';

export const userRoutes: IRouter = Router();

// Placeholder - will be implemented after auth
userRoutes.get('/me', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Get current user - Coming soon' },
  });
});

userRoutes.patch('/me', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Update current user - Coming soon' },
  });
});
