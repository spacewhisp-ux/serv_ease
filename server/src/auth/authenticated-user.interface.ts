export interface AuthenticatedUser {
  id: string;
  email: string | null;
  phone: string | null;
  displayName: string;
  avatarUrl: string | null;
  role: string;
  status: string;
}
