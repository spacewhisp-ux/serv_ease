import { Button, Card, Form, Input, Space, Switch, message } from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useNavigate, useParams } from 'react-router-dom';

import { chatKeywordApi, type ChatKeywordPayload } from './api';

interface FormValues {
  keyword: string;
  reply: string;
  isActive: boolean;
}

export function ChatKeywordFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [form] = Form.useForm<FormValues>();
  const isEditing = Boolean(id);

  const keywordQuery = useQuery({
    queryKey: ['chat-keyword', id],
    enabled: isEditing,
    queryFn: async () => {
      const keyword = await chatKeywordApi.get(id!);
      form.setFieldsValue({
        keyword: keyword.keyword,
        reply: keyword.reply,
        isActive: keyword.isActive,
      });
      return keyword;
    },
  });

  const mutation = useMutation({
    mutationFn: (payload: ChatKeywordPayload) =>
      isEditing ? chatKeywordApi.update(id!, payload) : chatKeywordApi.create(payload),
    onSuccess: async () => {
      message.success(isEditing ? 'Keyword updated' : 'Keyword created');
      await queryClient.invalidateQueries({ queryKey: ['chat-keywords'] });
      navigate('/chat-keywords');
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to save keyword');
    },
  });

  return (
    <Card title={isEditing ? 'Edit Chat Keyword' : 'New Chat Keyword'} loading={keywordQuery.isLoading}>
      <Form<FormValues>
        form={form}
        layout="vertical"
        initialValues={{
          keyword: '',
          reply: '',
          isActive: true,
        }}
        onFinish={(values) =>
          mutation.mutate({
            keyword: values.keyword.trim(),
            reply: values.reply.trim(),
            isActive: values.isActive,
          })
        }
      >
        <Form.Item
          label="Keyword"
          name="keyword"
          extra="When a user's message contains this keyword (case-insensitive), the system auto-replies with the response below. Longer keywords are matched first."
          rules={[
            { required: true, message: 'Keyword is required' },
            { max: 120, message: 'Keyword must be 120 characters or fewer' },
            {
              validator: async (_, value: string | undefined) => {
                if (!value || value.trim().length > 0) return;
                throw new Error('Keyword cannot be blank');
              },
            },
          ]}
        >
          <Input maxLength={120} showCount />
        </Form.Item>
        <Form.Item
          label="Reply"
          name="reply"
          rules={[
            { required: true, message: 'Reply is required' },
            {
              validator: async (_, value: string | undefined) => {
                if (!value || value.trim().length > 0) return;
                throw new Error('Reply cannot be blank');
              },
            },
          ]}
        >
          <Input.TextArea rows={8} showCount />
        </Form.Item>
        <Form.Item
          label="Active"
          name="isActive"
          valuePropName="checked"
          extra="Inactive keywords are not used for matching but remain editable."
        >
          <Switch />
        </Form.Item>
        <Space>
          <Button onClick={() => navigate('/chat-keywords')}>Cancel</Button>
          <Button type="primary" htmlType="submit" loading={mutation.isPending}>
            Save
          </Button>
        </Space>
      </Form>
    </Card>
  );
}
