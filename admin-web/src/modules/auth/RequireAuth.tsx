import { Spin } from 'antd';
import { useEffect } from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';

import { authApi } from './api';
import { canUseAdmin, useAuthStore } from './store';

export function RequireAuth() {
  const location = useLocation();
  const {
    accessToken,
    refreshToken,
    user,
    isBootstrapped,
    setSession,
    setBootstrapped,
    logout,
  } = useAuthStore();

  useEffect(() => {
    if (isBootstrapped) {
      return;
    }

    if (!accessToken || !refreshToken) {
      setBootstrapped(true);
      return;
    }

    authApi
      .me()
      .then((nextUser) => {
        if (!canUseAdmin(nextUser)) {
          logout();
          return;
        }
        setSession({ accessToken, refreshToken, user: nextUser });
      })
      .catch(() => {
        logout();
      })
      .finally(() => {
        setBootstrapped(true);
      });
  }, [
    accessToken,
    isBootstrapped,
    logout,
    refreshToken,
    setBootstrapped,
    setSession,
  ]);

  if (!isBootstrapped) {
    return (
      <div style={{ minHeight: '100vh', display: 'grid', placeItems: 'center' }}>
        <Spin size="large" />
      </div>
    );
  }

  if (!accessToken || !refreshToken || !user) {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }

  if (!canUseAdmin(user)) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}
