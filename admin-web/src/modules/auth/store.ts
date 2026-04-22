import { create } from 'zustand';

import {
  clearSessionTokens,
  readSessionTokens,
  type StoredUser,
  writeSessionTokens,
} from '../../shared/session/storage';

interface AuthState {
  accessToken: string | null;
  refreshToken: string | null;
  user: StoredUser | null;
  isBootstrapped: boolean;
  setSession: (session: {
    accessToken: string | null;
    refreshToken: string | null;
    user: StoredUser | null;
  }) => void;
  updateTokens: (accessToken: string, refreshToken: string) => void;
  setBootstrapped: (isBootstrapped: boolean) => void;
  logout: () => void;
}

const storedSession = readSessionTokens();

export const useAuthStore = create<AuthState>((set, get) => ({
  ...storedSession,
  isBootstrapped: false,
  setSession: (session) => {
    writeSessionTokens(session);
    set(session);
  },
  updateTokens: (accessToken, refreshToken) => {
    const nextSession = { ...get(), accessToken, refreshToken };
    writeSessionTokens({
      accessToken,
      refreshToken,
      user: nextSession.user,
    });
    set({ accessToken, refreshToken });
  },
  setBootstrapped: (isBootstrapped) => set({ isBootstrapped }),
  logout: () => {
    clearSessionTokens();
    set({ accessToken: null, refreshToken: null, user: null });
  },
}));

export function canUseAdmin(user: StoredUser | null) {
  return user?.role === 'AGENT' || user?.role === 'ADMIN';
}
