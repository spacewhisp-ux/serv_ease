import { httpClient } from '../../shared/api/client';
import type { ListResponse } from '../../shared/api/types';

export interface FaqRecord {
  id: string;
  categoryId: string;
  question: string;
  answer: string;
  keywords: string[];
  viewCount: number;
  sortOrder: number;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
  category?: {
    id: string;
    name: string;
    sortOrder: number;
    isActive: boolean;
  };
}

export interface FaqPayload {
  categoryId: string;
  question: string;
  answer: string;
  keywords: string[];
  sortOrder: number;
  isActive: boolean;
}

export interface FaqListQuery {
  page: number;
  pageSize: number;
  categoryId?: string;
  keyword?: string;
  isActive?: boolean;
}

export const faqApi = {
  list(query: FaqListQuery) {
    return httpClient.get<unknown, ListResponse<FaqRecord>>('/admin/faqs', {
      params: query,
    });
  },
  get(id: string) {
    return httpClient.get<unknown, FaqRecord>(`/admin/faqs/${id}`);
  },
  create(payload: FaqPayload) {
    return httpClient.post<unknown, FaqRecord>('/admin/faqs', payload);
  },
  update(id: string, payload: FaqPayload) {
    return httpClient.patch<unknown, FaqRecord>(`/admin/faqs/${id}`, payload);
  },
  deactivate(id: string) {
    return httpClient.delete<unknown, FaqRecord>(`/admin/faqs/${id}`);
  },
};
