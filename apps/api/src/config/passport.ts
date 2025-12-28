// ===========================================
// IAção API - Passport Configuration
// ===========================================

import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import { config } from './index';
import { logger } from '../utils/logger';
import { authenticateWithOAuth, OAuthProfile } from '../services/auth.service';

// ===========================================
// Google OAuth Strategy
// ===========================================

if (config.googleClientId && config.googleClientSecret) {
  passport.use(
    new GoogleStrategy(
      {
        clientID: config.googleClientId,
        clientSecret: config.googleClientSecret,
        callbackURL: config.googleCallbackUrl || `${config.apiUrl}/api/v1/auth/google/callback`,
        scope: ['profile', 'email'],
      },
      async (accessToken, refreshToken, profile, done) => {
        try {
          const email = profile.emails?.[0]?.value;
          if (!email) {
            return done(new Error('Email não disponível no perfil Google'), undefined);
          }

          const oauthProfile: OAuthProfile = {
            provider: 'google',
            providerId: profile.id,
            email,
            name: profile.displayName || email.split('@')[0],
            avatarUrl: profile.photos?.[0]?.value,
          };

          const result = await authenticateWithOAuth(oauthProfile);
          return done(null, result);
        } catch (error) {
          logger.error({ error }, 'Google OAuth error');
          return done(error as Error, undefined);
        }
      }
    )
  );

  logger.info('Google OAuth strategy configured');
} else {
  logger.warn('Google OAuth not configured - missing credentials');
}

// ===========================================
// Microsoft OAuth Strategy
// ===========================================

// Note: Using a simplified approach for Microsoft OAuth
// The passport-microsoft package requires specific setup
if (config.microsoftClientId && config.microsoftClientSecret) {
  // Microsoft OAuth would be configured here
  // For now, we'll implement it as a custom strategy in the routes
  logger.info('Microsoft OAuth credentials present - will use custom implementation');
} else {
  logger.warn('Microsoft OAuth not configured - missing credentials');
}

// ===========================================
// Serialization (not used with JWT, but required by Passport)
// ===========================================

passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user as Express.User);
});

export { passport };
