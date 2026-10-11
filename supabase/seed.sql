-- =============================================================================
-- Datos de ejemplo para desarrollo local.
-- Se cargan solos en `pnpm db:reset` (supabase/config.toml → [db.seed]).
-- NO se aplican en producción (`supabase db push` sólo corre migrations).
-- =============================================================================

insert into public.categories (name, slug, sort_order) values
  ('Cortes', 'cortes', 1),
  ('Barba',  'barba',  2),
  ('Color',  'color',  3);

insert into public.services (name, description, category_id, duration_minutes, price, sort_order)
select v.name, v.description, c.id, v.duration_minutes, v.price, v.sort_order
from (values
  ('Corte clásico',      'Corte a tijera y máquina.',          'cortes', 30, 12000, 1),
  ('Corte + lavado',     'Corte con lavado y peinado.',        'cortes', 45, 15000, 2),
  ('Perfilado de barba', 'Perfilado con navaja y toalla.',     'barba',  30,  8000, 3),
  ('Corte + barba',      'Combo corte clásico y barba.',       'barba',  60, 18000, 4),
  ('Color completo',     'Coloración completa con producto.',  'color',  90, 30000, 5)
) as v(name, description, slug, duration_minutes, price, sort_order)
join public.categories c on c.slug = v.slug;

insert into public.staff (name, bio, sort_order) values
  ('Leo',   'Fundador. Especialista en cortes clásicos.', 1),
  ('Mati',  'Barba y fades.',                             2);

-- Leo hace todo; Mati sólo cortes y barba.
insert into public.staff_services (staff_id, service_id)
select s.id, sv.id
from public.staff s
join public.services sv on true
join public.categories c on c.id = sv.category_id
where s.name = 'Leo'
   or (s.name = 'Mati' and c.slug in ('cortes', 'barba'));

-- Lunes a viernes 09–13 y 14–20; sábado 09–18 (0 = domingo).
insert into public.staff_schedules (staff_id, day_of_week, start_time, end_time)
select s.id, d.day, t.start_time, t.end_time
from public.staff s
cross join generate_series(1, 5) as d(day)
cross join (values ('09:00'::time, '13:00'::time), ('14:00'::time, '20:00'::time)) as t(start_time, end_time)
union all
select s.id, 6, '09:00', '18:00'
from public.staff s;
