import { httpClient } from '../../shared/api/client';

export interface FaqCategoryRecord {
  id: string;
  name: string;
  sortOrder: number;
  isActive: boolean;
  createdAt?: string;
  updatedAt?: string;
}

export interface CategoryPayload {
  name: string;
  sortOrder: number;
  isActive: boolean;
}

export const faqCategoryApi = {
  list(isActive?: boolean) {
    return httpClient.get<unknown, FaqCategoryRecord[]>('/admin/faq-categories', {
      params: { isActive },
    });
  },
  get(id: string) {
    return httpClient
      .get<unknown, FaqCategoryRecord[]>('/admin/faq-categories')
      .then((items) => items.find((item) => item.id === id));
  },
  create(payload: CategoryPayload) {
    return httpClient.post<unknown, FaqCategoryRecord>('/admin/faq-categories', payload);
  },
  update(id: string, payload: CategoryPayload) {
    return httpClient.patch<unknown, FaqCategoryRecord>(`/admin/faq-categories/${id}`, payload);
  },
  deactivate(id: string) {
    return httpClient.delete<unknown, FaqCategoryRecord>(`/admin/faq-categories/${id}`);
  },
};
