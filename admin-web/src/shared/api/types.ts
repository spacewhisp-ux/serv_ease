export interface Pagination {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}

export interface ListResponse<T> {
  items: T[];
  pagination: Pagination;
}

export interface ApiErrorPayload {
  message?: string | string[];
  code?: string;
}

export class AdminApiError extends Error {
  constructor(
    message: string,
    public readonly status?: number,
    public readonly code?: string,
  ) {
    super(message);
  }
}
