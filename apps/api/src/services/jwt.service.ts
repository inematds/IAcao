// ===========================================
// IAção API - JWT Service
// ===========================================

import * as jose from 'jose';
import { config } from '../config';
import { logger } from '../utils/logger';

// Token types
export interface TokenPayload {
  userId: string;
  email: string;
  role: 'student' | 'teacher' | 'parent' | 'admin';
  type: 'access' | 'refresh';
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

// Convert duration string to seconds
function parseDuration(duration: string): number {
  const match = duration.match(/^(\d+)([smhd])$/);
  if (!match) return 900; // default 15 minutes

  const value = parseInt(match[1], 10);
  const unit = match[2];

  switch (unit) {
    case 's':
      return value;
    case 'm':
      return value * 60;
    case 'h':
      return value * 3600;
    case 'd':
      return value * 86400;
    default:
      return 900;
  }
}

// Create secret key from config
const getSecretKey = () => new TextEncoder().encode(config.jwtSecret);

// ===========================================
// Token Generation
// ===========================================

export async function generateAccessToken(
  payload: Omit<TokenPayload, 'type'>
): Promise<string> {
  const secret = getSecretKey();
  const expiresIn = parseDuration(config.jwtExpiresIn);

  const token = await new jose.SignJWT({ ...payload, type: 'access' })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(`${expiresIn}s`)
    .setIssuer('iacao-api')
    .setAudience('iacao-client')
    .sign(secret);

  return token;
}

export async function generateRefreshToken(
  payload: Omit<TokenPayload, 'type'>
): Promise<string> {
  const secret = getSecretKey();
  const expiresIn = parseDuration(config.refreshTokenExpiresIn);

  const token = await new jose.SignJWT({ ...payload, type: 'refresh' })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(`${expiresIn}s`)
    .setIssuer('iacao-api')
    .setAudience('iacao-client')
    .sign(secret);

  return token;
}

export async function generateTokenPair(
  payload: Omit<TokenPayload, 'type'>
): Promise<TokenPair> {
  const [accessToken, refreshToken] = await Promise.all([
    generateAccessToken(payload),
    generateRefreshToken(payload),
  ]);

  return {
    accessToken,
    refreshToken,
    expiresIn: parseDuration(config.jwtExpiresIn),
  };
}

// ===========================================
// Token Verification
// ===========================================

export async function verifyToken(token: string): Promise<TokenPayload | null> {
  try {
    const secret = getSecretKey();
    const { payload } = await jose.jwtVerify(token, secret, {
      issuer: 'iacao-api',
      audience: 'iacao-client',
    });

    return payload as unknown as TokenPayload;
  } catch (error) {
    if (error instanceof jose.errors.JWTExpired) {
      logger.debug('Token expired');
    } else if (error instanceof jose.errors.JWTInvalid) {
      logger.warn('Invalid token');
    } else {
      logger.error({ error }, 'Token verification error');
    }
    return null;
  }
}

export async function verifyAccessToken(
  token: string
): Promise<TokenPayload | null> {
  const payload = await verifyToken(token);
  if (payload && payload.type === 'access') {
    return payload;
  }
  return null;
}

export async function verifyRefreshToken(
  token: string
): Promise<TokenPayload | null> {
  const payload = await verifyToken(token);
  if (payload && payload.type === 'refresh') {
    return payload;
  }
  return null;
}

// ===========================================
// Token Extraction
// ===========================================

export function extractTokenFromHeader(
  authHeader: string | undefined
): string | null {
  if (!authHeader) return null;

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
    return null;
  }

  return parts[1];
}
