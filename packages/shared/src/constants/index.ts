// ===========================================
// IAção - Constants
// ===========================================

// Energy system
export const MAX_ENERGY = 100;
export const ENERGY_REGEN_PER_MINUTE = 1;
export const ENERGY_REGEN_ON_NEW_DAY = 30;

// Competency levels
export const COMPETENCY_MIN = 0;
export const COMPETENCY_MAX = 100;

export const COMPETENCY_TIERS = {
  BEGINNER: { min: 0, max: 19, name: 'Iniciante' },
  APPRENTICE: { min: 20, max: 39, name: 'Aprendiz' },
  PRACTITIONER: { min: 40, max: 59, name: 'Praticante' },
  PROFICIENT: { min: 60, max: 79, name: 'Proficiente' },
  MASTER: { min: 80, max: 100, name: 'Mestre' },
} as const;

// Relationship levels
export const RELATIONSHIP_MIN = -100;
export const RELATIONSHIP_MAX = 100;

export const RELATIONSHIP_STATUS = {
  HOSTILE: { min: -100, max: -50, name: 'Hostil' },
  DISTRUSTFUL: { min: -49, max: -20, name: 'Desconfiado' },
  NEUTRAL: { min: -19, max: 19, name: 'Neutro' },
  FRIENDLY: { min: 20, max: 49, name: 'Amigável' },
  CLOSE_FRIEND: { min: 50, max: 100, name: 'Amigo Próximo' },
} as const;

// Game regions
export const REGIONS = {
  VILA_ESPERANCA: 'vila_esperanca',
  DISTRITO_INDUSTRIAL: 'distrito_industrial',
  FLORESTA_VIVA: 'floresta_viva',
  METROPOLIS: 'metropolis',
  TORRE_FLUXO: 'torre_fluxo',
} as const;

// Competency types
export const COMPETENCY_TYPES = [
  'creativity',
  'critical_thinking',
  'communication',
  'logic',
  'digital_ethics',
  'collaboration',
] as const;

// API versioning
export const API_VERSION = 'v1';
export const API_PREFIX = `/api/${API_VERSION}`;

// Rate limiting
export const RATE_LIMITS = {
  GENERAL: { windowMs: 15 * 60 * 1000, max: 100 }, // 100 requests per 15 min
  AUTH: { windowMs: 15 * 60 * 1000, max: 10 }, // 10 auth attempts per 15 min
  AI: { windowMs: 60 * 1000, max: 5 }, // 5 AI requests per minute
} as const;
