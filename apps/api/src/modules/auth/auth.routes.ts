// ===========================================
// IAção API - Auth Routes
// ===========================================

import { Router, Request, Response } from 'express';
import type { Router as IRouter } from 'express';
import { HttpStatus } from '../../utils/httpStatus';
import { ApiResponse } from '../../types';
import { passport } from '../../config/passport';
import { config } from '../../config';
import {
  verifyRefreshToken,
} from '../../services/jwt.service';
import { refreshUserTokens, AuthUser } from '../../services/auth.service';
import { requireAuth } from '../../middleware/auth';
import { logger } from '../../utils/logger';

export const authRoutes: IRouter = Router();

// ===========================================
// Google OAuth
// ===========================================

// Initiate Google OAuth flow
authRoutes.get('/google', (req, res, next) => {
  if (!config.googleClientId) {
    res.status(HttpStatus.SERVICE_UNAVAILABLE).json({
      success: false,
      error: {
        code: 'OAUTH_NOT_CONFIGURED',
        message: 'Google OAuth não está configurado',
      },
    } as ApiResponse);
    return;
  }

  passport.authenticate('google', {
    scope: ['profile', 'email'],
    session: false,
  })(req, res, next);
});

// Google OAuth callback
authRoutes.get('/google/callback', (req, res, next) => {
  passport.authenticate('google', { session: false }, (err, result) => {
    if (err || !result) {
      logger.error({ err }, 'Google OAuth callback error');
      // Redirect to frontend with error
      const errorUrl = `${config.gameClientUrl}/auth/error?message=${encodeURIComponent(err?.message || 'Erro na autenticação')}`;
      return res.redirect(errorUrl);
    }

    const { user, tokens, isNewUser } = result as {
      user: AuthUser;
      tokens: { accessToken: string; refreshToken: string; expiresIn: number };
      isNewUser: boolean;
    };

    // Redirect to frontend with tokens
    const params = new URLSearchParams({
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn.toString(),
      isNewUser: isNewUser.toString(),
    });

    const successUrl = `${config.gameClientUrl}/auth/callback?${params.toString()}`;
    res.redirect(successUrl);
  })(req, res, next);
});

// ===========================================
// Microsoft OAuth
// ===========================================

// Initiate Microsoft OAuth flow
authRoutes.get('/microsoft', (req, res) => {
  if (!config.microsoftClientId || !config.microsoftClientSecret) {
    res.status(HttpStatus.SERVICE_UNAVAILABLE).json({
      success: false,
      error: {
        code: 'OAUTH_NOT_CONFIGURED',
        message: 'Microsoft OAuth não está configurado',
      },
    } as ApiResponse);
    return;
  }

  // Build Microsoft OAuth URL
  const params = new URLSearchParams({
    client_id: config.microsoftClientId,
    response_type: 'code',
    redirect_uri: config.microsoftCallbackUrl || `${config.apiUrl}/api/v1/auth/microsoft/callback`,
    scope: 'openid profile email User.Read',
    response_mode: 'query',
  });

  const authUrl = `https://login.microsoftonline.com/common/oauth2/v2.0/authorize?${params.toString()}`;
  res.redirect(authUrl);
});

// Microsoft OAuth callback
authRoutes.get('/microsoft/callback', async (req, res) => {
  const { code, error } = req.query;

  if (error || !code) {
    const errorUrl = `${config.gameClientUrl}/auth/error?message=${encodeURIComponent(error as string || 'Autenticação cancelada')}`;
    return res.redirect(errorUrl);
  }

  try {
    // Exchange code for tokens
    const tokenResponse = await fetch('https://login.microsoftonline.com/common/oauth2/v2.0/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: config.microsoftClientId!,
        client_secret: config.microsoftClientSecret!,
        code: code as string,
        redirect_uri: config.microsoftCallbackUrl || `${config.apiUrl}/api/v1/auth/microsoft/callback`,
        grant_type: 'authorization_code',
      }),
    });

    if (!tokenResponse.ok) {
      throw new Error('Falha ao obter token Microsoft');
    }

    const tokenData = await tokenResponse.json() as { access_token: string };

    // Get user profile
    const profileResponse = await fetch('https://graph.microsoft.com/v1.0/me', {
      headers: { Authorization: `Bearer ${tokenData.access_token}` },
    });

    if (!profileResponse.ok) {
      throw new Error('Falha ao obter perfil Microsoft');
    }

    interface MicrosoftProfile {
      id: string;
      mail?: string;
      userPrincipalName: string;
      displayName?: string;
      givenName?: string;
    }

    const profile = await profileResponse.json() as MicrosoftProfile;

    // Import auth service dynamically to avoid circular deps
    const { authenticateWithOAuth } = await import('../../services/auth.service');

    const result = await authenticateWithOAuth({
      provider: 'microsoft',
      providerId: profile.id,
      email: profile.mail || profile.userPrincipalName,
      name: profile.displayName || profile.givenName || 'Usuário',
    });

    // Redirect to frontend with tokens
    const params = new URLSearchParams({
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
      expiresIn: result.tokens.expiresIn.toString(),
      isNewUser: result.isNewUser.toString(),
    });

    const successUrl = `${config.gameClientUrl}/auth/callback?${params.toString()}`;
    res.redirect(successUrl);
  } catch (err) {
    logger.error({ err }, 'Microsoft OAuth callback error');
    const errorUrl = `${config.gameClientUrl}/auth/error?message=${encodeURIComponent('Erro na autenticação Microsoft')}`;
    res.redirect(errorUrl);
  }
});

// ===========================================
// Token Management
// ===========================================

// Refresh tokens
authRoutes.post('/refresh', async (req: Request, res: Response<ApiResponse>) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      res.status(HttpStatus.BAD_REQUEST).json({
        success: false,
        error: {
          code: 'MISSING_TOKEN',
          message: 'Refresh token não fornecido',
        },
      });
      return;
    }

    const payload = await verifyRefreshToken(refreshToken);

    if (!payload) {
      res.status(HttpStatus.UNAUTHORIZED).json({
        success: false,
        error: {
          code: 'INVALID_TOKEN',
          message: 'Refresh token inválido ou expirado',
        },
      });
      return;
    }

    const tokens = await refreshUserTokens(payload.userId);

    res.json({
      success: true,
      data: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: tokens.expiresIn,
      },
    });
  } catch (error) {
    logger.error({ error }, 'Token refresh error');
    res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      success: false,
      error: {
        code: 'REFRESH_ERROR',
        message: 'Erro ao renovar tokens',
      },
    });
  }
});

// Logout (invalidate refresh token - client should clear tokens)
authRoutes.post('/logout', requireAuth, (req: Request, res: Response<ApiResponse>) => {
  // In a production system, you might want to:
  // 1. Blacklist the refresh token in Redis
  // 2. Track active sessions
  // For now, we just acknowledge the logout
  logger.info({ userId: req.authUser?.id }, 'User logged out');

  res.json({
    success: true,
    data: { message: 'Logout realizado com sucesso' },
  });
});

// ===========================================
// Current User
// ===========================================

// Get current user info
authRoutes.get('/me', requireAuth, async (req: Request, res: Response<ApiResponse>) => {
  try {
    const { getUserById } = await import('../../services/auth.service');
    const user = await getUserById(req.authUser!.id);

    if (!user) {
      res.status(HttpStatus.NOT_FOUND).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'Usuário não encontrado',
        },
      });
      return;
    }

    res.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        avatarUrl: user.avatarUrl,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    logger.error({ error }, 'Get current user error');
    res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      success: false,
      error: {
        code: 'FETCH_ERROR',
        message: 'Erro ao buscar dados do usuário',
      },
    });
  }
});
