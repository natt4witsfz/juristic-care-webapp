import type { HousekeepingRoutineRepository } from './housekeeping_repository';

/**
 * Future adapter seam only. The functional mockup intentionally does not import a
 * Supabase client, read environment variables, call a database, or modify schema.
 */
export type SupabaseHousekeepingRoutineRepository = HousekeepingRoutineRepository;
