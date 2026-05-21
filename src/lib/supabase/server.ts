/**
 * Supabase client para Server Components, Server Actions y Route Handlers.
 * En Next 16 cookies() es async — por eso createClient también lo es.
 *
 * Uso típico en Server Component:
 *   const supabase = await createClient();
 *   const { data } = await supabase.from('services').select();
 */
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import type { Database } from '@/types/database.types';

export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) => {
              cookieStore.set(name, value, options);
            });
          } catch {
            // setAll desde un Server Component (no Route Handler / Server Action)
            // falla porque cookies() ahí es read-only. Lo ignoramos: el middleware
            // refresca la sesión en cada request, así que esta vía no es crítica.
          }
        },
      },
    },
  );
}
