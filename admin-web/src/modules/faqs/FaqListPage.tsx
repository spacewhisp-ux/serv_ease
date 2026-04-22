import { PlusOutlined, SearchOutlined } from '@ant-design/icons';
import { Button, Card, Empty, Form, Input, Popconfirm, Select, Space, Table, Tag, message } from 'antd';
import type { TablePaginationConfig } from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';

import { faqCategoryApi } from '../faq-categories/api';
import { faqApi, type FaqListQuery, type FaqRecord } from './api';

type StatusFilter = 'active' | 'inactive' | 'all';

interface FilterValues {
  keyword?: string;
  categoryId?: string;
  status?: StatusFilter;
}

export function FaqListPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [filters, setFilters] = useState<FilterValues>({ status: 'active' });
  const [pagination, setPagination] = useState({ page: 1, pageSize: 10 });

  const query = useMemo<FaqListQuery>(
    () => ({
      page: pagination.page,
      pageSize: pagination.pageSize,
      keyword: filters.keyword,
      categoryId: filters.categoryId,
      isActive:
        filters.status === 'all' ? undefined : filters.status !== 'inactive',
    }),
    [filters, pagination],
  );

  const categoriesQuery = useQuery({
    queryKey: ['faq-categories'],
    queryFn: () => faqCategoryApi.list(),
  });
  const faqsQuery = useQuery({
    queryKey: ['faqs', query],
    queryFn: () => faqApi.list(query),
  });
  const [filterForm] = Form.useForm<FilterValues>();

  const deactivateMutation = useMutation({
    mutationFn: (id: string) => faqApi.deactivate(id),
    onSuccess: async () => {
      message.success('FAQ deactivated');
      await queryClient.invalidateQueries({ queryKey: ['faqs'] });
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to deactivate FAQ');
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
      title="FAQs"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={() => navigate('/faqs/new')}>
          New FAQ
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
          <Input allowClear prefix={<SearchOutlined />} placeholder="Search question or answer" style={{ width: 260 }} />
        </Form.Item>
        <Form.Item name="categoryId">
          <Select
            allowClear
            placeholder="Category"
            style={{ width: 220 }}
            options={(categoriesQuery.data ?? []).map((category) => ({
              value: category.id,
              label: category.isActive ? category.name : `${category.name} (inactive)`,
            }))}
          />
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
      <Table<FaqRecord>
        rowKey="id"
        loading={faqsQuery.isLoading}
        dataSource={faqsQuery.data?.items ?? []}
        locale={{
          emptyText: faqsQuery.error ? (
            <Empty
              description={faqsQuery.error instanceof Error ? faqsQuery.error.message : 'Failed to load FAQs'}
            >
              <Button onClick={() => faqsQuery.refetch()}>Retry</Button>
            </Empty>
          ) : (
            <Empty description="No FAQs match the current filters" />
          ),
        }}
        pagination={{
          current: faqsQuery.data?.pagination.page ?? pagination.page,
          pageSize: faqsQuery.data?.pagination.pageSize ?? pagination.pageSize,
          total: faqsQuery.data?.pagination.total ?? 0,
          showSizeChanger: true,
        }}
        onChange={onTableChange}
        columns={[
          {
            title: 'Question',
            dataIndex: 'question',
            ellipsis: true,
          },
          {
            title: 'Category',
            render: (_, record) => record.category?.name ?? '-',
            width: 180,
          },
          {
            title: 'Keywords',
            dataIndex: 'keywords',
            render: (keywords: string[]) => (
              <Space size={[4, 4]} wrap>
                {keywords.map((keyword) => (
                  <Tag key={keyword}>{keyword}</Tag>
                ))}
              </Space>
            ),
          },
          { title: 'Sort', dataIndex: 'sortOrder', width: 90 },
          {
            title: 'Status',
            dataIndex: 'isActive',
            width: 120,
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
                <Button type="link" onClick={() => navigate(`/faqs/${record.id}/edit`)}>
                  Edit
                </Button>
                {record.isActive ? (
                  <Popconfirm
                    title="Deactivate FAQ?"
                    description="This hides the FAQ from users but keeps it editable."
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
