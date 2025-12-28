// ===========================================
// IAção API - Not Found Handler
// ===========================================

import { Request, Response } from 'express';
import { ApiResponse, HttpStatus } from '@iacao/shared';

export function notFoundHandler(req: Request, res: Response<ApiResponse>): void {
  res.status(HttpStatus.NOT_FOUND).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `Route ${req.method} ${req.path} not found`,
    },
  });
}
