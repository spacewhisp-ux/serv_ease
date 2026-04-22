import { Button, Card, Checkbox, Form, Input, InputNumber, Space, message } from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useNavigate, useParams } from 'react-router-dom';

import { faqCategoryApi, type CategoryPayload } from './api';

export function CategoryFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [form] = Form.useForm<CategoryPayload>();
  const isEditing = Boolean(id);

  const { isLoading: isFetching } = useQuery({
    queryKey: ['faq-category', id],
    enabled: isEditing,
    queryFn: async () => {
      const category = await faqCategoryApi.get(id!);
      if (!category) {
        throw new Error('Category not found');
      }
      form.setFieldsValue({
        name: category.name,
        sortOrder: category.sortOrder,
        isActive: category.isActive,
      });
      return category;
    },
  });

  const mutation = useMutation({
    mutationFn: (values: CategoryPayload) =>
      isEditing ? faqCategoryApi.update(id!, values) : faqCategoryApi.create(values),
    onSuccess: async () => {
      message.success(isEditing ? 'Category updated' : 'Category created');
      await queryClient.invalidateQueries({ queryKey: ['faq-categories'] });
      navigate('/categories');
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to save category');
    },
  });

  return (
    <Card title={isEditing ? 'Edit category' : 'New category'} loading={isFetching}>
      <Form<CategoryPayload>
        form={form}
        layout="vertical"
        initialValues={{ name: '', sortOrder: 0, isActive: true }}
        onFinish={(values) => mutation.mutate(values)}
      >
        <Form.Item
          label="Name"
          name="name"
          rules={[
            { required: true, message: 'Name is required' },
            { max: 120, message: 'Name must be 120 characters or fewer' },
            {
              validator: async (_, value: string | undefined) => {
                if (!value || value.trim().length > 0) {
                  return;
                }
                throw new Error('Name cannot be blank');
              },
            },
          ]}
        >
          <Input maxLength={120} showCount />
        </Form.Item>
        <Form.Item
          label="Sort order"
          name="sortOrder"
          rules={[{ required: true, message: 'Sort order is required' }]}
          extra="Smaller numbers appear first."
        >
          <InputNumber style={{ width: '100%' }} />
        </Form.Item>
        <Form.Item name="isActive" valuePropName="checked" extra="Inactive categories stay editable in admin but are hidden from public FAQ navigation.">
          <Checkbox>Active</Checkbox>
        </Form.Item>
        <Space>
          <Button onClick={() => navigate('/categories')}>Cancel</Button>
          <Button type="primary" htmlType="submit" loading={mutation.isPending}>
            Save
          </Button>
        </Space>
      </Form>
    </Card>
  );
}
