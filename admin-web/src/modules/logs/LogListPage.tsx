import { DownloadOutlined, SearchOutlined } from '@ant-design/icons';
import {
  Button,
  Card,
  DatePicker,
  Empty,
  Form,
  Input,
  Select,
  Space,
  Table,
  Tag,
  Typography,
  message,
} from 'antd';
import type { TablePaginationConfig } from 'antd';
import { useQuery } from '@tanstack/react-query';
import dayjs from 'dayjs';
import { useMemo, useState } from 'react';

import { logsApi, type LogLine, type LogFileInfo } from './api';
import { useAuthStore } from '../auth/store';

function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

export function LogListPage() {
  const [selectedDate, setSelectedDate] = useState<string>(
    () => new Date().toISOString().slice(0, 10),
  );
  const [keyword, setKeyword] = useState<string>();
  const [pagination, setPagination] = useState({ page: 1, pageSize: 20 });

  const datesQuery = useQuery({
    queryKey: ['log-dates'],
    queryFn: () => logsApi.listDates(),
  });

  const logsQuery = useQuery({
    queryKey: ['logs', selectedDate, keyword, pagination],
    queryFn: () =>
      logsApi.readLog({
        date: selectedDate,
        page: pagination.page,
        pageSize: pagination.pageSize,
        keyword,
      }),
    enabled: !!selectedDate,
  });

  const dateOptions = useMemo(() => {
    const dates = datesQuery.data ?? [];
    return dates.map((d: LogFileInfo) => ({
      value: d.date,
      label: `${d.date} (${formatFileSize(d.fileSize)})`,
    }));
  }, [datesQuery.data]);

  const onTableChange = (nextPagination: TablePaginationConfig) => {
    setPagination({
      page: nextPagination.current ?? 1,
      pageSize: nextPagination.pageSize ?? 20,
    });
  };

  const handleDownload = async () => {
    const token = useAuthStore.getState().accessToken;
    if (!token) {
      message.error('Not authenticated');
      return;
    }
    const url = logsApi.getDownloadUrl(selectedDate);
    // Use fetch to include auth header, then trigger download
    try {
      const response = await fetch(url, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!response.ok) {
        throw new Error('Download failed');
      }
      const blob = await response.blob();
      const downloadUrl = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = downloadUrl;
      a.download = `access-${selectedDate}.log`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(downloadUrl);
    } catch {
      message.error('Failed to download log file');
    }
  };

  return (
    <Space direction="vertical" size="middle" style={{ width: '100%' }}>
      {/* Date selector card */}
      <Card title="Access Logs" size="small">
        <Space wrap>
          <Typography.Text>Select date:</Typography.Text>
          <Select
            showSearch
            style={{ width: 280 }}
            value={selectedDate}
            options={dateOptions}
            loading={datesQuery.isLoading}
            onChange={(value) => {
              setSelectedDate(value);
              setPagination((prev) => ({ ...prev, page: 1 }));
            }}
            notFoundContent={
              datesQuery.isLoading ? 'Loading...' : 'No log files found'
            }
          />
          <DatePicker
            allowClear={false}
            value={dayjs(selectedDate)}
            onChange={(date) => {
              if (date) {
                setSelectedDate(date.format('YYYY-MM-DD'));
                setPagination((prev) => ({ ...prev, page: 1 }));
              }
            }}
          />
          <Button
            icon={<DownloadOutlined />}
            onClick={handleDownload}
            loading={logsQuery.isLoading}
          >
            Download
          </Button>
        </Space>
      </Card>

      {/* Log entries table */}
      <Card size="small">
        <Form
          layout="inline"
          style={{ marginBottom: 16 }}
          onFinish={(values) => {
            setKeyword(values.keyword || undefined);
            setPagination((prev) => ({ ...prev, page: 1 }));
          }}
        >
          <Form.Item name="keyword">
            <Input
              allowClear
              prefix={<SearchOutlined />}
              placeholder="Search by IP, account, path..."
              style={{ width: 320 }}
            />
          </Form.Item>
          <Button htmlType="submit">Search</Button>
          <Button
            onClick={() => {
              setKeyword(undefined);
              setPagination((prev) => ({ ...prev, page: 1 }));
            }}
          >
            Reset
          </Button>
        </Form>

        <Table<LogLine>
          rowKey={(_, index) => String(index)}
          loading={logsQuery.isLoading}
          dataSource={logsQuery.data?.items ?? []}
          locale={{
            emptyText: logsQuery.error ? (
              <Empty
                description={
                  logsQuery.error instanceof Error
                    ? logsQuery.error.message
                    : 'Failed to load logs'
                }
              >
                <Button onClick={() => logsQuery.refetch()}>Retry</Button>
              </Empty>
            ) : (
              <Empty description="No logs for this date" />
            ),
          }}
          pagination={{
            current: logsQuery.data?.pagination.page ?? pagination.page,
            pageSize: logsQuery.data?.pagination.pageSize ?? pagination.pageSize,
            total: logsQuery.data?.pagination.total ?? 0,
            showSizeChanger: true,
            showTotal: (total) => `Total ${total} entries`,
          }}
          onChange={onTableChange}
          scroll={{ x: 1200 }}
          columns={[
            {
              title: 'Time',
              dataIndex: 'timestamp',
              width: 200,
              render: (v: string) =>
                v ? new Date(v).toLocaleString() : '-',
            },
            {
              title: 'IP',
              dataIndex: 'ip',
              width: 140,
            },
            {
              title: 'Account',
              dataIndex: 'account',
              width: 180,
              render: (v: string) => v || '-',
            },
            {
              title: 'Method',
              dataIndex: 'method',
              width: 90,
              render: (v: string) => {
                const color =
                  v === 'GET'
                    ? 'blue'
                    : v === 'POST'
                      ? 'green'
                      : v === 'PATCH'
                        ? 'orange'
                        : v === 'DELETE'
                          ? 'red'
                          : 'default';
                return <Tag color={color}>{v}</Tag>;
              },
            },
            {
              title: 'Path',
              dataIndex: 'path',
              ellipsis: true,
              width: 260,
            },
            {
              title: 'Status',
              dataIndex: 'statusCode',
              width: 90,
              render: (v: number) => (
                <Tag color={v >= 400 ? 'red' : v >= 300 ? 'orange' : 'green'}>
                  {v}
                </Tag>
              ),
            },
            {
              title: 'Duration',
              dataIndex: 'duration',
              width: 100,
              render: (v: number) => `${v}ms`,
              sorter: (a, b) => a.duration - b.duration,
            },
            {
              title: 'Response',
              dataIndex: 'response',
              ellipsis: true,
              width: 300,
            },
          ]}
        />
      </Card>
    </Space>
  );
}
