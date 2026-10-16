/**
 * Strict domain and network contract definitions for API client.
 */

export type UserRole = 'admin' | 'developer' | 'viewer';

export interface UserResponse {
  readonly id: number;
  readonly username: string;
  readonly role: UserRole;
  readonly active: boolean;
}

export interface ApiError {
  readonly error: string;
  readonly statusCode: number;
  readonly timestamp?: string;
}

export interface UserFilterOptions {
  readonly role?: UserRole;
  readonly activeOnly?: boolean;
}

export interface ApiResponse<T> {
  readonly success: boolean;
  readonly data?: T;
  readonly error?: ApiError;
}

/**
 * Type guard verifying if an unknown error object matches the ApiError contract.
 */
export function isApiError(value: unknown): value is ApiError {
  if (typeof value !== 'object' || value === null) {
    return false;
  }
  const candidate = value as Record<string, unknown>;
  return typeof candidate.error === 'string' && typeof candidate.statusCode === 'number';
}
