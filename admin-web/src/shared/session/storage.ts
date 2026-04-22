const ACCESS_TOKEN_KEY = 'serv-ease-admin-access-token';
const REFRESH_TOKEN_KEY = 'serv-ease-admin-refresh-token';
const USER_KEY = 'serv-ease-admin-user';

export interface StoredUser {
  id: string;
  email: string;
  displayName?: string | null;
  role: string;
}

export interface StoredSession {
  accessToken: string | null;
  refreshToken: string | null;
  user: StoredUser | null;
}

export function readSessionTokens(): StoredSession {
  const accessToken = localStorage.getItem(ACCESS_TOKEN_KEY);
  const refreshToken = localStorage.getItem(REFRESH_TOKEN_KEY);
  const userRaw = localStorage.getItem(USER_KEY);

  return {
    accessToken,
    refreshToken,
    user: userRaw ? (JSON.parse(userRaw) as StoredUser) : null,
  };
}

export function writeSessionTokens(session: StoredSession) {
  if (session.accessToken) {
    localStorage.setItem(ACCESS_TOKEN_KEY, session.accessToken);
  } else {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
  }

  if (session.refreshToken) {
    localStorage.setItem(REFRESH_TOKEN_KEY, session.refreshToken);
  } else {
    localStorage.removeItem(REFRESH_TOKEN_KEY);
  }

  if (session.user) {
    localStorage.setItem(USER_KEY, JSON.stringify(session.user));
  } else {
    localStorage.removeItem(USER_KEY);
  }
}

export function clearSessionTokens() {
  writeSessionTokens({ accessToken: null, refreshToken: null, user: null });
}
