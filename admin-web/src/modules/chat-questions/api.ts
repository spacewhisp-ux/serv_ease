import { httpClient } from '../../shared/api/client';
import type { ListResponse } from '../../shared/api/types';

export interface ChatQuestionRecord {
  id: string;
  text: string;
  reply: string;
  linkUrl?: string | null;
  linkLabel?: string | null;
  sortOrder: number;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface ChatQuestionPayload {
  text: string;
  reply: string;
  linkUrl?: string;
  linkLabel?: string;
  sortOrder?: number;
  isActive?: boolean;
}

export interface ChatQuestionListQuery {
  page: number;
  pageSize: number;
  isActive?: boolean;
}

export const chatQuestionApi = {
  list(query: ChatQuestionListQuery) {
    return httpClient.get<unknown, ListResponse<ChatQuestionRecord>>('/admin/chat/questions', {
      params: query,
    });
  },
  get(id: string) {
    return httpClient.get<unknown, ChatQuestionRecord>(`/admin/chat/questions/${id}`);
  },
  create(payload: ChatQuestionPayload) {
    return httpClient.post<unknown, ChatQuestionRecord>('/admin/chat/questions', payload);
  },
  update(id: string, payload: ChatQuestionPayload) {
    return httpClient.patch<unknown, ChatQuestionRecord>(`/admin/chat/questions/${id}`, payload);
  },
  deactivate(id: string) {
    return httpClient.delete<unknown, ChatQuestionRecord>(`/admin/chat/questions/${id}`);
  },
};
