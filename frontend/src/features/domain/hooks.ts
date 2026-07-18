import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

import { supabaseDomainGateway } from './gateway';
import type { CreateCaseInput, DomainGateway } from './types';

export const dashboardQueryKey = ['workspace-dashboard'] as const;

export function useDashboard(gateway: DomainGateway = supabaseDomainGateway) {
  return useQuery({ queryKey: dashboardQueryKey, queryFn: () => gateway.loadDashboard() });
}

export function useCreateCase(gateway: DomainGateway = supabaseDomainGateway) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateCaseInput) => gateway.createCase(input),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: dashboardQueryKey }),
  });
}

export function useCreateInvestigation(gateway: DomainGateway = supabaseDomainGateway) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: { juristicPersonId: string; caseId: string; question: string }) =>
      gateway.createInvestigation(input.juristicPersonId, input.caseId, input.question),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: dashboardQueryKey }),
  });
}
