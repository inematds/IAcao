// ===========================================
// IAção API - Error Handler Middleware
// ===========================================

import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { ApplicationError } from '../utils/errors';
import { logger } from '../utils/logger';
import { HttpStatus } from '../utils/httpStatus';
import { ApiResponse } from '../types';

export function errorHandler(
  error: Error,
  req: Request,
  res: Response<ApiResponse>,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction
): void {
  // Log error
  logger.error({
    err: error,
    req: {
      method: req.method,
      url: req.url,
      body: req.body,
    },
  });

  // Handle Zod validation errors
  if (error instanceof ZodError) {
    res.status(HttpStatus.BAD_REQUEST).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        details: { errors: error.errors },
      },
    });
    return;
  }

  // Handle application errors
  if (error instanceof ApplicationError) {
    res.status(error.statusCode).json({
      success: false,
      error: {
        code: error.code,
        message: error.message,
        details: error.details,
      },
    });
    return;
  }

  // Handle unknown errors
  res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message:
        process.env.NODE_ENV === 'production'
          ? 'An unexpected error occurred'
          : error.message,
    },
  });
}
