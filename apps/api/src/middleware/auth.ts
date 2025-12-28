// ===========================================
// IAção API - Authentication Middleware
// ===========================================

import { Request, Response, NextFunction } from 'express';
import { HttpStatus } from '../utils/httpStatus';
import { ApiResponse } from '../types';
import {
  verifyAccessToken,
  extractTokenFromHeader,
} from '../services/jwt.service';
import { getUserById } from '../services/auth.service';
import { logger } from '../utils/logger';

// Auth user type for request
export interface AuthUser {
  id: string;
  email: string;
  role: 'student' | 'teacher' | 'parent' | 'admin';
}

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      authUser?: AuthUser;
    }
  }
}

// ===========================================
// Authentication Required
// ===========================================

export async function requireAuth(
  req: Request,
  res: Response<ApiResponse>,
  next: NextFunction
): Promise<void> {
  try {
    const token = extractTokenFromHeader(req.headers.authorization);

    if (!token) {
      res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Token de autenticação não fornecido',
        },
      });
      return;
    }

    const payload = await verifyAccessToken(token);

    if (!payload) {
      res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: {
          code: 'INVALID_TOKEN',
          message: 'Token inválido ou expirado',
        },
      });
      return;
    }

    // Verify user still exists and is active
    const user = await getUserById(payload.userId);

    if (!user) {
      res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'Usuário não encontrado',
        },
      });
      return;
    }

    if (!user.isActive) {
      res.status(HttpStatus.FORBIDDEN).json({
        success: false,
        error: {
          code: 'ACCOUNT_DISABLED',
          message: 'Conta desativada',
        },
      });
      return;
    }

    // Attach user to request
    req.authUser = {
      id: payload.userId,
      email: payload.email,
      role: payload.role,
    };

    next();
  } catch (error) {
    logger.error({ error }, 'Auth middleware error');
    res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      success: false,
      error: {
        code: 'AUTH_ERROR',
        message: 'Erro na autenticação',
      },
    });
  }
}

// ===========================================
// Optional Authentication
// ===========================================

export async function optionalAuth(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const token = extractTokenFromHeader(req.headers.authorization);

    if (token) {
      const payload = await verifyAccessToken(token);

      if (payload) {
        req.authUser = {
          id: payload.userId,
          email: payload.email,
          role: payload.role,
        };
      }
    }

    next();
  } catch (error) {
    // Silently ignore errors for optional auth
    next();
  }
}

// ===========================================
// Role-based Authorization
// ===========================================

export function requireRole(...roles: Array<'student' | 'teacher' | 'parent' | 'admin'>) {
  return (req: Request, res: Response<ApiResponse>, next: NextFunction): void => {
    if (!req.authUser) {
      res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Autenticação necessária',
        },
      });
      return;
    }

    if (!roles.includes(req.authUser.role)) {
      res.status(HttpStatus.FORBIDDEN).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'Permissão insuficiente para esta ação',
        },
      });
      return;
    }

    next();
  };
}

// Convenience middleware for teacher/admin only routes
export const requireTeacher = requireRole('teacher', 'admin');
export const requireAdmin = requireRole('admin');
