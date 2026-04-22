import { httpClient } from '../../shared/api/client';
import type { ListResponse } from '../../shared/api/types';

export interface LogFileInfo {
  date: string;
  fileName: string;
  fileSize: number;
}

export interface LogLine {
  timestamp: string;
  ip: string;
  userId: string;
  account: string;
  method: string;
  path: string;
  statusCode: number;
  duration: number;
  response: string;
}

export interface LogListQuery {
  date: string;
  page?: number;
  pageSize?: number;
  keyword?: string;
}

export const logsApi = {
  listDates() {
    return httpClient.get<unknown, LogFileInfo[]>('/admin/logs/dates');
  },

  readLog(query: LogListQuery) {
    return httpClient.get<unknown, ListResponse<LogLine>>('/admin/logs', {
      params: query,
    });
  },

  getDownloadUrl(date: string) {
    // Build full URL for download (needs to include auth token as query param or use different approach)
    const baseUrl = (httpClient.defaults.baseURL ?? '').replace(/\/$/, '');
    return `${baseUrl}/admin/logs/download/${date}`;
  },
};
