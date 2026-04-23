import { httpClient } from '../../shared/api/client';
import type { ListResponse } from '../../shared/api/types';

export type TicketStatus = 'OPEN' | 'PENDING' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED';
export type TicketPriority = 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT';

export interface TicketUser {
  id: string;
  displayName?: string | null;
  email?: string | null;
  phone?: string | null;
}

export interface TicketAgent {
  id: string;
  displayName?: string | null;
  email?: string | null;
  role?: 'AGENT' | 'ADMIN';
}

export interface TicketAttachment {
  id: string;
  fileName: string;
  mimeType: string;
  fileSize: number;
  createdAt: string;
  messageId?: string | null;
}

export interface TicketMessage {
  id: string;
  senderRole: 'USER' | 'AGENT' | 'SYSTEM';
  type: 'TEXT' | 'SYSTEM';
  body: string;
  isInternal: boolean;
  createdAt: string;
  sender?: TicketAgent | null;
  attachments: TicketAttachment[];
}

export interface TicketRecord {
  id: string;
  ticketNo: string;
  subject: string;
  category?: string | null;
  status: TicketStatus;
  priority: TicketPriority;
  assignedAgentId?: string | null;
  createdAt?: string;
  updatedAt?: string;
  user?: TicketUser | null;
  assignedAgent?: TicketAgent | null;
}

export interface TicketDetail extends TicketRecord {
  description: string;
  resolvedAt?: string | null;
  closedAt?: string | null;
  attachments: TicketAttachment[];
  messages: TicketMessage[];
}

export interface TicketListQuery {
  page: number;
  pageSize: number;
  status?: TicketStatus;
  assignedAgentId?: string;
  keyword?: string;
  priority?: TicketPriority;
  category?: string;
}

export interface ReplyTicketPayload {
  body: string;
  isInternal?: boolean;
  attachmentIds?: string[];
}

export interface UpdateTicketStatusPayload {
  status: TicketStatus;
}

export type TicketHistoryAction =
  | 'CREATED'
  | 'STATUS_CHANGED'
  | 'ASSIGNED'
  | 'REASSIGNED'
  | 'PRIORITY_CHANGED'
  | 'CATEGORY_CHANGED'
  | 'REPLIED'
  | 'CLOSED'
  | 'REOPENED';

export type TicketHistoryActorRole = 'USER' | 'AGENT' | 'ADMIN' | 'SYSTEM';

export interface TicketHistory {
  id: string;
  action: TicketHistoryAction;
  actorRole: TicketHistoryActorRole;
  oldValue?: string | null;
  newValue?: string | null;
  metadata?: Record<string, any> | null;
  createdAt: string;
  actor?: TicketAgent | null;
}

export const ticketHistoryActionLabels: Record<TicketHistoryAction, string> = {
  CREATED: 'Created',
  STATUS_CHANGED: 'Status Changed',
  ASSIGNED: 'Assigned',
  REASSIGNED: 'Reassigned',
  PRIORITY_CHANGED: 'Priority Changed',
  CATEGORY_CHANGED: 'Category Changed',
  REPLIED: 'Replied',
  CLOSED: 'Closed',
  REOPENED: 'Reopened',
};

export const ticketPriorityLabels: Record<TicketPriority, string> = {
  LOW: 'Low',
  NORMAL: 'Normal',
  HIGH: 'High',
  URGENT: 'Urgent',
};

export const ticketStatuses: TicketStatus[] = [
  'OPEN',
  'PENDING',
  'IN_PROGRESS',
  'RESOLVED',
  'CLOSED',
];

export const ticketStatusLabels: Record<TicketStatus, string> = {
  OPEN: 'Open',
  PENDING: 'Pending',
  IN_PROGRESS: 'In progress',
  RESOLVED: 'Resolved',
  CLOSED: 'Closed',
};

export const ticketStatusColors: Record<TicketStatus, string> = {
  OPEN: 'blue',
  PENDING: 'orange',
  IN_PROGRESS: 'purple',
  RESOLVED: 'green',
  CLOSED: 'default',
};

export const ticketPriorityColors: Record<TicketPriority, string> = {
  LOW: 'default',
  NORMAL: 'blue',
  HIGH: 'orange',
  URGENT: 'red',
};

export const ticketApi = {
  listAssignableAgents() {
    return httpClient.get<unknown, TicketAgent[]>('/admin/agents');
  },
  list(query: TicketListQuery) {
    return httpClient.get<unknown, ListResponse<TicketRecord>>('/admin/tickets', {
      params: query,
    });
  },
  get(id: string) {
    return httpClient.get<unknown, TicketDetail>(`/admin/tickets/${id}`);
  },
  assign(id: string, agentId: string) {
    return httpClient.patch<unknown, TicketRecord>(`/admin/tickets/${id}/assign`, {
      agentId,
    });
  },
  reply(id: string, payload: ReplyTicketPayload) {
    return httpClient.post<unknown, TicketMessage>(`/admin/tickets/${id}/messages`, payload);
  },
  updateStatus(id: string, payload: UpdateTicketStatusPayload) {
    return httpClient.patch<unknown, TicketRecord>(`/admin/tickets/${id}/status`, payload);
  },
  getHistory(id: string) {
    return httpClient.get<unknown, TicketHistory[]>(`/admin/tickets/${id}/history`);
  },
};
