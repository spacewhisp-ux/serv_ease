import { ArrowLeftOutlined } from '@ant-design/icons';
import {
  Alert,
  Button,
  Card,
  Descriptions,
  Divider,
  Empty,
  Form,
  Input,
  Select,
  Space,
  Switch,
  Tag,
  Timeline,
  Typography,
  message,
} from 'antd';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';

import { useAuthStore } from '../auth/store';
import {
  ticketApi,
  ticketHistoryActionLabels,
  ticketPriorityColors,
  ticketStatusColors,
  ticketStatusLabels,
  ticketStatuses,
  type ReplyTicketPayload,
  type TicketAttachment,
  type TicketDetail,
  type TicketHistory,
  type TicketMessage,
  type TicketStatus,
} from './api';

interface ReplyFormValues {
  body: string;
  isInternal: boolean;
}

interface StatusFormValues {
  status: TicketStatus;
}

interface AssignmentFormValues {
  agentId: string;
}

function formatIdentity(user?: { id: string; displayName?: string | null; email?: string | null; phone?: string | null } | null) {
  if (!user) {
    return '-';
  }

  return user.displayName ?? user.email ?? user.phone ?? user.id;
}

function formatFileSize(fileSize: number) {
  if (fileSize < 1024) {
    return `${fileSize} B`;
  }
  if (fileSize < 1024 * 1024) {
    return `${(fileSize / 1024).toFixed(1)} KB`;
  }
  return `${(fileSize / 1024 / 1024).toFixed(1)} MB`;
}

function AttachmentList({ attachments }: { attachments: TicketAttachment[] }) {
  if (!attachments.length) {
    return null;
  }

  return (
    <Space direction="vertical" size={4} style={{ marginTop: 8 }}>
      {attachments.map((attachment) => (
        <Typography.Text key={attachment.id} type="secondary">
          {attachment.fileName} · {formatFileSize(attachment.fileSize)} · {attachment.mimeType}
        </Typography.Text>
      ))}
    </Space>
  );
}

function MessageTitle({ item }: { item: TicketMessage }) {
  const sender = item.sender ? formatIdentity(item.sender) : item.senderRole;

  return (
    <Space size={8} wrap>
      <Tag color={item.senderRole === 'USER' ? 'blue' : item.senderRole === 'AGENT' ? 'purple' : 'default'}>
        {item.senderRole}
      </Tag>
      {item.isInternal ? <Tag color="orange">Internal</Tag> : null}
      <Typography.Text strong>{sender}</Typography.Text>
      <Typography.Text type="secondary">{new Date(item.createdAt).toLocaleString()}</Typography.Text>
    </Space>
  );
}

function HistoryItem({ item }: { item: TicketHistory }) {
  const actor = item.actor ? formatIdentity(item.actor) : item.actorRole;

  return (
    <Space size={8} wrap>
      <Tag color={item.actorRole === 'USER' ? 'blue' : item.actorRole === 'AGENT' ? 'purple' : item.actorRole === 'ADMIN' ? 'gold' : 'default'}>
        {item.actorRole}
      </Tag>
      <Typography.Text strong>{ticketHistoryActionLabels[item.action]}</Typography.Text>
      {item.oldValue || item.newValue ? (
        <Typography.Text type="secondary">
          {item.oldValue ? `"${item.oldValue}"` : ''} → {item.newValue ? `"${item.newValue}"` : ''}
        </Typography.Text>
      ) : null}
      <Typography.Text type="secondary">by {actor}</Typography.Text>
      <Typography.Text type="secondary">{new Date(item.createdAt).toLocaleString()}</Typography.Text>
    </Space>
  );
}

function TicketSummary({ ticket }: { ticket: TicketDetail }) {
  const ticketLevelAttachments = ticket.attachments.filter((attachment) => !attachment.messageId);

  return (
    <Card title="Ticket details">
      <Descriptions column={2} size="small" bordered>
        <Descriptions.Item label="Ticket no">{ticket.ticketNo}</Descriptions.Item>
        <Descriptions.Item label="Status">
          <Tag color={ticketStatusColors[ticket.status]}>{ticketStatusLabels[ticket.status]}</Tag>
        </Descriptions.Item>
        <Descriptions.Item label="Subject">{ticket.subject}</Descriptions.Item>
        <Descriptions.Item label="Priority">
          <Tag color={ticketPriorityColors[ticket.priority]}>{ticket.priority}</Tag>
        </Descriptions.Item>
        <Descriptions.Item label="Category">{ticket.category ?? '-'}</Descriptions.Item>
        <Descriptions.Item label="User">{formatIdentity(ticket.user)}</Descriptions.Item>
        <Descriptions.Item label="Assignee">{formatIdentity(ticket.assignedAgent)}</Descriptions.Item>
        <Descriptions.Item label="Created">
          {ticket.createdAt ? new Date(ticket.createdAt).toLocaleString() : '-'}
        </Descriptions.Item>
        <Descriptions.Item label="Updated">
          {ticket.updatedAt ? new Date(ticket.updatedAt).toLocaleString() : '-'}
        </Descriptions.Item>
        <Descriptions.Item label="Resolved">
          {ticket.resolvedAt ? new Date(ticket.resolvedAt).toLocaleString() : '-'}
        </Descriptions.Item>
        <Descriptions.Item label="Closed">
          {ticket.closedAt ? new Date(ticket.closedAt).toLocaleString() : '-'}
        </Descriptions.Item>
        <Descriptions.Item label="Description" span={2}>
          <Typography.Paragraph style={{ marginBottom: 0, whiteSpace: 'pre-wrap' }}>
            {ticket.description}
          </Typography.Paragraph>
          <AttachmentList attachments={ticketLevelAttachments} />
        </Descriptions.Item>
      </Descriptions>
    </Card>
  );
}

export function TicketDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const currentUser = useAuthStore((state) => state.user);
  const [replyForm] = Form.useForm<ReplyFormValues>();
  const [statusForm] = Form.useForm<StatusFormValues>();
  const [assignmentForm] = Form.useForm<AssignmentFormValues>();

  const ticketQuery = useQuery({
    queryKey: ['ticket', id],
    enabled: Boolean(id),
    queryFn: () => ticketApi.get(id!),
  });
  const agentsQuery = useQuery({
    queryKey: ['assignable-agents'],
    queryFn: () => ticketApi.listAssignableAgents(),
  });
  const historyQuery = useQuery({
    queryKey: ['ticket-history', id],
    enabled: Boolean(id),
    queryFn: () => ticketApi.getHistory(id!),
  });

  useEffect(() => {
    if (ticketQuery.data) {
      statusForm.setFieldsValue({ status: ticketQuery.data.status });
      assignmentForm.setFieldsValue({ agentId: ticketQuery.data.assignedAgent?.id ?? '' });
    }
  }, [assignmentForm, statusForm, ticketQuery.data]);

  const invalidateTicket = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: ['ticket', id] }),
      queryClient.invalidateQueries({ queryKey: ['tickets'] }),
      queryClient.invalidateQueries({ queryKey: ['ticket-history', id] }),
    ]);
  };

  const assignMutation = useMutation({
    mutationFn: (agentId: string) => ticketApi.assign(id!, agentId),
    onSuccess: async () => {
      message.success('Assignee updated');
      await invalidateTicket();
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to assign ticket');
      if (ticketQuery.data) {
        assignmentForm.setFieldsValue({ agentId: ticketQuery.data.assignedAgent?.id ?? '' });
      }
    },
  });

  const replyMutation = useMutation({
    mutationFn: (payload: ReplyTicketPayload) => ticketApi.reply(id!, payload),
    onSuccess: async () => {
      message.success('Reply sent');
      replyForm.resetFields();
      await invalidateTicket();
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to send reply');
    },
  });

  const statusMutation = useMutation({
    mutationFn: (payload: StatusFormValues) => ticketApi.updateStatus(id!, payload),
    onSuccess: async () => {
      message.success('Ticket status updated');
      await invalidateTicket();
    },
    onError: (error) => {
      message.error(error instanceof Error ? error.message : 'Failed to update ticket status');
      if (ticketQuery.data) {
        statusForm.setFieldsValue({ status: ticketQuery.data.status });
      }
    },
  });

  if (!id) {
    return <Alert type="error" message="Ticket id is missing" />;
  }

  if (ticketQuery.error) {
    return (
      <Card>
        <Empty
          description={ticketQuery.error instanceof Error ? ticketQuery.error.message : 'Failed to load ticket'}
        >
          <Space>
            <Button onClick={() => navigate('/tickets')}>Back</Button>
            <Button type="primary" onClick={() => ticketQuery.refetch()}>
              Retry
            </Button>
          </Space>
        </Empty>
      </Card>
    );
  }

  const ticket = ticketQuery.data;
  const isClosed = ticket?.status === 'CLOSED';
  const agentOptions = (agentsQuery.data ?? []).map((agent) => ({
    value: agent.id,
    label: `${formatIdentity(agent)}${agent.role ? ` (${agent.role})` : ''}`,
  }));

  return (
    <Space direction="vertical" size={16} style={{ width: '100%' }}>
      <Space>
        <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/tickets')}>
          Back
        </Button>
        <Typography.Title level={4} style={{ margin: 0 }}>
          {ticket ? ticket.ticketNo : 'Ticket'}
        </Typography.Title>
      </Space>

      <Card loading={ticketQuery.isLoading}>{ticket ? <TicketSummary ticket={ticket} /> : null}</Card>

      {ticket ? (
        <Card title="Actions">
          <Space direction="vertical" size={16} style={{ width: '100%' }}>
            <Form<AssignmentFormValues>
              form={assignmentForm}
              layout="inline"
              initialValues={{ agentId: ticket.assignedAgent?.id ?? '' }}
              onFinish={(values) => assignMutation.mutate(values.agentId)}
            >
              <Form.Item
                name="agentId"
                label="Assignee"
                rules={[{ required: true, message: 'Assignee is required' }]}
              >
                <Select
                  style={{ width: 260 }}
                  placeholder="Select assignee"
                  loading={agentsQuery.isLoading}
                  disabled={isClosed}
                  options={agentOptions}
                />
              </Form.Item>
              <Button type="primary" htmlType="submit" loading={assignMutation.isPending} disabled={isClosed}>
                Update assignee
              </Button>
            </Form>
            {isClosed ? <Tag>Closed tickets cannot be assigned or replied to</Tag> : null}
            <Form<StatusFormValues>
              form={statusForm}
              layout="inline"
              initialValues={{ status: ticket.status }}
              onFinish={(values) => statusMutation.mutate(values)}
            >
              <Form.Item name="status" label="Status" rules={[{ required: true, message: 'Status is required' }]}>
                <Select
                  style={{ width: 180 }}
                  options={ticketStatuses.map((status) => ({
                    value: status,
                    label: ticketStatusLabels[status],
                  }))}
                />
              </Form.Item>
              <Button type="primary" htmlType="submit" loading={statusMutation.isPending}>
                Update status
              </Button>
            </Form>
          </Space>
        </Card>
      ) : null}

      <Card title="History" loading={historyQuery.isLoading}>
        {historyQuery.data && historyQuery.data.length ? (
          <Timeline
            items={historyQuery.data.map((item) => ({
              children: <HistoryItem item={item} />,
            }))}
          />
        ) : (
          <Empty description="No history yet" />
        )}
      </Card>

      <Card title="Messages" loading={ticketQuery.isLoading}>
        {ticket && ticket.messages.length ? (
          <Timeline
            items={ticket.messages.map((item) => ({
              children: (
                <div>
                  <MessageTitle item={item} />
                  <Typography.Paragraph style={{ marginTop: 8, marginBottom: 0, whiteSpace: 'pre-wrap' }}>
                    {item.body}
                  </Typography.Paragraph>
                  <AttachmentList attachments={item.attachments} />
                </div>
              ),
            }))}
          />
        ) : (
          <Empty description="No messages yet" />
        )}
      </Card>

      {ticket ? (
        <Card title="Reply">
          <Form<ReplyFormValues>
            form={replyForm}
            layout="vertical"
            initialValues={{ body: '', isInternal: false }}
            onFinish={(values) =>
              replyMutation.mutate({
                body: values.body.trim(),
                isInternal: values.isInternal,
              })
            }
          >
            <Form.Item
              name="body"
              label="Message"
              rules={[
                { required: true, message: 'Message is required' },
                {
                  validator: async (_, value: string | undefined) => {
                    if (!value || value.trim().length > 0) {
                      return;
                    }
                    throw new Error('Message cannot be blank');
                  },
                },
              ]}
            >
              <Input.TextArea rows={5} disabled={isClosed} showCount />
            </Form.Item>
            <Form.Item
              name="isInternal"
              valuePropName="checked"
              extra="Internal notes are visible to admins only."
            >
              <Switch checkedChildren="Internal" unCheckedChildren="Public" disabled={isClosed} />
            </Form.Item>
            <Divider />
            <Space>
              <Button onClick={() => replyForm.resetFields()} disabled={replyMutation.isPending || isClosed}>
                Clear
              </Button>
              <Button type="primary" htmlType="submit" loading={replyMutation.isPending} disabled={isClosed}>
                Send reply
              </Button>
            </Space>
          </Form>
        </Card>
      ) : null}
    </Space>
  );
}
