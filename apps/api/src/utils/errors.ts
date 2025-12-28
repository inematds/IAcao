// ===========================================
// IAção API - Custom Errors
// ===========================================

import { HttpStatus } from '@iacao/shared';

export class ApplicationError extends Error {
  public readonly statusCode: number;
  public readonly code: string;
  public readonly details?: Record<string, unknown>;

  constructor(
    message: string,
    statusCode: number = HttpStatus.INTERNAL_SERVER_ERROR,
    code: string = 'INTERNAL_ERROR',
    details?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends ApplicationError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(message, HttpStatus.BAD_REQUEST, 'VALIDATION_ERROR', details);
  }
}

export class AuthenticationError extends ApplicationError {
  constructor(message: string = 'Authentication required') {
    super(message, HttpStatus.UNAUTHORIZED, 'AUTHENTICATION_ERROR');
  }
}

export class AuthorizationError extends ApplicationError {
  constructor(message: string = 'Access denied') {
    super(message, HttpStatus.FORBIDDEN, 'AUTHORIZATION_ERROR');
  }
}

export class NotFoundError extends ApplicationError {
  constructor(resource: string = 'Resource') {
    super(`${resource} not found`, HttpStatus.NOT_FOUND, 'NOT_FOUND');
  }
}

export class ConflictError extends ApplicationError {
  constructor(message: string) {
    super(message, HttpStatus.CONFLICT, 'CONFLICT_ERROR');
  }
}

export class RateLimitError extends ApplicationError {
  constructor(message: string = 'Too many requests') {
    super(message, HttpStatus.TOO_MANY_REQUESTS, 'RATE_LIMIT_ERROR');
  }
}

export class ExternalServiceError extends ApplicationError {
  constructor(service: string, message: string) {
    super(`${service}: ${message}`, HttpStatus.SERVICE_UNAVAILABLE, 'EXTERNAL_SERVICE_ERROR');
  }
}

export class InsufficientEnergyError extends ApplicationError {
  constructor(required: number, current: number) {
    super(
      `Insufficient energy. Required: ${required}, Current: ${current}`,
      HttpStatus.BAD_REQUEST,
      'INSUFFICIENT_ENERGY',
      { required, current }
    );
  }
}
