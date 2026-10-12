# Guía de instalación — Barbershop Booking App

Todo lo que hay que instalar para trabajar en el proyecto, en orden. Está pensada para **Windows**
(al final hay una nota para Mac/Linux).

## Resumen

| #   | Programa       | Versión    | ¿Obligatorio?    | Dónde se baja                                  |
| --- | -------------- | ---------- | ---------------- | ---------------------------------------------- |
| 1   | Git            | la última  | Sí               | https://git-scm.com/download/win               |
| 2   | Node.js        | **24 LTS** | Sí               | https://nodejs.org                             |
| 3   | pnpm           | **11**     | Sí               | Se instala con npm (viene con Node)            |
| 4   | VS Code        | la última  | Sí (recomendado) | https://code.visualstudio.com                  |
| 5   | Docker Desktop | la última  | Opcional         | https://www.docker.com/products/docker-desktop |
| 6   | GitHub CLI     | la última  | Opcional         | https://cli.github.com                         |

> Para los comandos usá **PowerShell** (Inicio → escribir "PowerShell"). Cuando diga **"como
> administrador"**: clic derecho sobre PowerShell → _Ejecutar como administrador_.
>
> Después de instalar cada programa, **cerrá y volvé a abrir la terminal** para que lo reconozca.

---

## 1. Git

Sirve para bajar el código, guardar cambios y subirlos a GitHub.

1. Entrá a https://git-scm.com/download/win y bajá el instalador de 64 bits.
2. Instalá con las opciones por defecto. Si te pregunta el editor por defecto, elegí **Visual Studio
   Code**.
3. Configurá tu nombre y mail (usá el **mismo mail de tu cuenta de GitHub**):

   ```powershell
   git config --global user.name "Nombre Apellido"
   git config --global user.email "tu-mail@ejemplo.com"
   ```

4. Verificá:

   ```powershell
   git --version
   ```

Git para Windows ya trae el gestor de credenciales: la primera vez que hagas `git clone` o
`git push` se abre el navegador para que te loguees en GitHub.

## 2. Node.js 24 LTS

Es el entorno que corre el proyecto (Next.js) y trae `npm`.

1. Entrá a https://nodejs.org y bajá la versión **LTS (24.x)** → _Windows Installer (.msi)_.
2. Instalá con las opciones por defecto. La casilla _"Tools for Native Modules"_ dejala **sin
   marcar** (no hace falta).
3. Si ya tenías otra versión de Node, el instalador la reemplaza.
4. Verificá (tiene que decir `v24.x.x`):

   ```powershell
   node -v
   ```

## 3. pnpm 11

Es el gestor de paquetes del proyecto (reemplaza a `npm install`).

1. En PowerShell **como administrador**:

   ```powershell
   npm install -g pnpm@11
   ```

2. Cerrá la terminal, abrí una nueva y verificá (tiene que decir `11.x.x`):

   ```powershell
   pnpm -v
   ```

> **No uses `corepack enable`.** La versión de Corepack que viene con Node no puede arrancar pnpm
> 12 y falla con `Cannot find module ...pnpm.cjs`. Si ya lo habías activado, mirá
> [Problemas comunes](#problemas-comunes).

## 4. VS Code

El editor de código.

1. Bajalo de https://code.visualstudio.com.
2. En la instalación marcá **"Agregar a PATH"** y las dos opciones de **"Abrir con Code"** (menú
   del clic derecho).
3. Cuando abras el proyecto por primera vez, abajo a la derecha aparece un aviso de **extensiones
   recomendadas** → _Instalar todas_. Son:
   - ESLint
   - Prettier
   - Tailwind CSS IntelliSense
   - Supabase
4. La terminal integrada se abre desde el menú **Terminal → Nueva terminal**.

El proyecto ya viene configurado para que el código se formatee solo al guardar.

## 5. Docker Desktop (opcional)

Solo hace falta para levantar la base de datos (Supabase) **en tu propia compu**. Si no lo
instalás, se puede usar un proyecto de Supabase en la nube compartido para desarrollo.

1. Bajalo de https://www.docker.com/products/docker-desktop.
2. Te va a pedir **WSL2**. Si no lo tenés, en PowerShell **como administrador**:

   ```powershell
   wsl --install
   ```

   y reiniciá la compu.

3. Verificá:

   ```powershell
   docker -v
   ```

Docker Desktop tiene que estar **abierto** cada vez que levantes la base local (`pnpm db:start`).

## 6. GitHub CLI (opcional)

Facilita loguearse en GitHub y abrir Pull Requests desde la terminal.

```powershell
winget install --id GitHub.cli
gh auth login
```

En `gh auth login` elegí: _GitHub.com_ → _HTTPS_ → _Login with a web browser_.

---

## Cuentas

| Servicio                         | ¿Quién?    | Qué hacer                                                                                               |
| -------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------- |
| [GitHub](https://github.com)     | Los dos    | Crear cuenta. El dueño del repo te agrega en _Settings → Collaborators_; aceptá la invitación del mail. |
| [Supabase](https://supabase.com) | Los dos    | Crear cuenta. El dueño del proyecto te invita a la organización (_Organization settings → Team_).       |
| [Vercel](https://vercel.com)     | Solo dueño | No hace falta para el compañero: los deploys salen solos desde GitHub.                                  |

---

## Bajar el proyecto y levantarlo

> **No clones dentro de Documentos ni del Escritorio.** Si están sincronizados con OneDrive o
> protegidos por Windows Defender, `git clone` falla (`could not create work tree dir`) y OneDrive
> se traba sincronizando `node_modules`. Usá una carpeta propia, como `proyectos`.

```powershell
mkdir $HOME\proyectos
cd $HOME\proyectos
git clone https://github.com/jackness11/barbershop-booking-app.git
cd barbershop-booking-app
pnpm install
copy .env.example .env.local
code .
```

Completá `.env.local` con las claves de Supabase:

- **Base en la nube compartida:** pedíselas al dueño del proyecto. **No se suben a GitHub** ni se
  mandan por canales públicos.
- **Base local (con Docker):** corré `pnpm db:start`, copiá _Project URL_ y _Publishable key_ que
  aparecen en la consola, y después `pnpm db:reset` para cargar los datos de ejemplo.

Levantá la app:

```powershell
pnpm dev
```

Abrí http://localhost:3000: tiene que aparecer el nombre de la barbería y los horarios.

---

## Checklist final

```powershell
git --version   # git version 2.x
node -v         # v24.x.x
pnpm -v         # 11.x.x
docker -v       # solo si instalaste Docker
```

---

## Problemas comunes

**`git` no se reconoce... (pero Git está instalado)**
Git no quedó en el PATH. En una PowerShell **normal** (no como administrador: si no, puede quedar
configurado para otro usuario de Windows):

```powershell
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";C:\Program Files\Git\cmd", "User")
```

Cerrá la terminal, abrí una nueva y probá `git --version`.

**`fatal: could not create work tree dir ...`**
Estás clonando dentro de Documentos o del Escritorio (OneDrive / Windows Defender lo bloquean).
Cloná en `$HOME\proyectos` como en [Bajar el proyecto](#bajar-el-proyecto-y-levantarlo).

**Lo instalé como administrador y en la terminal normal no anda**
Si el administrador es otro usuario de Windows, lo instalado con `npm install -g` queda para ese
usuario. Repetí el comando en la terminal normal.

**`pnpm` no se reconoce como nombre de un cmdlet...**
Cerrá **todas** las terminales (y VS Code) y abrí una nueva. Si sigue, reinstalá:
`npm install -g pnpm@11`.

**`la ejecución de scripts está deshabilitada en este sistema`**
Restricción de PowerShell. Corré una sola vez y reabrí la terminal:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**`Cannot find module ...\corepack\...\pnpm\12...\bin\pnpm.cjs`**
Quedó activado Corepack con pnpm 12. En PowerShell **como administrador**:

```powershell
corepack disable
npm install -g pnpm@11
Remove-Item -Recurse -Force $env:LOCALAPPDATA\node\corepack
```

Si Corepack había agregado una línea `"packageManager": "pnpm@12..."` a algún `package.json`
**fuera** del proyecto (por ejemplo `C:\Users\<usuario>\package.json`), borrá esa línea.
El `package.json` **del proyecto** sí tiene que tener su línea `packageManager` con pnpm 11: esa no
se toca.

**`node -v` sigue mostrando una versión vieja**
Cerrá todas las terminales. Si usás `nvm-windows`: `nvm install 24` y `nvm use 24`.

**Corrí `pnpm` y quiere descargar otra versión**
Corré los comandos de pnpm siempre **dentro** de la carpeta `barbershop-booking-app`.

---

## Mac / Linux

Mismos programas, cambia cómo se instalan:

- **Git:** en Mac viene con `xcode-select --install`; en Linux, con el gestor de paquetes
  (`sudo apt install git`).
- **Node 24:** instalador de https://nodejs.org, o `brew install node@24` en Mac.
- **pnpm:** `npm install -g pnpm@11` (en Mac/Linux puede necesitar `sudo`).
- **Docker Desktop:** https://www.docker.com/products/docker-desktop (en Mac no hace falta WSL).
