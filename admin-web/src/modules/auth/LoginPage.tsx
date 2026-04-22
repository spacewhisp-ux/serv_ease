import { Button, Card, Form, Input, Typography, message } from 'antd';
import { useNavigate } from 'react-router-dom';

import { authApi, type LoginPayload } from './api';
import { canUseAdmin, useAuthStore } from './store';

export function LoginPage() {
  const navigate = useNavigate();
  const setSession = useAuthStore((state) => state.setSession);

  const onFinish = async (values: LoginPayload) => {
    try {
      const result = await authApi.login(values);
      if (!canUseAdmin(result.user)) {
        message.error('This account does not have admin access.');
        return;
      }
      setSession(result);
      navigate('/faqs', { replace: true });
    } catch (error) {
      message.error(error instanceof Error ? error.message : 'Login failed');
    }
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        display: 'grid',
        placeItems: 'center',
        background: '#f5f5f5',
        padding: 24,
      }}
    >
      <Card style={{ width: 420 }}>
        <Typography.Title level={3}>Serv Ease Admin</Typography.Title>
        <Typography.Paragraph type="secondary">
          Sign in with an AGENT or ADMIN account.
        </Typography.Paragraph>
        <Form<LoginPayload> layout="vertical" onFinish={onFinish}>
          <Form.Item
            label="Account"
            name="account"
            rules={[{ required: true, message: 'Account is required' }]}
          >
            <Input placeholder="Email, phone, or username" />
          </Form.Item>
          <Form.Item
            label="Password"
            name="password"
            rules={[{ required: true, message: 'Password is required' }]}
          >
            <Input.Password />
          </Form.Item>
          <Button block type="primary" htmlType="submit">
            Sign in
          </Button>
        </Form>
      </Card>
    </div>
  );
}
