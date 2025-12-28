// ===========================================
// IAção API - AI Rate Limiting Middleware
// ===========================================

import { Request, Response, NextFunction } from 'express';
import { config } from '../config';
import { logger } from '../utils/logger';

// Simple in-memory rate limiting (for production, use Redis)
interface RateLimitEntry {
  minute: number[];
  hour: number[];
  day: number[];
}

const rateLimitMap = new Map<string, RateLimitEntry>();

// Clean up old entries every 5 minutes
setInterval(() => {
  const now = Date.now();
  const dayAgo = now - 24 * 60 * 60 * 1000;

  for (const [key, entry] of rateLimitMap.entries()) {
    entry.day = entry.day.filter(t => t > dayAgo);
    if (entry.day.length === 0) {
      rateLimitMap.delete(key);
    }
  }
}, 5 * 60 * 1000);

export function aiRateLimit(req: Request, res: Response, next: NextFunction): void {
  const userId = (req as any).user?.id || req.ip || 'anonymous';
  const now = Date.now();

  // Get or create rate limit entry
  let entry = rateLimitMap.get(userId);
  if (!entry) {
    entry = { minute: [], hour: [], day: [] };
    rateLimitMap.set(userId, entry);
  }

  // Clean old timestamps
  const minuteAgo = now - 60 * 1000;
  const hourAgo = now - 60 * 60 * 1000;
  const dayAgo = now - 24 * 60 * 60 * 1000;

  entry.minute = entry.minute.filter(t => t > minuteAgo);
  entry.hour = entry.hour.filter(t => t > hourAgo);
  entry.day = entry.day.filter(t => t > dayAgo);

  // Check limits
  const limits = {
    minute: config.aiRateLimitPerMinute,
    hour: config.aiRateLimitPerHour,
    day: config.aiRateLimitPerDay,
  };

  if (entry.minute.length >= limits.minute) {
    logger.warn(`[AIRateLimit] User ${userId} exceeded minute limit`);
    res.status(429).json({
      success: false,
      error: 'Muitas requisições. Aguarde um minuto.',
      retryAfter: 60,
    });
    return;
  }

  if (entry.hour.length >= limits.hour) {
    logger.warn(`[AIRateLimit] User ${userId} exceeded hour limit`);
    res.status(429).json({
      success: false,
      error: 'Limite horário atingido. Tente novamente mais tarde.',
      retryAfter: 3600,
    });
    return;
  }

  if (entry.day.length >= limits.day) {
    logger.warn(`[AIRateLimit] User ${userId} exceeded day limit`);
    res.status(429).json({
      success: false,
      error: 'Limite diário atingido. Volte amanhã!',
      retryAfter: 86400,
    });
    return;
  }

  // Record this request
  entry.minute.push(now);
  entry.hour.push(now);
  entry.day.push(now);

  // Add headers
  res.setHeader('X-RateLimit-Limit-Minute', limits.minute.toString());
  res.setHeader('X-RateLimit-Remaining-Minute', (limits.minute - entry.minute.length).toString());
  res.setHeader('X-RateLimit-Limit-Day', limits.day.toString());
  res.setHeader('X-RateLimit-Remaining-Day', (limits.day - entry.day.length).toString());

  next();
}
