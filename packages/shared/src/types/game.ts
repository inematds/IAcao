// ===========================================
// Game Types
// ===========================================

import type { PlayerProfile } from './user';

export type CompetencyType =
  | 'creativity'
  | 'critical_thinking'
  | 'communication'
  | 'logic'
  | 'digital_ethics'
  | 'collaboration';

export type MissionStatus = 'not_started' | 'in_progress' | 'completed';

export type CreationType = 'idea' | 'project' | 'pitch';

export interface Competency {
  id: string;
  playerId: string;
  type: CompetencyType;
  level: number; // 0-100
  updatedAt: Date;
}

export interface CompetencyChange {
  type: CompetencyType;
  delta: number;
  reason?: string;
}

export interface MissionObjective {
  id: string;
  type: 'dialogue' | 'interact' | 'collect' | 'travel' | 'creation' | 'pitch' | 'choice' | 'time';
  target?: string;
  count?: number;
  required: boolean;
  completed: boolean;
}

export interface MissionProgress {
  id: string;
  playerId: string;
  missionId: string;
  status: MissionStatus;
  objectivesCompleted: Record<string, boolean>;
  chosenBranch?: string;
  startedAt?: Date;
  completedAt?: Date;
}

export interface ChoiceLog {
  id: string;
  playerId: string;
  missionId?: string;
  dialogueId: string;
  choiceId: string;
  choiceText: string;
  context?: Record<string, unknown>;
  competenciesAffected?: CompetencyChange[];
  createdAt: Date;
}

export interface Creation {
  id: string;
  playerId: string;
  missionId?: string;
  title: string;
  content: string;
  type: CreationType;
  evaluation?: CreationEvaluation;
  score?: number; // 1-5
  submittedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreationEvaluation {
  clarity: number; // 1-5
  creativity: number; // 1-5
  viability: number; // 1-5
  impact: number; // 1-5
  feedback: string;
}

export interface GameState {
  profile: PlayerProfile;
  competencies: Competency[];
  currentRegion: string;
  worldFlags: Record<string, boolean>;
  activeMissions: MissionProgress[];
  inventory: InventoryItem[];
}

export interface InventoryItem {
  id: string;
  itemId: string;
  quantity: number;
}
