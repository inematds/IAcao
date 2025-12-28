// ===========================================
// IAção API - AI (ARIA) Routes
// ===========================================

import { Router, Request, Response } from 'express';
import type { Router as IRouter } from 'express';
import { ApiResponse } from '../../types';

export const aiRoutes: IRouter = Router();

// Placeholder - will be implemented in Epic 4
aiRoutes.post('/query', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: { message: 'AI query - Coming soon' },
  });
});

aiRoutes.get('/health', (req: Request, res: Response<ApiResponse>) => {
  res.json({
    success: true,
    data: {
      status: 'ready',
      provider: 'openai',
      model: 'gpt-4o-mini',
    },
  });
});
