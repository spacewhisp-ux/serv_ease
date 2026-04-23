import { SearchOutlined } from '@ant-design/icons';
import { Button, Card, Empty, Form, Input, Select, Space, Table, Tag } from 'antd';
import type { TablePaginationConfig } from 'antd';
import { useQuery } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';

import { useAuthStore } from '../auth/store';
import {
  ticketApi,
  ticketPriorityColors,
  ticketPriorityLabels,
  ticketStatusColors,
  ticketStatusLabels,
  ticketStatuses,
  type TicketListQuery,
  type TicketPriority,
  type TicketRecord,
  type TicketStatus,
} from './api';

type AssignmentFilter = 'all' | 'mine' | 'unassigned';

interface FilterValues {
  status?: TicketStatus;
  assignment?: AssignmentFilter;
  keyword?: string;
  priority?: TicketPriority;
  category?: string;
}

function formatAssignee(record: TicketRecord) {
  if (!record.assignedAgent) {
    return '-';
  }

  return record.assignedAgent.displayName ?? record.assignedAgent.email ?? record.assignedAgent.id;
}

function formatUser(record: TicketRecord) {
  if (!record.user) {
    return '-';
  }

  return record.user.displayName ?? record.user.email ?? record.user.phone ?? record.user.id;
}

export function TicketListPage() {
  const navigate = useNavigate();
  const currentUser = useAuthStore((state) => state.user);
  const [filters, setFilters] = useState<FilterValues>({ assignment: 'all' });
  const [pagination, setPagination] = useState({ page: 1, pageSize: 10 });
  const [form] = Form.useForm<FilterValues>();

  const query = useMemo<TicketListQuery>(() => {
    const isMine = filters.assignment === 'mine' && currentUser?.id;
    return {
      page: pagination.page,
      pageSize: pagination.pageSize,
      status: filters.status,
      assignedAgentId: isMine ? currentUser.id : undefined,
      keyword: filters.keyword?.trim() || undefined,
      priority: filters.priority,
      category: filters.category?.trim() || undefined,
    };
  }, [currentUser?.id, filters, pagination]);

  const ticketsQuery = useQuery({
    queryKey: ['tickets', query],
    queryFn: () => ticketApi.list(query),
  });

  const filteredItems = useMemo(() => {
    const items = ticketsQuery.data?.items ?? [];
    if (filters.assignment === 'unassigned') {
      return items.filter((item) => !item.assignedAgentId);
    }
    return items;
  }, [filters.assignment, ticketsQuery.data?.items]);

  const onTableChange = (nextPagination: TablePaginationConfig) => {
    setPagination({
      page: nextPagination.current ?? 1,
      pageSize: nextPagination.pageSize ?? 10,
    });
  };

  return (
    <Card title="Tickets">
      <Form<FilterValues>
        form={form}
        layout="inline"
        initialValues={filters}
        onFinish={(values) => {
          setFilters(values);
          setPagination((current) => ({ ...current, page: 1 }));
        }}
        style={{ marginBottom: 16 }}
      >
        <Form.Item name="keyword">
          <Input
            placeholder="Search by ticket no, subject, or email"
            style={{ width: 280 }}
            allowClear
          />
        </Form.Item>
        <Form.Item name="status">
          <Select
            allowClear
            placeholder="Status"
            style={{ width: 180 }}
            options={ticketStatuses.map((status) => ({
              value: status,
              label: ticketStatusLabels[status],
            }))}
          />
        </Form.Item>
        <Form.Item name="priority">
          <Select
            allowClear
            placeholder="Priority"
            style={{ width: 140 }}
            options={(['LOW', 'NORMAL', 'HIGH', 'URGENT'] as TicketPriority[]).map((priority) => ({
              value: priority,
              label: ticketPriorityLabels[priority],
            }))}
          />
        </Form.Item>
        <Form.Item name="category">
          <Select
            allowClear
            placeholder="Category"
            style={{ width: 160 }}
            options={[
              { value: 'GENERAL', label: 'General' },
              { value: 'TECHNICAL', label: 'Technical' },
              { value: 'BILLING', label: 'Billing' },
              { value: 'FEATURE_REQUEST', label: 'Feature Request' },
              { value: 'BUG_REPORT', label: 'Bug Report' },
              { value: 'OTHER', label: 'Other' },
            ]}
          />
        </Form.Item>
        <Form.Item name="assignment">
          <Select
            style={{ width: 180 }}
            options={[
              { value: 'all', label: 'All tickets' },
              { value: 'mine', label: 'Assigned to me' },
              { value: 'unassigned', label: 'Unassigned' },
            ]}
          />
        </Form.Item>
        <Button htmlType="submit" icon={<SearchOutlined />}>
          Filter
        </Button>
        <Button
          onClick={() => {
            form.resetFields();
            const nextFilters: FilterValues = { assignment: 'all' };
            form.setFieldsValue(nextFilters);
            setFilters(nextFilters);
            setPagination((current) => ({ ...current, page: 1 }));
          }}
        >
          Reset
        </Button>
      </Form>
      <Table<TicketRecord>
        rowKey="id"
        loading={ticketsQuery.isLoading}
        dataSource={filteredItems}
        locale={{
          emptyText: ticketsQuery.error ? (
            <Empty
              description={
                ticketsQuery.error instanceof Error
                  ? ticketsQuery.error.message
                  : 'Failed to load tickets'
              }
            >
              <Button onClick={() => ticketsQuery.refetch()}>Retry</Button>
            </Empty>
          ) : (
            <Empty description="No tickets match the current filters" />
          ),
        }}
        pagination={{
          current: ticketsQuery.data?.pagination.page ?? pagination.page,
          pageSize: ticketsQuery.data?.pagination.pageSize ?? pagination.pageSize,
          total:
            filters.assignment === 'unassigned'
              ? filteredItems.length
              : (ticketsQuery.data?.pagination.total ?? 0),
          showSizeChanger: true,
        }}
        onChange={onTableChange}
        columns={[
          {
            title: 'Ticket',
            width: 180,
            render: (_, record) => (
              <Space direction="vertical" size={0}>
                <Button type="link" style={{ padding: 0 }} onClick={() => navigate(`/tickets/${record.id}`)}>
                  {record.ticketNo}
                </Button>
                <span>{record.subject}</span>
              </Space>
            ),
          },
          {
            title: 'Status',
            dataIndex: 'status',
            width: 140,
            render: (status: TicketStatus) => (
              <Tag color={ticketStatusColors[status]}>{ticketStatusLabels[status]}</Tag>
            ),
          },
          {
            title: 'Priority',
            dataIndex: 'priority',
            width: 120,
            render: (priority: TicketRecord['priority']) => (
              <Tag color={ticketPriorityColors[priority]}>{priority}</Tag>
            ),
          },
          {
            title: 'User',
            width: 220,
            render: (_, record) => formatUser(record),
          },
          {
            title: 'Assignee',
            width: 220,
            render: (_, record) => formatAssignee(record),
          },
          {
            title: 'Updated',
            dataIndex: 'updatedAt',
            width: 180,
            render: (value?: string) => (value ? new Date(value).toLocaleString() : '-'),
          },
        ]}
      />
    </Card>
  );
}
