import React from 'react';
import ReactDOM from 'react-dom/client';
import { ConfigProvider } from 'antd';

import { App } from './app/App';
import { AppProviders } from './app/providers';
import 'antd/dist/reset.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ConfigProvider
      theme={{
        token: {
          colorPrimary: '#000000',
          borderRadius: 12,
        },
      }}
    >
      <AppProviders>
        <App />
      </AppProviders>
    </ConfigProvider>
  </React.StrictMode>,
);
