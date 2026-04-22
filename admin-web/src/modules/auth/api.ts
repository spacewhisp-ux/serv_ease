import { httpClient } from '../../shared/api/client';
import type { StoredUser } from '../../shared/session/storage';

export interface LoginPayload {
  account: string;
  password: string;
}

export interface LoginResult {
  accessToken: string;
  refreshToken: string;
  user: StoredUser;
}

export const authApi = {
  login(payload: LoginPayload) {
    return httpClient.post<unknown, LoginResult>('/auth/login', {
      ...payload,
      deviceName: 'admin-web',
    });
  },
  me() {
    return httpClient.get<unknown, StoredUser>('/users/me');
  },
  logout(refreshToken: string) {
    return httpClient.post<unknown, { revoked: boolean }>('/auth/logout', {
      refreshToken,
    });
  },
};
