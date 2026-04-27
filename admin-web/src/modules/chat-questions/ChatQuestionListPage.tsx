import { PlusOutlined } from '@ant-design/icons';
import { Button, Card, Empty, Form, Popconfirm, Select, Space, Table, Tag, message } from 'antd';
import type { TablePaginationConfig } from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';

import { chatQuestionApi, type ChatQuestionListQuery, type ChatQuestionRecord } from './api';

type StatusFilter = 'active' | 'inactive' | 'all';

interface FilterValues {
  status?: StatusFilter;
}

export function ChatQuestionListPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [filters, setFilters] = useState<FilterValues>({ status: 'active' });
  const [pagination, setPagination] = useState({ page: 1, pageSize: 10 });

  const query = useMemo<ChatQuestionListQuery>(
    () => ({
      page: pagination.page,
      pageSize: pagination.pageSize,
      isActive:
        filters.status === 'all' ? undefined : filters.status !== 'inactive',
    }),
    [filters, pagination],
  );

  const questionsQuery = useQuery({
    queryKey: ['chat-questions', query],
    queryFn: () => chatQuestionApi.list(query),
  });
  const [filterForm] = Form.useForm<FilterValues>();

  const deactivateMutation = useMutation({
    mutationFn: (id: string) => chatQuestionApi.deactivate(id),
    onSuccess: async () => {
      message.success('Question deactivated');
      await queryClient.invalidateQueries({ queryKey: ['chat-questions'] });
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to deactivate question');
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
      title="Chat Questions"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={() => navigate('/chat-questions/new')}>
          New Question
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
      <Table<ChatQuestionRecord>
        rowKey="id"
        loading={questionsQuery.isLoading}
        dataSource={questionsQuery.data?.items ?? []}
        locale={{
          emptyText: questionsQuery.error ? (
            <Empty
              description={questionsQuery.error instanceof Error ? questionsQuery.error.message : 'Failed to load questions'}
            >
              <Button onClick={() => questionsQuery.refetch()}>Retry</Button>
            </Empty>
          ) : (
            <Empty description="No chat questions match the current filters" />
          ),
        }}
        pagination={{
          current: questionsQuery.data?.pagination.page ?? pagination.page,
          pageSize: questionsQuery.data?.pagination.pageSize ?? pagination.pageSize,
          total: questionsQuery.data?.pagination.total ?? 0,
          showSizeChanger: true,
        }}
        onChange={onTableChange}
        columns={[
          {
            title: 'Question',
            dataIndex: 'text',
            ellipsis: true,
          },
          {
            title: 'Reply',
            dataIndex: 'reply',
            ellipsis: true,
            width: 320,
          },
          {
            title: 'Link',
            dataIndex: 'linkUrl',
            width: 120,
            render: (linkUrl?: string | null) =>
              linkUrl ? <Tag color="blue">Has Link</Tag> : '-',
          },
          { title: 'Sort', dataIndex: 'sortOrder', width: 80 },
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
                <Button type="link" onClick={() => navigate(`/chat-questions/${record.id}/edit`)}>
                  Edit
                </Button>
                {record.isActive ? (
                  <Popconfirm
                    title="Deactivate Question?"
                    description="This hides the question from users but keeps it editable."
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
