import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

import { supabaseDomainGateway } from './gateway';
import type {
  CommandParameters,
  CreateCaseInput,
  DomainGateway,
  EvidenceUploadInput,
} from './types';

export const dashboardQueryKey = ['workspace-dashboard'] as const;
export const projectionQueryKey = (view: string) => ['domain-projection', view] as const;

export function useDashboard(gateway: DomainGateway = supabaseDomainGateway) {
  return useQuery({ queryKey: dashboardQueryKey, queryFn: () => gateway.loadDashboard() });
}

export function useProjection(view: string, gateway: DomainGateway = supabaseDomainGateway) {
  return useQuery({
    queryKey: projectionQueryKey(view),
    queryFn: () => gateway.loadProjection(view),
  });
}

function useRefreshAfterMutation() {
  const queryClient = useQueryClient();
  return () => queryClient.invalidateQueries();
}

export function useDomainCommand(command: string, gateway: DomainGateway = supabaseDomainGateway) {
  const refresh = useRefreshAfterMutation();
  return useMutation({
    mutationFn: (parameters: CommandParameters) => gateway.execute(command, parameters),
    onSuccess: refresh,
  });
}

export function useTrustedWorkflow(name: string, gateway: DomainGateway = supabaseDomainGateway) {
  const refresh = useRefreshAfterMutation();
  return useMutation({
    mutationFn: (body: CommandParameters) => gateway.invokeTrustedWorkflow(name, body),
    onSuccess: refresh,
  });
}

export function useCreateCase(gateway: DomainGateway = supabaseDomainGateway) {
  const refresh = useRefreshAfterMutation();
  return useMutation({
    mutationFn: (input: CreateCaseInput) => gateway.createCase(input),
    onSuccess: refresh,
  });
}

export function useCreateInvestigation(gateway: DomainGateway = supabaseDomainGateway) {
  const refresh = useRefreshAfterMutation();
  return useMutation({
    mutationFn: (input: { juristicPersonId: string; caseId: string; question: string }) =>
      gateway.createInvestigation(input.juristicPersonId, input.caseId, input.question),
    onSuccess: refresh,
  });
}

export function useEvidenceUpload(gateway: DomainGateway = supabaseDomainGateway) {
  const refresh = useRefreshAfterMutation();
  return useMutation({
    mutationFn: (input: EvidenceUploadInput) => gateway.uploadEvidence(input),
    onSuccess: refresh,
  });
}
