// ===========================================
// User Types
// ===========================================

export type UserRole = 'player' | 'educator' | 'parent';

export type PlayerBackground = 'inventor' | 'artist' | 'mediator' | 'explorer';

export interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  avatarUrl?: string;
  oauthProvider: string;
  oauthId: string;
  createdAt: Date;
  lastLogin?: Date;
}

export interface PlayerProfile {
  id: string;
  userId: string;
  characterName: string;
  characterAppearance: Record<string, unknown>;
  background: PlayerBackground;
  currentRegion: string;
  energy: number;
  playTimeMinutes: number;
  worldFlags: Record<string, boolean>;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserInput {
  email: string;
  name: string;
  role: UserRole;
  avatarUrl?: string;
  oauthProvider: string;
  oauthId: string;
}

export interface CreatePlayerProfileInput {
  userId: string;
  characterName: string;
  background: PlayerBackground;
  characterAppearance?: Record<string, unknown>;
}
