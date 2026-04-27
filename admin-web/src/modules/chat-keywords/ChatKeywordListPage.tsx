import { PlusOutlined, SearchOutlined } from '@ant-design/icons';
import { Button, Card, Empty, Form, Input, Popconfirm, Select, Space, Table, Tag, message } from 'antd';
import type { TablePaginationConfig } from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';

import { chatKeywordApi, type ChatKeywordListQuery, type ChatKeywordRecord } from './api';

type StatusFilter = 'active' | 'inactive' | 'all';

interface FilterValues {
  keyword?: string;
  status?: StatusFilter;
}

export function ChatKeywordListPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [filters, setFilters] = useState<FilterValues>({ status: 'active' });
  const [pagination, setPagination] = useState({ page: 1, pageSize: 10 });

  const query = useMemo<ChatKeywordListQuery>(
    () => ({
      page: pagination.page,
      pageSize: pagination.pageSize,
      keyword: filters.keyword,
      isActive:
        filters.status === 'all' ? undefined : filters.status !== 'inactive',
    }),
    [filters, pagination],
  );

  const keywordsQuery = useQuery({
    queryKey: ['chat-keywords', query],
    queryFn: () => chatKeywordApi.list(query),
  });
  const [filterForm] = Form.useForm<FilterValues>();

  const deactivateMutation = useMutation({
    mutationFn: (id: string) => chatKeywordApi.deactivate(id),
    onSuccess: async () => {
      message.success('Keyword deactivated');
      await queryClient.invalidateQueries({ queryKey: ['chat-keywords'] });
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to deactivate keyword');
    },
  });

  const onTableChange = (nextPagination: TablePaginationConfig) => {
    setPagination({
      page: nextPagination.current ?? 1,
      pageSize: nextPagination.pageSize ?? 10,
    });
  };

  return (
    <Card
      title="Chat Keywords"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={() => navigate('/chat-keywords/new')}>
          New Keyword
        </Button>
      }
    >
      <Form<FilterValues>
        form={filterForm}
        layout="inline"
        initialValues={filters}
        onFinish={(values) => {
          setFilters(values);
          setPagination((current) => ({ ...current, page: 1 }));
        }}
        style={{ marginBottom: 16 }}
      >
        <Form.Item name="keyword">
          <Input allowClear prefix={<SearchOutlined />} placeholder="Search keyword" style={{ width: 260 }} />
        </Form.Item>
        <Form.Item name="status">
          <Select
            style={{ width: 140 }}
            options={[
              { value: 'active', label: 'Active' },
              { value: 'inactive', label: 'Inactive' },
              { value: 'all', label: 'All' },
            ]}
          />
        </Form.Item>
        <Button htmlType="submit">Filter</Button>
        <Button
          onClick={() => {
            filterForm.resetFields();
            setFilters({ status: 'active' });
            setPagination((current) => ({ ...current, page: 1 }));
          }}
        >
          Reset
        </Button>
      </Form>
      <Table<ChatKeywordRecord>
        rowKey="id"
        loading={keywordsQuery.isLoading}
        dataSource={keywordsQuery.data?.items ?? []}
        locale={{
          emptyText: keywordsQuery.error ? (
            <Empty
              description={keywordsQuery.error instanceof Error ? keywordsQuery.error.message : 'Failed to load keywords'}
            >
              <Button onClick={() => keywordsQuery.refetch()}>Retry</Button>
            </Empty>
          ) : (
            <Empty description="No chat keywords match the current filters" />
          ),
        }}
        pagination={{
          current: keywordsQuery.data?.pagination.page ?? pagination.page,
          pageSize: keywordsQuery.data?.pagination.pageSize ?? pagination.pageSize,
          total: keywordsQuery.data?.pagination.total ?? 0,
          showSizeChanger: true,
        }}
        onChange={onTableChange}
        columns={[
          {
            title: 'Keyword',
            dataIndex: 'keyword',
            width: 200,
          },
          {
            title: 'Reply',
            dataIndex: 'reply',
            ellipsis: true,
          },
          {
            title: 'Status',
            dataIndex: 'isActive',
            width: 100,
            render: (isActive: boolean) => (
              <Tag color={isActive ? 'green' : 'default'}>{isActive ? 'Active' : 'Inactive'}</Tag>
            ),
          },
          {
            title: 'Updated',
            dataIndex: 'updatedAt',
            width: 180,
            render: (value?: string) => (value ? new Date(value).toLocaleString() : '-'),
          },
          {
            title: 'Actions',
            width: 220,
            render: (_, record) => (
              <Space>
                <Button type="link" onClick={() => navigate(`/chat-keywords/${record.id}/edit`)}>
                  Edit
                </Button>
                {record.isActive ? (
                  <Popconfirm
                    title="Deactivate Keyword?"
                    description="This stops the keyword from matching but keeps it editable."
                    okText="Deactivate"
                    onConfirm={() => deactivateMutation.mutate(record.id)}
                  >
                    <Button type="link" danger>
                      Deactivate
                    </Button>
                  </Popconfirm>
                ) : null}
              </Space>
            ),
          },
        ]}
      />
    </Card>
  );
}
