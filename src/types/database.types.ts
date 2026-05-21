/**
 * Generado por `pnpm db:types` desde el schema de Supabase.
 *
 * Este archivo es un PLACEHOLDER mientras no haya proyecto Supabase conectado.
 * Cuando esté el proyecto:
 *   1. Linkearlo: `supabase link --project-ref <ref>`
 *   2. Aplicar migrations: `supabase db push`
 *   3. Regenerar tipos: `pnpm db:types`
 */
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export interface Database {
  public: {
    Tables: Record<string, never>;
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
}
