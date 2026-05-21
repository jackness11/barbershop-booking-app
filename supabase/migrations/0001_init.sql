-- =============================================================================
-- barbershop-booking-app · initial schema
-- =============================================================================
-- Single-tenant: cada peluquería corre su propio proyecto Supabase.
-- Public role (anon) lee catálogo y crea turnos; admin (authenticated) gestiona.
-- =============================================================================

-- btree_gist es necesario para combinar igualdad (staff_id) con && (tstzrange)
-- en el exclusion constraint de appointments.
create extension if not exists "btree_gist";

-- -----------------------------------------------------------------------------
-- Helpers
-- -----------------------------------------------------------------------------

-- Trigger genérico para mantener updated_at al día.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- categories
-- -----------------------------------------------------------------------------
-- ABM completo desde el panel admin. slug se usa en URLs/filtros del front.
create table public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  slug        text not null unique,
  sort_order  int  not null default 0,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index categories_active_idx on public.categories (active) where active = true;
create index categories_sort_idx   on public.categories (sort_order);

create trigger categories_set_updated_at
before update on public.categories
for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- services
-- -----------------------------------------------------------------------------
-- category_id → categories. RESTRICT al borrar: no se puede borrar una categoría
-- con servicios asociados; el admin debe reasignar o desactivar primero.
create table public.services (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  description      text,
  category_id      uuid not null references public.categories(id) on delete restrict,
  duration_minutes int  not null check (duration_minutes > 0),
  price            numeric(10,2) not null check (price >= 0),
  image_url        text,
  active           boolean not null default true,
  sort_order       int not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index services_active_idx      on public.services (active) where active = true;
create index services_category_id_idx on public.services (category_id);
create index services_sort_idx        on public.services (sort_order);

create trigger services_set_updated_at
before update on public.services
for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- staff
-- -----------------------------------------------------------------------------
create table public.staff (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  bio         text,
  photo_url   text,
  active      boolean not null default true,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index staff_active_idx on public.staff (active) where active = true;
create index staff_sort_idx   on public.staff (sort_order);

create trigger staff_set_updated_at
before update on public.staff
for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- staff_services (M2M)
-- -----------------------------------------------------------------------------
-- Qué servicios ofrece cada profesional. Sin updated_at: la relación se borra y recrea.
create table public.staff_services (
  staff_id   uuid not null references public.staff(id)    on delete cascade,
  service_id uuid not null references public.services(id) on delete restrict,
  primary key (staff_id, service_id)
);

create index staff_services_service_idx on public.staff_services (service_id);

-- -----------------------------------------------------------------------------
-- staff_schedules
-- -----------------------------------------------------------------------------
-- Horario semanal recurrente por profesional. Permite múltiples franjas por día
-- (ej. 09-13 y 16-20) — por eso la UNIQUE incluye start_time.
create table public.staff_schedules (
  id          uuid primary key default gen_random_uuid(),
  staff_id    uuid not null references public.staff(id) on delete cascade,
  day_of_week smallint not null check (day_of_week between 0 and 6),  -- 0=domingo
  start_time  time not null,
  end_time    time not null,
  created_at  timestamptz not null default now(),
  check (start_time < end_time),
  unique (staff_id, day_of_week, start_time)
);

create index staff_schedules_staff_day_idx on public.staff_schedules (staff_id, day_of_week);

-- -----------------------------------------------------------------------------
-- blocked_slots
-- -----------------------------------------------------------------------------
-- Bloqueos puntuales (vacaciones, feriado, hora libre).
-- staff_id NULL = bloqueo global (toda la peluquería).
create table public.blocked_slots (
  id         uuid primary key default gen_random_uuid(),
  staff_id   uuid references public.staff(id) on delete cascade,
  from_at    timestamptz not null,
  to_at      timestamptz not null,
  reason     text,
  created_at timestamptz not null default now(),
  check (from_at < to_at)
);

create index blocked_slots_range_idx on public.blocked_slots using gist (tstzrange(from_at, to_at, '[)'));
create index blocked_slots_staff_idx on public.blocked_slots (staff_id);

-- -----------------------------------------------------------------------------
-- appointments
-- -----------------------------------------------------------------------------
-- end_at se calcula en la app (start_at + service.duration_minutes) y se guarda
-- explícito para que el exclusion constraint sea barato y no requiera join.
create table public.appointments (
  id             uuid primary key default gen_random_uuid(),
  service_id     uuid not null references public.services(id) on delete restrict,
  staff_id       uuid not null references public.staff(id)    on delete restrict,
  customer_name  text not null,
  customer_phone text not null,
  customer_email text,
  start_at       timestamptz not null,
  end_at         timestamptz not null,
  status         text not null default 'pending'
                   check (status in ('pending', 'confirmed', 'cancelled', 'completed')),
  notes          text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  check (start_at < end_at),

  -- Última línea de defensa contra doble reserva del mismo profesional.
  -- Los turnos cancelled no participan (un cancelado no debe bloquear).
  constraint appointments_no_overlap exclude using gist (
    staff_id with =,
    tstzrange(start_at, end_at, '[)') with &&
  ) where (status <> 'cancelled')
);

create index appointments_staff_start_idx on public.appointments (staff_id, start_at);
create index appointments_status_idx      on public.appointments (status);
create index appointments_start_idx       on public.appointments (start_at);

create trigger appointments_set_updated_at
before update on public.appointments
for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- products
-- -----------------------------------------------------------------------------
create table public.products (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text,
  price       numeric(10,2) not null check (price >= 0),
  image_url   text,
  active      boolean not null default true,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index products_active_idx on public.products (active) where active = true;
create index products_sort_idx   on public.products (sort_order);

create trigger products_set_updated_at
before update on public.products
for each row execute function public.set_updated_at();

-- -----------------------------------------------------------------------------
-- gallery
-- -----------------------------------------------------------------------------
create table public.gallery (
  id          uuid primary key default gen_random_uuid(),
  image_url   text not null,
  caption     text,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);

create index gallery_sort_idx on public.gallery (sort_order);

-- =============================================================================
-- Row Level Security
-- =============================================================================
-- Modelo:
--   anon (público):           lee catálogo activo + crea appointments
--   authenticated (admin):    lectura/escritura total
-- =============================================================================

alter table public.categories      enable row level security;
alter table public.services        enable row level security;
alter table public.staff           enable row level security;
alter table public.staff_services  enable row level security;
alter table public.staff_schedules enable row level security;
alter table public.blocked_slots   enable row level security;
alter table public.appointments    enable row level security;
alter table public.products        enable row level security;
alter table public.gallery         enable row level security;

-- categories -------------------------------------------------------------------
create policy "categories public read active"
  on public.categories for select to anon
  using (active = true);

create policy "categories admin all"
  on public.categories for all to authenticated
  using (true) with check (true);

-- services ---------------------------------------------------------------------
create policy "services public read active"
  on public.services for select to anon
  using (active = true);

create policy "services admin all"
  on public.services for all to authenticated
  using (true) with check (true);

-- staff ------------------------------------------------------------------------
create policy "staff public read active"
  on public.staff for select to anon
  using (active = true);

create policy "staff admin all"
  on public.staff for all to authenticated
  using (true) with check (true);

-- staff_services ---------------------------------------------------------------
create policy "staff_services public read"
  on public.staff_services for select to anon
  using (true);

create policy "staff_services admin all"
  on public.staff_services for all to authenticated
  using (true) with check (true);

-- staff_schedules --------------------------------------------------------------
create policy "staff_schedules public read"
  on public.staff_schedules for select to anon
  using (true);

create policy "staff_schedules admin all"
  on public.staff_schedules for all to authenticated
  using (true) with check (true);

-- blocked_slots ----------------------------------------------------------------
-- Lectura pública para que el front pueda calcular disponibilidad sin auth.
create policy "blocked_slots public read"
  on public.blocked_slots for select to anon
  using (true);

create policy "blocked_slots admin all"
  on public.blocked_slots for all to authenticated
  using (true) with check (true);

-- appointments -----------------------------------------------------------------
-- El cliente NO ve turnos ajenos; sólo puede insertar.
create policy "appointments public insert"
  on public.appointments for insert to anon
  with check (status = 'pending');

create policy "appointments admin all"
  on public.appointments for all to authenticated
  using (true) with check (true);

-- products ---------------------------------------------------------------------
create policy "products public read active"
  on public.products for select to anon
  using (active = true);

create policy "products admin all"
  on public.products for all to authenticated
  using (true) with check (true);

-- gallery ----------------------------------------------------------------------
create policy "gallery public read"
  on public.gallery for select to anon
  using (true);

create policy "gallery admin all"
  on public.gallery for all to authenticated
  using (true) with check (true);
