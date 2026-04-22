import { Button, Card, Form, Input, InputNumber, Select, Space, Switch, message } from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useNavigate, useParams } from 'react-router-dom';

import { faqCategoryApi } from '../faq-categories/api';
import { faqApi, type FaqPayload } from './api';

interface FormValues {
  categoryId: string;
  question: string;
  answer: string;
  keywordsText: string;
  sortOrder: number;
  isActive: boolean;
}

export function FaqFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [form] = Form.useForm<FormValues>();
  const isEditing = Boolean(id);

  const categoriesQuery = useQuery({
    queryKey: ['faq-categories'],
    queryFn: () => faqCategoryApi.list(),
  });

  const faqQuery = useQuery({
    queryKey: ['faq', id],
    enabled: isEditing,
    queryFn: async () => {
      const faq = await faqApi.get(id!);
      form.setFieldsValue({
        categoryId: faq.categoryId,
        question: faq.question,
        answer: faq.answer,
        keywordsText: faq.keywords.join(', '),
        sortOrder: faq.sortOrder,
        isActive: faq.isActive,
      });
      return faq;
    },
  });

  const mutation = useMutation({
    mutationFn: (payload: FaqPayload) =>
      isEditing ? faqApi.update(id!, payload) : faqApi.create(payload),
    onSuccess: async () => {
      message.success(isEditing ? 'FAQ updated' : 'FAQ created');
      await queryClient.invalidateQueries({ queryKey: ['faqs'] });
      navigate('/faqs');
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to save FAQ');
    },
  });

  return (
    <Card title={isEditing ? 'Edit FAQ' : 'New FAQ'} loading={faqQuery.isLoading}>
      <Form<FormValues>
        form={form}
        layout="vertical"
        initialValues={{
          categoryId: undefined,
          question: '',
          answer: '',
          keywordsText: '',
          sortOrder: 0,
          isActive: true,
        }}
        onFinish={(values) =>
          mutation.mutate({
            categoryId: values.categoryId,
            question: values.question.trim(),
            answer: values.answer.trim(),
            keywords: values.keywordsText
              .split(',')
              .map((keyword) => keyword.trim())
              .filter(Boolean),
            sortOrder: values.sortOrder,
            isActive: values.isActive,
          })
        }
      >
        <Form.Item
          label="Category"
          name="categoryId"
          rules={[{ required: true, message: 'Category is required' }]}
        >
          <Select
            placeholder="Select category"
            loading={categoriesQuery.isLoading}
            options={(categoriesQuery.data ?? []).map((category) => ({
              value: category.id,
              label: category.isActive ? category.name : `${category.name} (inactive)`,
            }))}
          />
        </Form.Item>
        <Form.Item
          label="Question"
          name="question"
          rules={[
            { required: true, message: 'Question is required' },
            { max: 255, message: 'Question must be 255 characters or fewer' },
            {
              validator: async (_, value: string | undefined) => {
                if (!value || value.trim().length > 0) {
                  return;
                }
                throw new Error('Question cannot be blank');
              },
            },
          ]}
        >
          <Input maxLength={255} showCount />
        </Form.Item>
        <Form.Item
          label="Answer"
          name="answer"
          rules={[
            { required: true, message: 'Answer is required' },
            {
              validator: async (_, value: string | undefined) => {
                if (!value || value.trim().length > 0) {
                  return;
                }
                throw new Error('Answer cannot be blank');
              },
            },
          ]}
        >
          <Input.TextArea rows={8} showCount />
        </Form.Item>
        <Form.Item
          label="Keywords"
          name="keywordsText"
          extra="Separate keywords with commas. Empty values are ignored."
        >
          <Input placeholder="refund, account, billing" />
        </Form.Item>
        <Form.Item
          label="Sort order"
          name="sortOrder"
          rules={[{ required: true, message: 'Sort order is required' }]}
          extra="Smaller numbers appear first."
        >
          <InputNumber style={{ width: '100%' }} />
        </Form.Item>
        <Form.Item
          label="Active"
          name="isActive"
          valuePropName="checked"
          extra="Inactive FAQs remain editable in admin but are hidden from users."
        >
          <Switch />
        </Form.Item>
        <Space>
          <Button onClick={() => navigate('/faqs')}>Cancel</Button>
          <Button type="primary" htmlType="submit" loading={mutation.isPending}>
            Save
          </Button>
        </Space>
      </Form>
    </Card>
  );
}
