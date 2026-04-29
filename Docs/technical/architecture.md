# Arquitectura del Proyecto LoneWalker

## Descripción General

LoneWalker sigue una arquitectura moderna de cliente-servidor con soporte para modo offline. La aplicación móvil se comunica con un backend que gestiona datos, rankings y sincronización.

## 1. Arquitectura de Alto Nivel

```
┌─────────────────────────────────────────────────┐
│          CLIENTE (Aplicación Móvil)             │
├─────────────────────────────────────────────────┤
│  - Interfaz de Usuario (Flutter/React Native)   │
│  - GPS y Sensores                               │
│  - Base de Datos Local (SQLite)                 │
│  - Cache de Mapas (Tiles)                       │
│  - Sincronización                               │
└─────────────────────────────────────────────────┘
              ↓↑ (REST API + WebSocket)
┌─────────────────────────────────────────────────┐
│          SERVIDOR (Backend)                     │
├─────────────────────────────────────────────────┤
│  - API REST (Node.js/Python/Go)                 │
│  - Base de Datos (PostgreSQL)                   │
│  - Cache (Redis)                                │
│  - Storage (S3/Cloud Storage)                   │
│  - Sistema de Ranking                           │
│  - Notificaciones Push                          │
└─────────────────────────────────────────────────┘
              ↓↑
┌─────────────────────────────────────────────────┐
│       SERVICIOS EXTERNOS                        │
├─────────────────────────────────────────────────┤
│  - Google Maps API                              │
│  - Firebase (Auth, Push)                        │
│  - OpenStreetMap (Tiles)                        │
│  - AWS/GCP (Almacenamiento)                     │
└─────────────────────────────────────────────────┘
```

## 2. Stack Tecnológico

### Frontend
```
Framework: Flutter 3.10+ (iOS + Android)
Estado: BLoC (flutter_bloc ^8.1.0)
Mapas: Google Maps SDK (google_maps_flutter ^2.5.0)
GPS: Geolocator + Sensors (foreground service en Android)
BD Local: SQLite + Drift (dependencia instalada, integración pendiente Phase 8)
Autenticación: JWT propio vía backend NestJS
Notificaciones: Firebase Cloud Messaging (dependencia instalada, pendiente integración)
```

### Backend
```
Runtime: Node.js 18+ con NestJS (TypeScript)
Base Datos: PostgreSQL 14+ con PostGIS
Cache: Redis 7+ (dependencia instalada, integración pendiente Phase 8)
ORM: TypeORM con migraciones
Autenticación: JWT HS256 + Passport.js (1h access / 7d refresh)
API Docs: Swagger en /api/docs
```

### DevOps
```
Hosting: Railway.app
Containerización: Docker
CI/CD: GitHub Actions + Railway autodeploy
```

## 3. Estructura de Carpetas (Recomendada)

### Frontend (Mobile)
```
lib/
├── main.dart
├── config/
│   ├── app_config.dart
│   └── constants.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── map/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── treasure/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── core/
│   ├── database/
│   ├── network/
│   ├── utils/
│   └── widgets/
└── assets/
    ├── images/
    ├── maps/
    └── fonts/
```

### Backend (NestJS)
```
src/
├── main.ts                  # Bootstrap (puerto 3000, prefijo api/v1, Swagger)
├── app.module.ts
├── config/
│   └── database.config.ts
├── common/
│   └── constants/           # geo, auth, app, validation, error-messages
├── modules/
│   ├── auth/                # JWT + Passport, login/register/refresh/logout
│   ├── users/               # Entidad usuario (sin controller aún)
│   ├── exploration/         # Fog-of-war, PostGIS queries
│   ├── treasures/           # Radar, claim, wall-of-fame
│   ├── landmarks/           # Propuestas comunitarias y votación
│   ├── ranking/             # Rankings global, weekly, district
│   └── medals/              # Sistema de logros
└── migrations/
```

## 4. Flujo de Datos

### Flujo de Exploración

```
Usuario Camina
    ↓
GPS del dispositivo captura posición
    ↓
App calcula distancia desde última posición
    ↓
¿Velocity > 20 km/h?
├─ SÍ → Bloquear progresión (mostrar aviso)
└─ NO → Continuar
    ↓
Calcular área de niebla a despejar
    ↓
Actualizar BD Local (SQLite)
    ↓
¿Usuario tiene conexión?
├─ SÍ → Enviar datos al servidor
│   └─ Servidor actualiza exploración global
└─ NO → Guardar en cola de sincronización
    ↓
Actualizar UI (Mapa)
```

### Flujo de Tesoro

```
Usuario se acerca a POI (< 100m)
    ↓
App calcula distancia al tesoro
    ↓
Activar Modo Radar
    ↓
Usuario camina más cerca
    ↓
¿Distancia < 10m?
├─ SÍ → Mostrar botón "Reclamar"
└─ NO → Continuar retroalimentación caliente/frío
    ↓
Usuario pulsa "Reclamar"
    ↓
Validar GPS durante 3-5 segundos
    ↓
¿Posición válida?
├─ SÍ → Registrar reclamación en servidor
│   ├─ Asignar recompensas (XP, medalla)
│   ├─ Decrementar contador de usos
│   └─ Actualizar ranking
└─ NO → Mostrar error "Posición no válida"
```

### Flujo de Sincronización

```
┌──────────────────────┐
│ Datos Locales (BD)   │
└──────────────────────┘
         ↓ (Cambios detectados)
┌──────────────────────┐
│ Cola de Sincronización
├──────────────────────┤
│ - Exploración        │
│ - Tesoros           │
│ - Perfiles          │
└──────────────────────┘
         ↓
¿Conexión a Internet?
├─ SÍ → Enviar cambios pendientes
│   ├─ Usar HTTPS con JWT
│   ├─ Incluir timestamp
│   └─ Guardar en log
└─ NO → Esperar conexión
         ↓
Servidor procesa datos
    ├─ Actualiza BD principal
    ├─ Recalcula rankings
    └─ Notifica a otros usuarios
         ↓
Respuesta al cliente
    ├─ Confirma recepción
    ├─ Envía cambios del servidor
    └─ Sincroniza BD local
```

## 5. Base de Datos: Esquema Principal

### Tabla: Users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    bio TEXT,
    privacy_mode ENUM('PUBLIC', 'PRIVATE') DEFAULT 'PUBLIC',
    exploration_percent DECIMAL(5,2) DEFAULT 0,
    total_xp INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP
);
```

### Tabla: Exploration
```sql
CREATE TABLE exploration (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    radius_meters INTEGER DEFAULT 75,
    explored_at TIMESTAMP DEFAULT NOW(),
    -- PostGIS para queries espaciales
    location GEOMETRY(POINT, 4326),
    -- Índice espacial
    INDEX idx_location (location)
);
```

### Tabla: Treasures
```sql
CREATE TABLE treasures (
    id UUID PRIMARY KEY,
    creator_id UUID REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    status ENUM('ACTIVE', 'DEPLETED', 'ARCHIVED') DEFAULT 'ACTIVE',
    max_uses INTEGER,
    current_uses INTEGER DEFAULT 0,
    rarity ENUM('COMMON', 'UNCOMMON', 'RARE', 'EPIC', 'LEGENDARY'),
    stl_file_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    location GEOMETRY(POINT, 4326)
);
```

### Tabla: Treasure_Claims
```sql
CREATE TABLE treasure_claims (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    treasure_id UUID REFERENCES treasures(id),
    claimed_at TIMESTAMP DEFAULT NOW(),
    xp_earned INTEGER,
    position_lat DECIMAL(10,8),
    position_lng DECIMAL(11,8),
    UNIQUE(user_id, treasure_id)  -- Un usuario solo puede reclamar una vez
);
```

### Tabla: Rankings
```sql
CREATE TABLE rankings (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    rank INTEGER,
    exploration_percent DECIMAL(5,2),
    treasures_found INTEGER,
    xp_total INTEGER,
    medals_count INTEGER,
    score DECIMAL(10,2),
    updated_at TIMESTAMP DEFAULT NOW(),
    -- Índice para queries rápidas
    INDEX idx_score (score DESC)
);
```

## 6. API Endpoints Implementados

### Autenticación
```
POST   /api/v1/auth/register      - Crear cuenta
POST   /api/v1/auth/login         - Iniciar sesión
POST   /api/v1/auth/refresh       - Renovar JWT
POST   /api/v1/auth/logout        - Cerrar sesión (requiere JWT)
GET    /api/v1/auth/verify        - Verificar token (requiere JWT)
```

### Exploración
```
POST   /api/v1/exploration              - Registrar punto explorado (requiere JWT)
GET    /api/v1/exploration/progress     - Porcentaje de exploración (requiere JWT)
GET    /api/v1/exploration/map          - Fog-of-war ?lat=&lng=&radius= (requiere JWT)
GET    /api/v1/exploration/last         - Último punto registrado (requiere JWT)
GET    /api/v1/exploration/history      - Historial paginado (requiere JWT)
GET    /api/v1/exploration/stats        - Estadísticas por fecha (requiere JWT)
```

### Tesoros
```
POST   /api/v1/treasures                - Crear tesoro (requiere JWT)
GET    /api/v1/treasures/nearby         - Tesoros cercanos ?lat=&lng=&radius=
GET    /api/v1/treasures/radar          - Datos de radar (requiere JWT)
GET    /api/v1/treasures/:id            - Detalles del tesoro
POST   /api/v1/treasures/:id/claim      - Reclamar tesoro (requiere JWT)
GET    /api/v1/treasures/:id/wall-of-fame - Muro de fama
GET    /api/v1/treasures/stats/claims   - Estadísticas de claims (requiere JWT)
```

### Ranking
```
GET    /api/v1/ranking/global           - Ranking global (requiere JWT)
GET    /api/v1/ranking/weekly           - Ranking semanal (requiere JWT)
GET    /api/v1/ranking/district/:id     - Ranking por distrito (requiere JWT)
GET    /api/v1/ranking/position         - Tu posición actual (requiere JWT)
```

### Hitos Comunitarios
```
POST   /api/v1/landmarks                - Proponer hito (requiere JWT)
GET    /api/v1/landmarks                - Hitos en votación (requiere JWT)
GET    /api/v1/landmarks/approved       - Hitos aprobados ?lat=&lng=&radius=
GET    /api/v1/landmarks/:id            - Detalles de hito (requiere JWT)
POST   /api/v1/landmarks/:id/votes      - Votar en hito (requiere JWT)
GET    /api/v1/landmarks/:id/comments   - Comentarios del hito
```

### Medallas
```
GET    /api/v1/medals                   - Todas las medallas con estado unlock (requiere JWT)
GET    /api/v1/medals/my                - Solo medallas desbloqueadas (requiere JWT)
```

### Pendiente de implementación (Phase 8)
```
GET    /api/v1/users/me           - El módulo users no tiene controller aún
PUT    /api/v1/users/me           - Pendiente
GET    /api/v1/users/:id          - Pendiente
```

## 7. Seguridad

### Autenticación
- JWT (JSON Web Tokens) con expiración de 1 hora
- Refresh tokens válidos por 7 días
- Contraseñas hasheadas con bcrypt (salt: 10)

### Autorización
- Validación de JWT en cada request
- Control basado en roles (User, Creator, Admin)
- Validación de datos de entrada

### Cifrado
- HTTPS obligatorio en producción
- TLS 1.3 mínimo
- Datos sensibles encriptados en BD

### Rate Limiting
```
POST /auth/login: 5 intentos / 15 minutos
POST /api/*: 100 requests / minuto
GET /api/*: 500 requests / minuto
```

---

**Última actualización**: Abril 2026
**Versión**: 1.0
