import { PlusOutlined } from '@ant-design/icons';
import { Button, Card, Empty, Popconfirm, Space, Table, Tag, message } from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';

import { faqCategoryApi, type FaqCategoryRecord } from './api';

export function CategoryListPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { data = [], isLoading, error, refetch } = useQuery({
    queryKey: ['faq-categories'],
    queryFn: () => faqCategoryApi.list(),
  });

  const deactivateMutation = useMutation({
    mutationFn: (id: string) => faqCategoryApi.deactivate(id),
    onSuccess: async () => {
      message.success('Category deactivated');
      await queryClient.invalidateQueries({ queryKey: ['faq-categories'] });
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to deactivate category');
    },
  });

  return (
    <Card
      title="FAQ Categories"
      extra={
        <Button type="primary" icon={<PlusOutlined />} onClick={() => navigate('/categories/new')}>
          New category
        </Button>
      }
    >
      <Table<FaqCategoryRecord>
        rowKey="id"
        loading={isLoading}
        dataSource={data}
        pagination={false}
        locale={{
          emptyText: error ? (
            <Empty
              description={error instanceof Error ? error.message : 'Failed to load categories'}
            >
              <Button onClick={() => refetch()}>Retry</Button>
            </Empty>
          ) : (
            <Empty description="No FAQ categories yet" />
          ),
        }}
        columns={[
          { title: 'Name', dataIndex: 'name' },
          { title: 'Sort', dataIndex: 'sortOrder', width: 100 },
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
                <Button type="link" onClick={() => navigate(`/categories/${record.id}/edit`)}>
                  Edit
                </Button>
                {record.isActive ? (
                  <Popconfirm
                    title="Deactivate category?"
                    description="This hides the category from public FAQ navigation."
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
