// ===========================================
// IAção API - JWT Service Tests
// ===========================================

import { describe, it, expect, beforeAll } from 'vitest';
import {
  generateAccessToken,
  generateRefreshToken,
  generateTokenPair,
  verifyAccessToken,
  verifyRefreshToken,
  extractTokenFromHeader,
} from '../jwt.service';

describe('JWT Service', () => {
  const testPayload = {
    userId: 'test-user-123',
    email: 'test@example.com',
    role: 'student' as const,
  };

  describe('generateAccessToken', () => {
    it('should generate a valid access token', async () => {
      const token = await generateAccessToken(testPayload);

      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.').length).toBe(3); // JWT has 3 parts
    });
  });

  describe('generateRefreshToken', () => {
    it('should generate a valid refresh token', async () => {
      const token = await generateRefreshToken(testPayload);

      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.').length).toBe(3);
    });
  });

  describe('generateTokenPair', () => {
    it('should generate both access and refresh tokens', async () => {
      const tokens = await generateTokenPair(testPayload);

      expect(tokens.accessToken).toBeDefined();
      expect(tokens.refreshToken).toBeDefined();
      expect(tokens.expiresIn).toBeGreaterThan(0);
    });

    it('should generate different tokens for access and refresh', async () => {
      const tokens = await generateTokenPair(testPayload);

      expect(tokens.accessToken).not.toBe(tokens.refreshToken);
    });
  });

  describe('verifyAccessToken', () => {
    it('should verify a valid access token', async () => {
      const token = await generateAccessToken(testPayload);
      const payload = await verifyAccessToken(token);

      expect(payload).toBeDefined();
      expect(payload?.userId).toBe(testPayload.userId);
      expect(payload?.email).toBe(testPayload.email);
      expect(payload?.role).toBe(testPayload.role);
      expect(payload?.type).toBe('access');
    });

    it('should return null for a refresh token', async () => {
      const token = await generateRefreshToken(testPayload);
      const payload = await verifyAccessToken(token);

      expect(payload).toBeNull();
    });

    it('should return null for an invalid token', async () => {
      const payload = await verifyAccessToken('invalid.token.here');

      expect(payload).toBeNull();
    });
  });

  describe('verifyRefreshToken', () => {
    it('should verify a valid refresh token', async () => {
      const token = await generateRefreshToken(testPayload);
      const payload = await verifyRefreshToken(token);

      expect(payload).toBeDefined();
      expect(payload?.userId).toBe(testPayload.userId);
      expect(payload?.type).toBe('refresh');
    });

    it('should return null for an access token', async () => {
      const token = await generateAccessToken(testPayload);
      const payload = await verifyRefreshToken(token);

      expect(payload).toBeNull();
    });
  });

  describe('extractTokenFromHeader', () => {
    it('should extract token from valid Bearer header', () => {
      const token = extractTokenFromHeader('Bearer eyJhbGciOiJIUzI1NiJ9.test.test');

      expect(token).toBe('eyJhbGciOiJIUzI1NiJ9.test.test');
    });

    it('should return null for missing header', () => {
      const token = extractTokenFromHeader(undefined);

      expect(token).toBeNull();
    });

    it('should return null for invalid format', () => {
      expect(extractTokenFromHeader('Basic token')).toBeNull();
      expect(extractTokenFromHeader('BearerToken')).toBeNull();
      expect(extractTokenFromHeader('Bearer')).toBeNull();
    });
  });
});
