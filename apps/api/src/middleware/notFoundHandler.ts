// ===========================================
// IAção API - Not Found Handler
// ===========================================

import { Request, Response } from 'express';
import { HttpStatus } from '../utils/httpStatus';
import { ApiResponse } from '../types';

export function notFoundHandler(req: Request, res: Response<ApiResponse>): void {
  res.status(HttpStatus.NOT_FOUND).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `Route ${req.method} ${req.path} not found`,
    },
  });
}
