// ===========================================
// API Types
// ===========================================

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: ApiError;
  meta?: ApiMeta;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export interface ApiMeta {
  page?: number;
  limit?: number;
  total?: number;
  timestamp?: string;
}

export interface PaginationParams {
  page?: number;
  limit?: number;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface TokenPayload {
  sub: string; // user id
  email: string;
  role: string;
  iat: number;
  exp: number;
}

// HTTP Status codes for reference
export const HttpStatus = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
} as const;

export type HttpStatusCode = (typeof HttpStatus)[keyof typeof HttpStatus];
