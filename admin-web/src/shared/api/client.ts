import axios, { AxiosError, type AxiosRequestConfig } from 'axios';

import { useAuthStore } from '../../modules/auth/store';
import { AdminApiError, type ApiErrorPayload } from './types';

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3001/v1';
let refreshPromise: Promise<string> | null = null;

export const httpClient = axios.create({
  baseURL: apiBaseUrl,
  timeout: 25000,
  headers: {
    'Content-Type': 'application/json',
  },
});

httpClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

httpClient.interceptors.response.use(
  (response) => unwrapResponse(response.data),
  async (error: AxiosError) => {
    const originalRequest = error.config as (AxiosRequestConfig & { _retried?: boolean }) | undefined;
    const status = error.response?.status;

    if (status === 401 && originalRequest && !originalRequest._retried) {
      originalRequest._retried = true;
      try {
        const accessToken = await refreshAccessToken();
        originalRequest.headers = {
          ...originalRequest.headers,
          Authorization: `Bearer ${accessToken}`,
        };
        return httpClient(originalRequest);
      } catch (refreshError) {
        useAuthStore.getState().logout();
        throw refreshError;
      }
    }

    throw normalizeError(error);
  },
);

export function unwrapResponse<T>(body: unknown): T {
  if (!body || typeof body !== 'object') {
    return body as T;
  }

  const response = body as { success?: boolean; data?: unknown; error?: ApiErrorPayload };
  if (response.success === false) {
    throw new AdminApiError(readErrorMessage(response.error), undefined, response.error?.code);
  }

  return response.data as T;
}

async function refreshAccessToken() {
  if (refreshPromise) {
    return refreshPromise;
  }

  const refreshToken = useAuthStore.getState().refreshToken;
  if (!refreshToken) {
    throw new AdminApiError('Session expired');
  }

  refreshPromise = axios
    .post(`${apiBaseUrl}/auth/refresh`, { refreshToken })
    .then((response) => unwrapResponse<{ accessToken: string; refreshToken: string }>(response.data))
    .then((tokens) => {
      useAuthStore.getState().updateTokens(tokens.accessToken, tokens.refreshToken);
      return tokens.accessToken;
    })
    .finally(() => {
      refreshPromise = null;
    });

  return refreshPromise;
}

function normalizeError(error: AxiosError) {
  const data = error.response?.data as { error?: ApiErrorPayload } | undefined;
  return new AdminApiError(
    readErrorMessage(data?.error) || error.message || 'Request failed',
    error.response?.status,
    data?.error?.code,
  );
}

function readErrorMessage(error?: ApiErrorPayload) {
  const message = error?.message;
  if (Array.isArray(message)) {
    return message.join(', ');
  }
  return message ?? 'Request failed';
}
