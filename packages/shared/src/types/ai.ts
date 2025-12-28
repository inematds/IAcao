// ===========================================
// AI (ARIA) Types
// ===========================================

export type AIAction = 'analyze' | 'suggest' | 'simulate' | 'improve';

export interface AIQueryRequest {
  action: AIAction;
  additionalContext?: string;
}

export interface AIQueryResponse {
  success: boolean;
  response?: string;
  energyCost: number;
  newEnergy: number;
  error?: {
    code: string;
    message: string;
  };
}

export interface AIUsageLog {
  id: string;
  playerId: string;
  action: AIAction;
  energyCost: number;
  context?: Record<string, unknown>;
  promptTokens?: number;
  completionTokens?: number;
  responseFiltered: boolean;
  latencyMs?: number;
  createdAt: Date;
}

export interface AIContext {
  player: {
    name: string;
    background: string;
    competencies: Record<string, number>;
    energy: number;
  };
  location: {
    region: string;
    area: string;
  };
  mission?: {
    id: string;
    title: string;
    objectives: string[];
    progress: string;
  };
  recentHistory: {
    lastDialogue?: string;
    recentChoices: string[];
    recentCreations: string[];
  };
  npcs: Array<{
    name: string;
    relationship: number;
    recentInteraction?: string;
  }>;
  worldFlags: Record<string, boolean>;
}

// Energy costs for each action
export const AI_ENERGY_COSTS: Record<AIAction, number> = {
  analyze: 10,
  suggest: 15,
  simulate: 20,
  improve: 15,
};

// Cooldowns in seconds
export const AI_COOLDOWNS: Record<AIAction, number> = {
  analyze: 30,
  suggest: 45,
  simulate: 60,
  improve: 45,
};
