/**
 * Typed HTTP API client providing authenticated requests and response normalization.
 */

import {
  ApiError,
  ApiResponse,
  UserFilterOptions,
  UserResponse,
} from './types';

export class UserApiClient {
  private readonly baseUrl: string;
  private readonly defaultTimeoutMs: number;

  constructor(baseUrl: string = 'http://localhost:3000', timeoutMs: number = 5000) {
    this.baseUrl = baseUrl.replace(/\/+$/, '');
    this.defaultTimeoutMs = timeoutMs;
  }

  /**
   * Health probe verifying upstream connectivity.
   */
  public async checkHealth(): Promise<boolean> {
    try {
      const response = await fetch(`${this.baseUrl}/health`, {
        signal: AbortSignal.timeout(this.defaultTimeoutMs),
      });
      return response.ok;
    } catch {
      return false;
    }
  }

  /**
   * Retrieves user catalog with optional client-side and server-side filtering.
   */
  public async listUsers(
    options: UserFilterOptions = {}
  ): Promise<ApiResponse<UserResponse[]>> {
    try {
      const url = new URL(`${this.baseUrl}/api/users`);
      if (options.role) {
        url.searchParams.set('role', options.role);
      }

      const response = await fetch(url.toString(), {
        headers: { Accept: 'application/json' },
        signal: AbortSignal.timeout(this.defaultTimeoutMs),
      });

      if (!response.ok) {
        const errorPayload: ApiError = {
          error: `HTTP error encountered: ${response.statusText}`,
          statusCode: response.status,
          timestamp: new Date().toISOString(),
        };
        return { success: false, error: errorPayload };
      }

      const payload = (await response.json()) as { users: UserResponse[] };
      let results: UserResponse[] = Array.isArray(payload.users) ? payload.users : [];

      if (options.activeOnly) {
        results = results.filter((user) => user.active);
      }

      return { success: true, data: results };
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Unknown communication error';
      return {
        success: false,
        error: { error: message, statusCode: 500, timestamp: new Date().toISOString() },
      };
    }
  }

  /**
   * Filters and sorts active administrative users from a typed user array.
   */
  public filterActiveAdmins(users: readonly UserResponse[]): UserResponse[] {
    return users
      .filter((user): boolean => user.active && user.role === 'admin')
      .slice()
      .sort((a, b) => a.username.localeCompare(b.username));
  }
}
