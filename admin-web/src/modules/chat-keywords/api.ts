import { httpClient } from '../../shared/api/client';
import type { ListResponse } from '../../shared/api/types';

export interface ChatKeywordRecord {
  id: string;
  keyword: string;
  reply: string;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface ChatKeywordPayload {
  keyword: string;
  reply: string;
  isActive?: boolean;
}

export interface ChatKeywordListQuery {
  page: number;
  pageSize: number;
  keyword?: string;
  isActive?: boolean;
}

export const chatKeywordApi = {
  list(query: ChatKeywordListQuery) {
    return httpClient.get<unknown, ListResponse<ChatKeywordRecord>>('/admin/chat/keywords', {
      params: query,
    });
  },
  get(id: string) {
    return httpClient.get<unknown, ChatKeywordRecord>(`/admin/chat/keywords/${id}`);
  },
  create(payload: ChatKeywordPayload) {
    return httpClient.post<unknown, ChatKeywordRecord>('/admin/chat/keywords', payload);
  },
  update(id: string, payload: ChatKeywordPayload) {
    return httpClient.patch<unknown, ChatKeywordRecord>(`/admin/chat/keywords/${id}`, payload);
  },
  deactivate(id: string) {
    return httpClient.delete<unknown, ChatKeywordRecord>(`/admin/chat/keywords/${id}`);
  },
};
