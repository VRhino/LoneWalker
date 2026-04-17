# 🚀 Guía de Setup Local - LoneWalker

**Estado del Proyecto**: Phase 3 (Maps & Exploration System)  
**Última Actualización**: Abril 2026  
**Documentación**: Completa ✅

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Quick Start (5 minutos)](#quick-start)
3. [Setup Detallado](#setup-detallado)
4. [Backend NestJS](#backend-nestjs)
5. [Frontend Flutter](#frontend-flutter)
6. [Base de Datos](#base-de-datos)
7. [Servicios Externos](#servicios-externos)
8. [Verificación de Setup](#verificación-de-setup)
9. [Troubleshooting](#troubleshooting)
10. [Comandos Útiles](#comandos-útiles)

---

## ⚙️ Requisitos Previos

### Sistema Operativo
- **macOS 11+** / **Ubuntu 20.04+** / **Windows 10+ con WSL2**
- Terminal/Shell (Bash, Zsh)
- ~20GB de espacio libre en disco

### Software Obligatorio

| Software | Versión Mínima | Propósito |
|----------|----------------|-----------|
| Git | 2.30+ | Control de versiones |
| Docker | 20.10+ | Servicios (PostgreSQL, Redis) |
| Docker Compose | 2.0+ | Orquestación de servicios |
| Node.js | 18.16+ | Runtime backend |
| npm | 9.0+ | Package manager backend |
| Flutter | 3.16+ | Framework mobile |
| Dart | 3.1+ | Lenguaje Flutter |
| PostgreSQL CLI | 14+ | Herramientas de BD (opcional) |

### Verificar Instalaciones
```bash
# Node.js y npm
node --version    # v18.16.0 o superior
npm --version     # 9.0.0 o superior

# Flutter y Dart
flutter --version # Flutter 3.16.0 o superior
dart --version    # Dart 3.1.0 o superior

# Docker
docker --version  # 20.10+ 
docker-compose --version  # 2.0+

# Git
git --version     # 2.30+
```

### Cuentas Necesarias
- ✅ **GitHub**: Para clonar repo (puede ser pública)
- ✅ **Google Cloud Console**: Para Google Maps API key
  - Habilitar: Maps JavaScript API, Maps Static API
- ✅ **Firebase Console**: Para autenticación (opcional para desarrollo local)

---

## 🏃 Quick Start (5 minutos)

**Para los impacientes:**

```bash
# 1. Clonar repositorio
git clone https://github.com/vrhino/lonewalker.git
cd lonewalker

# 2. Instalar dependencias
./scripts/setup.sh  # Linux/Mac
# O manualmente:
cd backend && npm install && cd ../frontend && flutter pub get && cd ..

# 3. Levantar servicios Docker
docker-compose up -d postgres redis pgadmin

# 4. Configurar variables de entorno
cp .env.example .env
# Editar .env con valores reales (especialmente GOOGLE_MAPS_API_KEY)

# 5. Ejecutar backend
cd backend && npm run start:dev

# 6. En otra terminal, ejecutar frontend
cd frontend && flutter run

# ✅ ¡Listo! Backend en http://localhost:3000, frontend en emulador/dispositivo
```

**Nota**: Esto asume que ya tienes Google Maps API key. Si no, ver sección [Google Maps Setup](#google-maps-setup).

---

## 🔧 Setup Detallado

### Paso 1: Clonar el Repositorio

```bash
# HTTPS
git clone https://github.com/vrhino/lonewalker.git
cd lonewalker

# O SSH (si tienes clave SSH configurada)
git clone git@github.com:vrhino/lonewalker.git
cd lonewalker

# Verificar rama
git branch          # Debe mostrar "main" o rama actual
git status          # Debe estar limpio
```

### Paso 2: Instalar Node.js (Backend)

**macOS con Homebrew**:
```bash
brew install node@18
node --version  # Verificar: v18.16.0 o superior
```

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install -y nodejs npm
node --version  # Verificar: v18.16.0 o superior
```

**Windows (WSL2)**:
```bash
# En WSL terminal
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Verificar npm**:
```bash
npm --version  # 9.0.0 o superior
npm install -g npm@latest  # Actualizar si es necesario
```

### Paso 3: Instalar Flutter

**macOS**:
```bash
# Descargar desde https://flutter.dev/docs/get-started/install/macos
# O con Homebrew
brew install flutter

# Configurar PATH en ~/.zshrc o ~/.bash_profile
export PATH="$PATH:$HOME/development/flutter/bin"

# Verificar
flutter --version
```

**Ubuntu/Debian**:
```bash
# Descargar desde https://flutter.dev/docs/get-started/install/linux
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz

# Agregar PATH a ~/.bashrc
export PATH="$PATH:$HOME/development/flutter/bin"

source ~/.bashrc
flutter --version
```

**Windows (WSL2)**:
```bash
# En WSL terminal
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
export PATH="$PATH:$HOME/development/flutter/bin"
```

**Ejecutar Flutter Doctor**:
```bash
flutter doctor
# Checklist que debe mostrar:
# ✓ Flutter (Channel stable)
# ✓ Dart SDK
# ✓ Android toolchain (para desarrollo Android)
# ✓ Xcode / Android Studio (IDE)
```

### Paso 4: Instalar Docker

**macOS**:
```bash
# Descargar desde https://www.docker.com/products/docker-desktop
# O con Homebrew
brew install --cask docker

# Iniciar Docker Desktop desde Applications
docker --version  # Verificar
docker ps         # Verificar que daemon está corriendo
```

**Ubuntu/Debian**:
```bash
# Siguiendo https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker

docker --version
docker ps  # Verificar sin sudo
```

**Verificar Docker Compose**:
```bash
docker-compose --version  # v2.0.0+
# Si no está instalado:
docker compose version    # Comando nuevo (integrado en Docker 20.10+)
```

### Paso 5: Clonar Repositorio y Instalar Dependencias

```bash
# Ya dentro de /lonewalker
cd backend
npm install

# Verificar instalación
npm list | head -20  # Mostrar primeras 20 dependencias

# Volver a raíz y hacer mismo con frontend
cd ..
cd frontend
flutter pub get

# Verificar
flutter pub list  # Listar paquetes
```

---

## 🔌 Backend NestJS

### Estructura del Backend

```
backend/
├── src/
│   ├── main.ts                # Entry point
│   ├── app.module.ts          # Root module
│   ├── config/
│   │   └── database.config.ts # TypeORM config
│   ├── modules/
│   │   ├── auth/              # Auth feature
│   │   ├── users/             # Users feature
│   │   └── exploration/       # Exploration feature
│   └── common/
│       ├── guards/            # JWT guards
│       └── decorators/        # Custom decorators
├── package.json
├── tsconfig.json
├── Dockerfile
└── .eslintrc.js
```

### Configurar Backend

**1. Variables de Entorno**:
```bash
# En raíz del proyecto, crear/editar .env
cp .env.example .env
nano .env  # O tu editor preferido
```

**Mínimo requerido en .env**:
```env
# SERVER
NODE_ENV=development
PORT=3000
HOST=localhost

# DATABASE (PostgreSQL)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=lonewalker_dev
DB_USER=lonewalker
DB_PASSWORD=lonewalker_password
DB_SYNCHRONIZE=true

# REDIS
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your-super-secret-key-change-in-production
JWT_EXPIRATION=3600        # 1 hora
REFRESH_TOKEN_EXPIRATION=604800  # 7 días

# GOOGLE MAPS (Ver sección Google Maps Setup)
GOOGLE_MAPS_API_KEY=AIzaSy...your_actual_key
GOOGLE_MAPS_STATIC_API_KEY=AIzaSy...your_static_key

# FIREBASE (Opcional para dev local)
FIREBASE_PROJECT_ID=your-project
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=firebase@your-project.iam.gserviceaccount.com
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
```

**2. Levantar Servicios Docker**:
```bash
# Desde raíz de /lonewalker
docker-compose up -d

# Verificar servicios
docker-compose ps
# Salida esperada:
# NAME                COMMAND                  SERVICE      STATUS
# lonewalker-postgres-1  postgres --max_connections=100  postgres  Up 2 seconds
# lonewalker-redis-1     redis-server             redis       Up 1 second
# lonewalker-pgadmin-1   /entrypoint.sh           pgadmin     Up 1 second
```

**3. Esperar a PostgreSQL**:
```bash
# PostgreSQL tarda ~5-10 segundos en estar listo
sleep 10

# Verificar conectividad
psql -h localhost -U lonewalker -d lonewalker_dev -c "SELECT 1"
# Ingresa password: lonewalker_password
# Debe retornar: 1
```

**4. Iniciar Backend en Desarrollo**:
```bash
cd backend

# Opción A: Desarrollo con hot-reload
npm run start:dev
# Output esperado:
# [Nest] 1234  - 04/17/2026, 10:15:30 AM     LOG [NestFactory] Starting Nest application...
# [Nest] 1234  - 04/17/2026, 10:15:31 AM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +45ms
# [Nest] 1234  - 04/17/2026, 10:15:32 AM     LOG [InstanceLoader] ConfigModule dependencies initialized +5ms
# [Nest] 1234  - 04/17/2026, 10:15:32 AM     LOG [RouterModule] Routes registered +75ms
# [Nest] 1234  - 04/17/2026, 10:15:32 AM     LOG [NestApplication] Nest application successfully started +2ms

# Opción B: Compilación y ejecución
npm run build
npm run start:prod

# Opción C: Compilación en watch mode
npm run build:watch
```

**5. Verificar Backend está corriendo**:
```bash
# En otra terminal
curl http://localhost:3000/api/v1

# Salida esperada: {"status":"ok"}

# O en navegador: http://localhost:3000/api/docs
# (Swagger UI con documentación interactiva)
```

### Endpoints Disponibles (Phase 3)

**Salud del servidor**:
```
GET http://localhost:3000/api/v1
Respuesta: {"status":"ok"}
```

**Autenticación**:
```
POST http://localhost:3000/api/v1/auth/register
POST http://localhost:3000/api/v1/auth/login
POST http://localhost:3000/api/v1/auth/refresh
GET  http://localhost:3000/api/v1/auth/verify (Protected)
POST http://localhost:3000/api/v1/auth/logout (Protected)
```

**Exploración**:
```
POST http://localhost:3000/api/v1/exploration
GET  http://localhost:3000/api/v1/exploration/progress
GET  http://localhost:3000/api/v1/exploration/map
GET  http://localhost:3000/api/v1/exploration/last
GET  http://localhost:3000/api/v1/exploration/history
GET  http://localhost:3000/api/v1/exploration/stats
```

**Swagger UI**:
```
http://localhost:3000/api/docs
http://localhost:3000/api/docs-json
```

### Testing del Backend

```bash
cd backend

# Ejecutar tests
npm run test

# Tests en watch mode
npm run test:watch

# Coverage report
npm run test:cov
# Abre coverage/lcov-report/index.html en navegador
```

---

## 📱 Frontend Flutter

### Estructura del Frontend

```
frontend/
├── lib/
│   ├── main.dart              # App entry point
│   ├── config/
│   │   └── app_config.dart    # Configuración centralizada
│   ├── core/
│   │   ├── network/
│   │   │   └── api_client.dart  # Dio HTTP client
│   │   └── theme/
│   │       └── app_theme.dart   # Themes
│   └── features/
│       ├── auth/              # Feature autenticación
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       └── map/               # Feature mapas
│           ├── data/
│           ├── domain/
│           └── presentation/
├── pubspec.yaml               # Dependencias
└── analysis_options.yaml      # Lint rules
```

### Configurar Frontend

**1. Obtener dependencias Flutter**:
```bash
cd frontend
flutter pub get

# Verificar
flutter pub list | wc -l  # Mostrar cantidad de paquetes
```

**2. Configurar Google Maps API (Importante)**:

**Android** (`frontend/android/app/src/main/AndroidManifest.xml`):
```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="AIzaSy...your_actual_key"/>
    <!-- ... resto de config -->
</application>
```

**iOS** (`frontend/ios/Runner/GeneratedPluginRegistrant.m`):
- La configuración se hace automáticamente mediante CocoaPods

**3. Verificar Emulador/Dispositivo Disponible**:

**Android Emulator**:
```bash
# Listar dispositivos disponibles
flutter devices

# Si no hay emulador, crear uno
flutter emulators --create --name=pixel_4

# Iniciar emulador
flutter emulators --launch pixel_4

# Esperar ~30 segundos a que cargue
```

**iOS Simulator** (solo macOS):
```bash
# Listar dispositivos
flutter devices

# Si no está abierto, abrir automáticamente
flutter run
```

**Dispositivo Físico**:
```bash
# Conectar por USB y habilitar Developer Mode
# Verificar que aparezca en flutter devices
flutter devices

# Debe mostrar algo como:
# SM-A515F (mobile) • emulator-5554 • android-29 • Android 10 (API 29)
```

**4. Ejecutar App en Desarrollo**:
```bash
cd frontend

# Opción A: Ejecutar en emulador/dispositivo que está activo
flutter run

# Opción A2: Especificar dispositivo
flutter run -d emulator-5554    # Android
flutter run -d "iPhone 14"      # iOS (macOS)

# Opción B: Hot reload (mientras app está corriendo)
# Presionar 'r' en terminal para hot reload
# Presionar 'R' para hot restart
# Presionar 'q' para salir

# Opción C: Ejecutar con logs verbosos
flutter run -v
```

**Output esperado**:
```
Launching lib/main.dart on Android SDK built for x86 in debug mode...
Building an APK using gradlew.bat...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing and launching... 
✓ Application successfully started!
```

### Verificar Frontend está corriendo

1. **Visual**: App debe estar visible en emulador/dispositivo
2. **Funcionalidad**: 
   - Home screen visible con elementos básicos
   - Navegación funcional
   - Sin crashes en consola

### Testing del Frontend

```bash
cd frontend

# Ejecutar tests unitarios
flutter test

# Tests con coverage
flutter test --coverage

# Ver coverage
open coverage/lcov.info  # macOS
# O en navegador: coverage/lcov-report/index.html
```

---

## 🗄️ Base de Datos

### PostgreSQL Setup

**Acceder a PostgreSQL**:
```bash
# Método 1: Usando psql (CLI)
psql -h localhost -U lonewalker -d lonewalker_dev -W
# Password: lonewalker_password

# Método 2: Usando pgAdmin (GUI)
# URL: http://localhost:5050
# Email: admin@admin.com
# Password: admin
```

**Comandos PostgreSQL útiles**:
```sql
-- Listar bases de datos
\l

-- Conectar a BD
\c lonewalker_dev

-- Listar tablas
\dt

-- Ver esquema de tabla
\d users

-- Ver columnas de tabla
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'users';

-- Salir
\q
```

### Verificar Tablas Creadas (Phase 3)

```bash
# Conectar a BD
psql -h localhost -U lonewalker -d lonewalker_dev -W

# Dentro de psql:
\dt
# Debe mostrar:
# users
# exploration
```

**Estructura de Tabla Users**:
```bash
psql -h localhost -U lonewalker -d lonewalker_dev -W

\d users
# Columnas: id, username, email, password_hash, avatar_url, bio, 
#           privacy_mode, exploration_percent, total_xp, medals_count,
#           is_active, refresh_token_hash, created_at, updated_at, last_login_at
```

**Estructura de Tabla Exploration**:
```bash
\d exploration
# Columnas: id, user_id, latitude, longitude, accuracy_meters, speed_kmh,
#           location (PostGIS POINT), explored_at
```

### Respaldar Base de Datos

```bash
# Crear backup
pg_dump -h localhost -U lonewalker -d lonewalker_dev > lonewalker_backup.sql

# Restaurar desde backup
psql -h localhost -U lonewalker -d lonewalker_dev -f lonewalker_backup.sql
```

### Limpiar Base de Datos

```bash
# ⚠️ CUIDADO: Esto borra TODO
docker-compose down -v

# Levantar nuevamente (crea BD vacía)
docker-compose up -d postgres redis
sleep 10

# El backend crea tablas automáticamente en próxima ejecución
npm run start:dev  # Backend
```

---

## 🌐 Servicios Externos

### Google Maps Setup

**1. Crear Proyecto en Google Cloud Console**:
```
1. Ir a https://console.cloud.google.com
2. Crear nuevo proyecto: "LoneWalker"
3. Habilitar APIs:
   - Maps JavaScript API
   - Maps Static API
   - Places API (para futuro)
4. Crear credenciales (API Key)
5. Restringir clave a aplicaciones iOS y Android
```

**2. Obtener API Key**:
```
1. En Google Cloud Console → Credenciales
2. Copiar "API key" (empieza con "AIzaSy...")
3. Pegar en .env:
   GOOGLE_MAPS_API_KEY=AIzaSy...
   GOOGLE_MAPS_STATIC_API_KEY=AIzaSy...
```

**3. Verificar funcionamiento**:
```bash
# En navegador
https://maps.googleapis.com/maps/api/staticmap?center=40.4168,-3.7038&zoom=15&size=400x300&key=AIzaSy...

# Debe retornar una imagen
```

### Firebase Setup (Opcional)

**Para desarrollo local, no es obligatorio, pero si quieres habilitar:**

**1. Crear Proyecto Firebase**:
```
1. Ir a https://firebase.google.com
2. Crear nuevo proyecto: "LoneWalker"
3. Agregar Apps (Android, iOS)
4. Descargar config files
```

**2. Configurar Android**:
```
Copiar google-services.json a: frontend/android/app/
```

**3. Configurar iOS**:
```
Copiar GoogleService-Info.plist a: frontend/ios/Runner/
```

**4. Configurar Backend**:
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="..."
FIREBASE_CLIENT_EMAIL="..."
FIREBASE_DATABASE_URL="..."
```

---

## ✅ Verificación de Setup

### Checklist Completo

```bash
# 1. Git
git --version
git status  # Debe estar limpio

# 2. Node.js
node --version  # v18.16.0+
npm --version   # 9.0.0+

# 3. Flutter
flutter --version  # 3.16.0+
flutter doctor     # Todos con ✓

# 4. Docker
docker --version           # 20.10+
docker-compose --version   # 2.0+
docker ps                  # Servicios arriba
docker-compose ps          # Same check

# 5. PostgreSQL
psql -h localhost -U lonewalker -d lonewalker_dev -c "SELECT 1"
# Respuesta: 1

# 6. Redis
redis-cli -h localhost ping
# Respuesta: PONG

# 7. Backend
curl http://localhost:3000/api/v1
# Respuesta: {"status":"ok"}

# 8. Frontend
flutter devices  # Al menos un emulador/dispositivo

# 9. API funcionando
curl -X GET http://localhost:3000/api/v1/exploration/progress \
  -H "Authorization: Bearer <tu_token_jwt>"
# Debe retornar JSON con exploration stats
```

### Script de Verificación

```bash
#!/bin/bash
# save as: scripts/verify-setup.sh

echo "🔍 Verificando setup de LoneWalker..."
echo ""

# Node.js
echo "✓ Node.js"
node --version

# Flutter
echo "✓ Flutter"
flutter --version

# Docker
echo "✓ Docker"
docker --version

# PostgreSQL
echo "✓ PostgreSQL"
psql -h localhost -U lonewalker -d lonewalker_dev -c "SELECT 1" >/dev/null 2>&1 && echo "  Connected" || echo "  NOT RUNNING"

# Redis
echo "✓ Redis"
redis-cli -h localhost ping >/dev/null 2>&1 && echo "  Connected" || echo "  NOT RUNNING"

# Backend
echo "✓ Backend"
curl -s http://localhost:3000/api/v1 >/dev/null 2>&1 && echo "  Running" || echo "  NOT RUNNING"

echo ""
echo "✅ Verificación completa!"
```

```bash
chmod +x scripts/verify-setup.sh
./scripts/verify-setup.sh
```

---

## 🐛 Troubleshooting

### Backend Issues

**Error: "Cannot find module '@nestjs/common'"**
```bash
cd backend
rm -rf node_modules package-lock.json
npm install
```

**Error: "connect ECONNREFUSED 127.0.0.1:5432"** (PostgreSQL no está corriendo)
```bash
docker-compose up -d postgres
sleep 10  # Esperar a que inicie
npm run start:dev
```

**Error: "connect ECONNREFUSED 127.0.0.1:6379"** (Redis no está corriendo)
```bash
docker-compose up -d redis
npm run start:dev
```

**Error: "FATAL: role 'lonewalker' does not exist"**
```bash
# Recrear PostgreSQL
docker-compose down -v postgres
docker-compose up -d postgres
sleep 15  # Esperar a init
```

**Port 3000 ya está en uso**:
```bash
# Cambiar en .env
PORT=3001

# O matar proceso
lsof -i :3000
kill -9 <PID>
```

**Error: "TypeORM error: column 'xyz' does not exist"**
```bash
# Sincronizar BD con entities
# En desarrollo está habilitado automáticamente
# Si no funciona:
docker-compose down -v
docker-compose up -d postgres
npm run start:dev  # Crea tablas desde cero
```

### Frontend Issues

**Error: "flutter: command not found"**
```bash
# Agregar Flutter a PATH
export PATH="$PATH:$HOME/development/flutter/bin"

# Hacer permanente (en ~/.bashrc o ~/.zshrc)
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

**Error: "No device available"**
```bash
# Crear/iniciar emulador Android
flutter emulators --create --name=pixel_4
flutter emulators --launch pixel_4

# O crear en Android Studio manualmente
```

**Error: "MapsInitializedException: Platform views are disabled"**
```dart
// En lib/main.dart, antes de runApp():
WidgetsFlutterBinding.ensureInitialized();
```

**Error: "PlatformException: MissingPluginException"**
```bash
# Reinstalar dependencias
cd frontend
flutter clean
flutter pub get
flutter run
```

**Hot reload no funciona**
```bash
# Detener y reiniciar
# Presionar 'q' en terminal
flutter run

# O ejecutar:
flutter run --no-fast-start
```

**Google Maps no carga**
```bash
# Verificar que API key esté en:
# Android: android/app/src/main/AndroidManifest.xml
# iOS: ios/Runner/GeneratedPluginRegistrant.m

# Verificar que API esté habilitada en Google Cloud Console:
# https://console.cloud.google.com/apis/library
```

### Docker Issues

**Error: "Cannot connect to Docker daemon"**
```bash
# Iniciar Docker Desktop (macOS/Windows) o:
sudo systemctl start docker  # Linux

# O si usas socket:
sudo usermod -aG docker $USER
newgrp docker
```

**PostgreSQL no inicializa**
```bash
# Ver logs
docker-compose logs postgres

# Limpiar y reintentar
docker-compose down -v
docker-compose up postgres
```

**Error: "Bind for 0.0.0.0:5432 failed"**
```bash
# Puerto ya está en uso
lsof -i :5432
kill -9 <PID>

# O usar puerto diferente en docker-compose.yml
```

### Database Issues

**No puedo conectarme a PostgreSQL**
```bash
# Verificar credenciales en .env
cat .env | grep DB_

# Verificar servicio está corriendo
docker ps | grep postgres

# Probar conexión
psql -h localhost -U lonewalker -d lonewalker_dev -W
# Ingresa password de .env (DB_PASSWORD)
```

**Tabla no existe pero debería existir**
```bash
# Backend crea tablas automáticamente en desarrollo
# Si no lo hizo:
npm run start:dev

# Ver logs de TypeORM
# Debe mostrar: "TypeOrmModule dependencies initialized"

# O sincronizar manualmente (no disponible aún)
```

**Datos no se guardan en BD**
```bash
# Verificar que el endpoint realmente guarda
# Revisar logs de backend

# Limpiar BD y reintentar
docker-compose down -v postgres
docker-compose up -d postgres
npm run start:dev
```

---

## 🛠️ Comandos Útiles

### Backend Commands

```bash
cd backend

# Desarrollo
npm run start:dev          # Hot reload on port 3000

# Build
npm run build              # Compilar TypeScript
npm run build:watch        # Compilar en watch mode

# Tests
npm run test               # Ejecutar tests
npm run test:watch         # Tests en watch mode
npm run test:cov           # Coverage report

# Code Quality
npm run lint               # ESLint check
npm run lint:fix           # Fix linting issues
npm run format             # Prettier format
npm run format:check       # Check formatting

# Database
npm run typeorm migration:generate -- -n InitialMigration  # Generar migración
npm run typeorm migration:run                               # Ejecutar migraciones
npm run db:reset           # Reset BD

# Production
npm run build
npm run start:prod
```

### Frontend Commands

```bash
cd frontend

# Desarrollo
flutter run                # Ejecutar en device/emulator
flutter run -d <device_id> # En device específico

# Build
flutter build apk          # Build APK Android
flutter build ios          # Build para iOS
flutter build web          # Build web (experimental)

# Tests
flutter test               # Unit tests
flutter test --coverage    # Con coverage

# Code Quality
dart analyze               # Análisis estático
dart format .              # Format código
flutter doctor             # Verificar setup

# Limpieza
flutter clean              # Limpiar build
flutter pub get            # Instalar deps
flutter pub upgrade        # Actualizar deps
```

### Docker Commands

```bash
# Desde raíz /lonewalker

# Servicios
docker-compose up -d postgres redis pgadmin      # Levantar
docker-compose down                              # Bajar
docker-compose down -v                           # Bajar y borrar volúmenes
docker-compose ps                                # Estado
docker-compose logs postgres                     # Logs
docker-compose logs -f redis                     # Logs en tiempo real

# Ejecutar comandos en contenedor
docker-compose exec postgres psql -U lonewalker -d lonewalker_dev
docker-compose exec redis redis-cli

# Rebuild
docker-compose build
docker-compose up -d --force-recreate
```

### Útiles para Debugging

```bash
# Backend logs
curl http://localhost:3000/api/v1 -v

# Verificar puerto en uso
lsof -i :3000

# Verificar connecciones a BD
psql -h localhost -U lonewalker -d lonewalker_dev -c "SELECT datname, usename FROM pg_stat_activity;"

# Monitor recursos Docker
docker stats

# Verificar IP de contenedor
docker inspect lonewalker-postgres-1 | grep IPAddress

# Ejecutar SQL file
psql -h localhost -U lonewalker -d lonewalker_dev -f script.sql
```

---

## 📦 Estructura de Carpetas Útil

Después de setup completo, tu carpeta /lonewalker debe verse así:

```
lonewalker/
├── .env                          # ← Tu configuración local
├── .env.example                  # Plantilla (no editar)
├── .gitignore
├── docker-compose.yml            # ← Servicios locales
├── README.md
├── Docs/
│   ├── LOCAL_SETUP.md            # ← Este archivo
│   ├── DEVELOPMENT_PLAN.md
│   ├── README.md
│   ├── features/
│   └── technical/
├── backend/
│   ├── node_modules/             # ← Creado por npm install
│   ├── dist/                     # ← Creado por npm run build
│   ├── coverage/                 # ← Creado por npm run test:cov
│   ├── src/
│   ├── test/
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   └── .env                      # ← Símbolo de .env raíz
├── frontend/
│   ├── .dart_tool/               # ← Creado por flutter pub get
│   ├── build/                    # ← Creado por flutter run
│   ├── lib/
│   ├── test/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
├── .github/
│   └── workflows/
├── scripts/
│   └── verify-setup.sh           # ← Script útil
└── .gitkeep
```

---

## 🚀 Próximos Pasos Después de Setup

1. **Explorar Endpoints**:
   - Abrir `http://localhost:3000/api/docs` (Swagger UI)
   - Probar endpoints con diferentes métodos HTTP
   - Ver estructura de responses

2. **Registrar usuario**:
   ```bash
   curl -X POST http://localhost:3000/api/v1/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "email": "test@example.com",
       "password": "TestPassword123",
       "passwordConfirm": "TestPassword123"
     }'
   ```

3. **Login y obtener JWT**:
   ```bash
   curl -X POST http://localhost:3000/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "TestPassword123"
     }'
   # Guardar el token de respuesta
   ```

4. **Registrar exploración**:
   ```bash
   curl -X POST http://localhost:3000/api/v1/exploration \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <tu_token>" \
     -d '{
       "latitude": 40.4168,
       "longitude": -3.7038,
       "accuracy_meters": 10,
       "speed_kmh": 5
     }'
   ```

5. **Explorar frontend**:
   - Registrarse en app
   - Navegar a Map page
   - Ver Fog of War (si es en dispositivo físico con GPS)

---

## 📞 Soporte

**Si tienes problemas:**

1. Revisar sección [Troubleshooting](#troubleshooting)
2. Ejecutar `./scripts/verify-setup.sh` para checklist
3. Revisar logs: `docker-compose logs -f`
4. Crear issue en GitHub con:
   - Sistema operativo y versión
   - Output de `flutter doctor` y `npm --version`
   - Error exacto o logs
   - Pasos para reproducir

---

## 📚 Referencias

- **NestJS Docs**: https://docs.nestjs.com
- **Flutter Docs**: https://flutter.dev/docs
- **PostgreSQL Docs**: https://www.postgresql.org/docs
- **Docker Docs**: https://docs.docker.com
- **Google Maps API**: https://developers.google.com/maps
- **Firebase Docs**: https://firebase.google.com/docs

---

**¡Listo! 🎉 Deberías tener LoneWalker corriendo localmente en ~30-45 minutos.**

Si todo funciona, ¡felicidades! Estás listo para:
- ✅ Desarrollar nuevas features
- ✅ Contribuir al proyecto
- ✅ Hacer testing local
- ✅ Proceder a Phase 4 (Treasure Hunt)
