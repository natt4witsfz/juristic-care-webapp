export type O83Role =
  | 'admin'
  | 'committee'
  | 'juristic_manager'
  | 'juristic_staff'
  | 'head_technician'
  | 'technician'
  | 'resident'
  | 'vendor'
  | 'security'
  | 'housekeeping'
  | 'auditor'
  | 'ai_service';

export interface AuthUser {
  readonly id: string;
  readonly email: string | null;
}

export interface AccessContext {
  readonly juristicPersonId: string;
  readonly personId: string;
  readonly displayName: string;
  readonly roles: readonly O83Role[];
  readonly permissions: readonly string[];
}

export interface AuthSnapshot {
  readonly user: AuthUser | null;
  readonly access: AccessContext | null;
}

export interface AuthGateway {
  getSnapshot(): Promise<AuthSnapshot>;
  subscribe(listener: (snapshot: AuthSnapshot) => void): () => void;
  signIn(email: string, password: string): Promise<void>;
  signOut(): Promise<void>;
  requestPasswordReset(email: string, redirectTo: string): Promise<void>;
  updatePassword(password: string): Promise<void>;
}
