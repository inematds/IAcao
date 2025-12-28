// ===========================================
// IAção API - Auth Routes
// ===========================================

import { Router, Request, Response } from 'express';
import { ApiResponse } from '@iacao/shared';

export const authRoutes = Router();

// Placeholder - will be implemented in Story 1.4
authRoutes.get('/google', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Google OAuth - Coming soon' },
  });
});

authRoutes.get('/microsoft', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Microsoft OAuth - Coming soon' },
  });
});

authRoutes.post('/refresh', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Token refresh - Coming soon' },
  });
});

authRoutes.post('/logout', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'Logout - Coming soon' },
  });
});
