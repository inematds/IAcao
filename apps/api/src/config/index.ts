// ===========================================
// IAção API - Configuration
// ===========================================

import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const configSchema = z.object({
  // Server
  nodeEnv: z.enum(['development', 'production', 'test']).default('development'),
  port: z.coerce.number().default(3000),
  apiUrl: z.string().default('http://localhost:3000'),

  // Database
  databaseUrl: z.string(),

  // Redis
  redisUrl: z.string().default('redis://localhost:6379'),

  // JWT
  jwtSecret: z.string().min(32),
  jwtExpiresIn: z.string().default('15m'),
  refreshTokenExpiresIn: z.string().default('7d'),

  // OAuth - Google
  googleClientId: z.string().optional(),
  googleClientSecret: z.string().optional(),
  googleCallbackUrl: z.string().optional(),

  // OAuth - Microsoft
  microsoftClientId: z.string().optional(),
  microsoftClientSecret: z.string().optional(),
  microsoftCallbackUrl: z.string().optional(),

  // AI
  openaiApiKey: z.string().optional(),
  openaiModel: z.string().default('gpt-4o-mini'),
  anthropicApiKey: z.string().optional(),
  anthropicModel: z.string().default('claude-3-haiku-20240307'),

  // AI Rate Limiting
  aiRateLimitPerMinute: z.coerce.number().default(5),
  aiRateLimitPerHour: z.coerce.number().default(20),
  aiRateLimitPerDay: z.coerce.number().default(50),

  // Frontend URLs
  gameClientUrl: z.string().default('http://localhost:8080'),
  dashboardUrl: z.string().default('http://localhost:5173'),
  corsOrigins: z.string().default('http://localhost:8080,http://localhost:5173'),

  // Logging
  logLevel: z.enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal']).default('info'),
});

const parseConfig = () => {
  const result = configSchema.safeParse({
    nodeEnv: process.env.NODE_ENV,
    port: process.env.PORT,
    apiUrl: process.env.API_URL,
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: process.env.REDIS_URL,
    jwtSecret: process.env.JWT_SECRET,
    jwtExpiresIn: process.env.JWT_EXPIRES_IN,
    refreshTokenExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN,
    googleClientId: process.env.GOOGLE_CLIENT_ID,
    googleClientSecret: process.env.GOOGLE_CLIENT_SECRET,
    googleCallbackUrl: process.env.GOOGLE_CALLBACK_URL,
    microsoftClientId: process.env.MICROSOFT_CLIENT_ID,
    microsoftClientSecret: process.env.MICROSOFT_CLIENT_SECRET,
    microsoftCallbackUrl: process.env.MICROSOFT_CALLBACK_URL,
    openaiApiKey: process.env.OPENAI_API_KEY,
    openaiModel: process.env.OPENAI_MODEL,
    anthropicApiKey: process.env.ANTHROPIC_API_KEY,
    anthropicModel: process.env.ANTHROPIC_MODEL,
    aiRateLimitPerMinute: process.env.AI_RATE_LIMIT_PER_MINUTE,
    aiRateLimitPerHour: process.env.AI_RATE_LIMIT_PER_HOUR,
    aiRateLimitPerDay: process.env.AI_RATE_LIMIT_PER_DAY,
    gameClientUrl: process.env.GAME_CLIENT_URL,
    dashboardUrl: process.env.DASHBOARD_URL,
    corsOrigins: process.env.CORS_ORIGINS,
    logLevel: process.env.LOG_LEVEL,
  });

  if (!result.success) {
    console.error('❌ Invalid configuration:', result.error.format());
    process.exit(1);
  }

  return result.data;
};

export const config = parseConfig();

export type Config = typeof config;
