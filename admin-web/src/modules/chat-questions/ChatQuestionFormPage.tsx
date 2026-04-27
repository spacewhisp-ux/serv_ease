import { Button, Card, Form, Input, InputNumber, Space, Switch, message } from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useNavigate, useParams } from 'react-router-dom';

import { chatQuestionApi, type ChatQuestionPayload } from './api';

interface FormValues {
  text: string;
  reply: string;
  linkUrl?: string;
  linkLabel?: string;
  sortOrder: number;
  isActive: boolean;
}

export function ChatQuestionFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [form] = Form.useForm<FormValues>();
  const isEditing = Boolean(id);

  const questionQuery = useQuery({
    queryKey: ['chat-question', id],
    enabled: isEditing,
    queryFn: async () => {
      const question = await chatQuestionApi.get(id!);
      form.setFieldsValue({
        text: question.text,
        reply: question.reply,
        linkUrl: question.linkUrl ?? '',
        linkLabel: question.linkLabel ?? '',
        sortOrder: question.sortOrder,
        isActive: question.isActive,
      });
      return question;
    },
  });

  const mutation = useMutation({
    mutationFn: (payload: ChatQuestionPayload) =>
      isEditing ? chatQuestionApi.update(id!, payload) : chatQuestionApi.create(payload),
    onSuccess: async () => {
      message.success(isEditing ? 'Question updated' : 'Question created');
      await queryClient.invalidateQueries({ queryKey: ['chat-questions'] });
      navigate('/chat-questions');
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to save question');
    },
  });

  return (
    <Card title={isEditing ? 'Edit Chat Question' : 'New Chat Question'} loading={questionQuery.isLoading}>
      <Form<FormValues>
        form={form}
        layout="vertical"
        initialValues={{
          text: '',
          reply: '',
          linkUrl: '',
          linkLabel: '',
          sortOrder: 0,
          isActive: true,
        }}
        onFinish={(values) =>
          mutation.mutate({
            text: values.text.trim(),
            reply: values.reply.trim(),
            linkUrl: values.linkUrl?.trim() || undefined,
            linkLabel: values.linkLabel?.trim() || undefined,
            sortOrder: values.sortOrder,
            isActive: values.isActive,
          })
        }
      >
        <Form.Item
          label="Question Text"
          name="text"
          rules={[
            { required: true, message: 'Question text is required' },
            { max: 255, message: 'Question must be 255 characters or fewer' },
          ]}
        >
          <Input maxLength={255} showCount />
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
          label="Link URL"
          name="linkUrl"
          extra="Optional external link shown after the reply."
        >
          <Input placeholder="https://example.com/help" />
        </Form.Item>
        <Form.Item
          label="Link Label"
          name="linkLabel"
          extra="Display text for the link. Defaults to '查看详情' if URL is set but label is empty."
        >
          <Input maxLength={120} placeholder="查看详情" showCount />
        </Form.Item>
        <Form.Item
          label="Sort Order"
          name="sortOrder"
          rules={[{ required: true, message: 'Sort order is required' }]}
          extra="Smaller numbers appear first in the quick-reply list."
        >
          <InputNumber style={{ width: '100%' }} />
        </Form.Item>
        <Form.Item
          label="Active"
          name="isActive"
          valuePropName="checked"
          extra="Inactive questions are hidden from users but remain editable."
        >
          <Switch />
        </Form.Item>
        <Space>
          <Button onClick={() => navigate('/chat-questions')}>Cancel</Button>
          <Button type="primary" htmlType="submit" loading={mutation.isPending}>
            Save
          </Button>
        </Space>
      </Form>
    </Card>
  );
}
