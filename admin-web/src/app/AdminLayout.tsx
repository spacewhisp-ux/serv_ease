import { Button, Dropdown, Layout, Menu, Space, Typography, message } from 'antd';
import {
  FileTextOutlined,
  FolderOpenOutlined,
  KeyOutlined,
  LogoutOutlined,
  UserOutlined,
  FileSearchOutlined,
  MessageOutlined,
  QuestionCircleOutlined,
} from '@ant-design/icons';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';

import { authApi } from '../modules/auth/api';
import { clearSessionTokens } from '../shared/session/storage';
import { useAuthStore } from '../modules/auth/store';

const { Header, Sider, Content } = Layout;

export function AdminLayout() {
  const location = useLocation();
  const navigate = useNavigate();
  const user = useAuthStore((state) => state.user);
  const refreshToken = useAuthStore((state) => state.refreshToken);
  const setSession = useAuthStore((state) => state.setSession);

  const selectedKey = location.pathname.startsWith('/chat-questions')
    ? 'chat-questions'
    : location.pathname.startsWith('/chat-keywords')
      ? 'chat-keywords'
      : location.pathname.startsWith('/categories')
        ? 'categories'
        : location.pathname.startsWith('/tickets')
          ? 'tickets'
          : location.pathname.startsWith('/logs')
            ? 'logs'
            : 'faqs';

  const menuItems = [
    { key: 'faqs', icon: <FileTextOutlined />, label: 'FAQs' },
    { key: 'categories', icon: <FolderOpenOutlined />, label: 'FAQ Categories' },
    {
      key: 'chat-group',
      icon: <MessageOutlined />,
      label: 'Chat Q&A',
      children: [
        { key: 'chat-questions', icon: <QuestionCircleOutlined />, label: 'Questions' },
        { key: 'chat-keywords', icon: <KeyOutlined />, label: 'Keywords' },
      ],
    },
    { key: 'tickets', icon: <MessageOutlined />, label: 'Tickets' },
    { key: 'logs', icon: <FileSearchOutlined />, label: 'Access Logs' },
  ];

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider width={240} theme="light" style={{ borderRight: '1px solid #f0f0f0' }}>
        <div style={{ padding: 24 }}>
          <Typography.Title level={4} style={{ margin: 0 }}>
            Serv Ease Admin
          </Typography.Title>
        </div>
        <Menu
          mode="inline"
          selectedKeys={[selectedKey]}
          items={menuItems}
          onClick={({ key }) => {
            const routeMap: Record<string, string> = {
              'chat-questions': '/chat-questions',
              'chat-keywords': '/chat-keywords',
              categories: '/categories',
              tickets: '/tickets',
              logs: '/logs',
            };
            navigate(routeMap[key] ?? '/faqs');
          }}
        />
      </Sider>
      <Layout>
        <Header
          style={{
            background: '#ffffff',
            padding: '0 24px',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            borderBottom: '1px solid #f0f0f0',
          }}
        >
          <Typography.Text strong>
            {selectedKey === 'chat-questions'
              ? 'Chat Questions'
              : selectedKey === 'chat-keywords'
                ? 'Chat Keywords'
                : selectedKey === 'categories'
                  ? 'FAQ Categories'
                  : selectedKey === 'tickets'
                    ? 'Tickets'
                    : selectedKey === 'logs'
                      ? 'Access Logs'
                      : 'FAQs'}
          </Typography.Text>
          <Dropdown
            menu={{
              items: [
                {
                  key: 'logout',
                  icon: <LogoutOutlined />,
                  label: 'Logout',
                },
              ],
              onClick: async ({ key }) => {
                if (key !== 'logout') {
                  return;
                }
                try {
                  if (refreshToken) {
                    await authApi.logout(refreshToken);
                  }
                } catch (error) {
                  message.warning(
                    error instanceof Error
                      ? error.message
                      : 'Logout failed, clearing local session only.',
                  );
                } finally {
                  clearSessionTokens();
                  setSession({ accessToken: null, refreshToken: null, user: null });
                  navigate('/login', { replace: true });
                }
              },
            }}
          >
            <Button type="text">
              <Space>
                <UserOutlined />
                <span>{user?.displayName ?? user?.email ?? 'Account'}</span>
                <Typography.Text type="secondary">{user?.role}</Typography.Text>
              </Space>
            </Button>
          </Dropdown>
        </Header>
        <Content style={{ padding: 24, background: '#f5f5f5' }}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  );
}
