# Barbershop Booking App

Gestión de turnos online para una barbería: el cliente elige servicio, profesional y horario; el
dueño administra todo desde `/admin`.

> Personalizar para un cliente nuevo = editar `src/config/site.config.ts` (datos del negocio) y
> `src/app/globals.css` (paleta y tipografía).

---

## Stack

Un solo lenguaje en todo el proyecto: **TypeScript**.

| Capa            | Elección                                          | Por qué                                                                                                                             |
| --------------- | ------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Front + back    | **Next.js 16** (App Router, React 19)             | El "back" vive en Server Components, Server Actions y Route Handlers. Para un proyecto chico no hace falta mantener una API aparte. |
| Base de datos   | **Supabase** (Postgres 17)                        | SQL real, Row Level Security, y un _exclusion constraint_ que impide a nivel base que un profesional tenga dos turnos superpuestos. |
| Auth / Storage  | **Supabase Auth + Storage**                       | Login del admin y fotos (servicios, staff, galería) sin servicios extra.                                                            |
| Estilos         | **Tailwind CSS v4**                               | Design tokens en `globals.css` (`@theme`), sin archivo de config JS.                                                                |
| Formularios     | react-hook-form · date-fns                        | Formularios livianos y manejo de fechas/slots.                                                                                      |
| Calidad         | ESLint 10 · Prettier · TS strict · GitHub Actions | `pnpm check` local y CI en cada PR.                                                                                                 |
| Runtime / tools | **Node 24 LTS** · **pnpm 11**                     | Node 24 es el LTS activo. pnpm rápido y estricto con dependencias.                                                                  |

**Versiones que NO están en la última a propósito:**

- **TypeScript 6.0** (no 7): `typescript-eslint` todavía no soporta TS 7. Subir cuando lo soporte.
- **pnpm 11** (no 12): Vercel todavía no detecta pnpm 11+ solo; con 11 alcanza con la variable
  `ENABLE_EXPERIMENTAL_COREPACK=1` (ver [Deploy](#deploy)).

## Hosting

| Servicio                         | Para qué                                                           | Plan para arrancar                                                                                        |
| -------------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| [GitHub](https://github.com)     | Repo + CI (GitHub Actions)                                         | Free                                                                                                      |
| [Vercel](https://vercel.com)     | Hosting de Next.js. Deploy automático en cada push, preview por PR | Hobby (gratis, **uso no comercial**). Si se le cobra al cliente → Pro.                                    |
| [Supabase](https://supabase.com) | Postgres + Auth + Storage                                          | Free. Ojo: un proyecto free se **pausa tras ~1 semana sin actividad**; para producción real conviene Pro. |

Región sugerida para ambos: **São Paulo** (Supabase `sa-east-1`, Vercel `gru1`), la más cercana a
Argentina.

---

## Requisitos

- **Git**
- **Node 24 LTS** — la versión está en `.nvmrc` (`nvm use` / `fnm use`; en Windows,
  [nvm-windows](https://github.com/coreybutler/nvm-windows)).
- **pnpm 11** — viene con Node vía Corepack: `corepack enable` (toma la versión exacta de
  `package.json`).
- **Docker Desktop** — sólo si querés correr Supabase local (recomendado). Si no, usá un proyecto
  Supabase cloud de desarrollo.
- **VS Code** — al abrir el repo te sugiere las extensiones (ESLint, Prettier, Tailwind, Supabase).
  Formatea al guardar.

## Primer setup

```bash
git clone https://github.com/jackness11/barbershop-booking-app.git
cd barbershop-booking-app
corepack enable
pnpm install
cp .env.example .env.local
```

### Opción A — Supabase local (Docker)

```bash
pnpm db:start   # levanta Postgres + Auth + Studio; imprime URL y keys
pnpm db:reset   # aplica supabase/migrations + supabase/seed.sql (datos de ejemplo)
```

Copiá **Project URL** y la key **Publishable** que imprime `db:start` a `.env.local`.

- Studio (admin de la base): http://127.0.0.1:54323
- Crear el usuario admin: Studio → Authentication → Add user.

### Opción B — Supabase cloud

```bash
pnpm exec supabase login
pnpm exec supabase link --project-ref <tu-project-ref>
pnpm db:push           # aplica las migrations al proyecto remoto
pnpm db:types:remote   # regenera los tipos desde el proyecto remoto
```

Completá `.env.local` con Dashboard → Project Settings → API Keys.

### Levantar la app

```bash
pnpm dev   # http://localhost:3000
```

## Scripts

| Script                 | Qué hace                                                   |
| ---------------------- | ---------------------------------------------------------- |
| `pnpm dev`             | Servidor de desarrollo                                     |
| `pnpm build` / `start` | Build de producción / servirlo                             |
| `pnpm check`           | lint + typecheck + formato (lo mismo que corre el CI)      |
| `pnpm lint`            | ESLint                                                     |
| `pnpm typecheck`       | `tsc --noEmit`                                             |
| `pnpm format`          | Prettier sobre todo el repo                                |
| `pnpm db:start/stop`   | Supabase local on/off                                      |
| `pnpm db:reset`        | Recrea la base local: migrations + seed                    |
| `pnpm db:push`         | Aplica migrations al proyecto Supabase linkeado            |
| `pnpm db:types`        | Regenera `src/types/database.types.ts` desde la base local |
| `pnpm db:types:remote` | Ídem, desde el proyecto linkeado                           |

Cambios de schema: nueva migration con `pnpm exec supabase migration new <nombre>`, `pnpm db:reset`
para probarla y `pnpm db:types` para actualizar los tipos.

---

## Flujo de trabajo con Git

Configuración inicial (una sola vez por máquina):

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-mail@ejemplo.com"
```

Para autenticarte con GitHub, lo más simple es [GitHub CLI](https://cli.github.com/)
(`gh auth login`) o una [clave SSH](https://docs.github.com/es/authentication/connecting-to-github-with-ssh).

Ramas:

| Rama                         | Uso                                                        |
| ---------------------------- | ---------------------------------------------------------- |
| `main`                       | Producción. Cada push deploya a Vercel.                    |
| `development`                | Integración. Se mergea a `main` cuando está estable.       |
| `feat/*`, `fix/*`, `chore/*` | Una rama por tarea, sale de `development` y vuelve por PR. |

```bash
git switch development && git pull
git switch -c feat/listado-servicios
# ...cambios...
pnpm check
git commit -m "feat: listado de servicios en la home"
git push -u origin feat/listado-servicios   # y abrir PR contra development
```

Mensajes de commit con [Conventional Commits](https://www.conventionalcommits.org/es/):
`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`.

---

## Deploy

### 1. Supabase (producción)

1. Crear el proyecto en [supabase.com](https://supabase.com) (región São Paulo).
2. **Authentication → Sign In / Providers → desactivar "Allow new users to sign up"**. Las policies
   RLS tratan a todo usuario logueado como admin, así que nadie tiene que poder registrarse solo.
3. Crear el usuario admin a mano: Authentication → Users → Add user.
4. `pnpm exec supabase link --project-ref <ref>` y `pnpm db:push`.

### 2. Vercel

1. Add New → Project → importar `jackness11/barbershop-booking-app` desde GitHub. Detecta Next.js
   solo.
2. Environment Variables:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
   - `ENABLE_EXPERIMENTAL_COREPACK` = `1` (para que use el pnpm de `packageManager`)
3. Settings → Functions → Region: `gru1` (São Paulo), cerca de la base.
4. Deploy. Después: push a `main` → producción; cada PR → URL de preview.
5. En Supabase → Authentication → URL Configuration, poner la URL de Vercel como **Site URL**.

---

## Estructura

```
src/
  app/                 rutas (App Router), layout y estilos globales
  config/site.config.ts  datos del negocio (nombre, contacto, horarios, reglas de booking)
  lib/supabase/        clientes de Supabase (browser, server, proxy)
  proxy.ts             refresca la sesión y protege /admin
  types/               tipos generados de la base
supabase/
  migrations/          schema versionado (tablas, RLS, constraint anti-superposición)
  seed.sql             datos de ejemplo para desarrollo local
  config.toml          configuración de Supabase local
```
