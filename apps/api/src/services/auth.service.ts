// ===========================================
// IAção API - Auth Service
// ===========================================

import { prisma } from '../config/database';
import { generateTokenPair, TokenPair } from './jwt.service';
import { logger } from '../utils/logger';
import { ApplicationError } from '../utils/errors';
import { HttpStatus } from '../utils/httpStatus';

// OAuth profile types
export interface OAuthProfile {
  provider: 'google' | 'microsoft';
  providerId: string;
  email: string;
  name: string;
  avatarUrl?: string;
}

// User with profile
export interface AuthUser {
  id: string;
  email: string;
  name: string;
  role: 'student' | 'teacher' | 'parent' | 'admin';
  avatarUrl: string | null;
  isActive: boolean;
  createdAt: Date;
}

// ===========================================
// OAuth Authentication
// ===========================================

export async function authenticateWithOAuth(
  profile: OAuthProfile
): Promise<{ user: AuthUser; tokens: TokenPair; isNewUser: boolean }> {
  logger.info({ provider: profile.provider, email: profile.email }, 'OAuth authentication');

  // Try to find existing user
  let user = await prisma.user.findUnique({
    where: { email: profile.email },
  });

  let isNewUser = false;

  if (!user) {
    // Create new user
    isNewUser = true;
    user = await prisma.user.create({
      data: {
        email: profile.email,
        name: profile.name,
        authProvider: profile.provider,
        providerId: profile.providerId,
        avatarUrl: profile.avatarUrl,
        role: 'student', // Default role for new users
        isActive: true,
      },
    });

    // Create player profile for new users
    await prisma.playerProfile.create({
      data: {
        userId: user.id,
        displayName: profile.name.split(' ')[0], // First name as display name
        level: 1,
        experiencePoints: 0,
        currentEnergy: 100,
      },
    });

    // Create initial competencies
    const competencyTypes = [
      'creativity',
      'critical_thinking',
      'communication',
      'logic',
      'digital_ethics',
      'collaboration',
    ];

    await prisma.competency.createMany({
      data: competencyTypes.map((type) => ({
        userId: user!.id,
        type,
        level: 0,
        experience: 0,
      })),
    });

    logger.info({ userId: user.id }, 'New user created via OAuth');
  } else {
    // Update existing user with latest OAuth info
    user = await prisma.user.update({
      where: { id: user.id },
      data: {
        name: profile.name,
        avatarUrl: profile.avatarUrl || user.avatarUrl,
        lastLoginAt: new Date(),
      },
    });
  }

  // Check if user is active
  if (!user.isActive) {
    throw new ApplicationError(
      'Conta desativada. Entre em contato com o suporte.',
      HttpStatus.FORBIDDEN
    );
  }

  // Generate tokens
  const tokens = await generateTokenPair({
    userId: user.id,
    email: user.email,
    role: user.role as 'student' | 'teacher' | 'parent' | 'admin',
  });

  const authUser: AuthUser = {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role as 'student' | 'teacher' | 'parent' | 'admin',
    avatarUrl: user.avatarUrl,
    isActive: user.isActive,
    createdAt: user.createdAt,
  };

  return { user: authUser, tokens, isNewUser };
}

// ===========================================
// Token Refresh
// ===========================================

export async function refreshUserTokens(userId: string): Promise<TokenPair> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) {
    throw new ApplicationError('Usuário não encontrado', HttpStatus.NOT_FOUND);
  }

  if (!user.isActive) {
    throw new ApplicationError(
      'Conta desativada',
      HttpStatus.FORBIDDEN
    );
  }

  // Update last login
  await prisma.user.update({
    where: { id: userId },
    data: { lastLoginAt: new Date() },
  });

  return generateTokenPair({
    userId: user.id,
    email: user.email,
    role: user.role as 'student' | 'teacher' | 'parent' | 'admin',
  });
}

// ===========================================
// User Lookup
// ===========================================

export async function getUserById(userId: string): Promise<AuthUser | null> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) return null;

  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role as 'student' | 'teacher' | 'parent' | 'admin',
    avatarUrl: user.avatarUrl,
    isActive: user.isActive,
    createdAt: user.createdAt,
  };
}

export async function getUserByEmail(email: string): Promise<AuthUser | null> {
  const user = await prisma.user.findUnique({
    where: { email },
  });

  if (!user) return null;

  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role as 'student' | 'teacher' | 'parent' | 'admin',
    avatarUrl: user.avatarUrl,
    isActive: user.isActive,
    createdAt: user.createdAt,
  };
}
