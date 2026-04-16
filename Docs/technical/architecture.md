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

## 2. Stack Tecnológico Recomendado

### Frontend
```
Framework: Flutter (multiplataforma) o React Native
Estado: BLoC/Riverpod (Flutter) o Redux/Zustand (RN)
Mapas: Google Maps SDK + Mapbox (alternativa)
GPS: Geolocator + Sensors
BD Local: SQLite + Drift (ORM)
Autenticación: Firebase Auth
Notificaciones: Firebase Cloud Messaging
```

### Backend
```
Runtime: Node.js con Express o Python con FastAPI
Base Datos: PostgreSQL (ubicación con PostGIS)
Cache: Redis (rankings, sesiones)
Search: Elasticsearch (búsqueda de usuarios)
Almacenamiento: AWS S3 (fotos, archivos .STL)
Realtime: Socket.io (actualizaciones en vivo)
Autenticación: JWT + Refresh Tokens
```

### DevOps
```
Containerización: Docker
Orquestación: Kubernetes o Docker Compose
CI/CD: GitHub Actions / GitLab CI
Monitoreo: Prometheus + Grafana
Logs: ELK Stack o Datadog
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

### Backend
```
src/
├── config/
│   ├── database.js
│   ├── cache.js
│   └── env.js
├── routes/
│   ├── auth.js
│   ├── users.js
│   ├── map.js
│   ├── treasures.js
│   └── ranking.js
├── controllers/
│   ├── authController.js
│   ├── mapController.js
│   └── treasureController.js
├── services/
│   ├── userService.js
│   ├── mapService.js
│   ├── rankingService.js
│   └── notificationService.js
├── models/
│   ├── User.js
│   ├── Exploration.js
│   ├── Treasure.js
│   └── Ranking.js
├── middleware/
│   ├── auth.js
│   └── validation.js
├── utils/
│   ├── logger.js
│   ├── gps.js
│   └── validators.js
└── tests/
    ├── unit/
    └── integration/
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

## 6. API Endpoints Principales

### Autenticación
```
POST   /api/v1/auth/register      - Crear cuenta
POST   /api/v1/auth/login         - Iniciar sesión
POST   /api/v1/auth/refresh       - Renovar JWT
POST   /api/v1/auth/logout        - Cerrar sesión
```

### Mapa y Exploración
```
GET    /api/v1/map/tiles/:z/:x/:y - Descargar tiles de mapa
POST   /api/v1/exploration        - Registrar posición explorada
GET    /api/v1/exploration/progress - Obtener porcentaje exploración
GET    /api/v1/exploration/map    - Obtener mapa de exploración
```

### Tesoros
```
GET    /api/v1/treasures          - Listar tesoros cercanos
GET    /api/v1/treasures/:id      - Detalles del tesoro
POST   /api/v1/treasures          - Crear tesoro (Maker)
POST   /api/v1/treasures/:id/claim - Reclamar tesoro
GET    /api/v1/treasures/:id/wall - Muro de fama del tesoro
```

### Ranking
```
GET    /api/v1/ranking/global     - Ranking global
GET    /api/v1/ranking/district/:id - Ranking del distrito
GET    /api/v1/ranking/weekly     - Ranking semanal
GET    /api/v1/ranking/position   - Tu posición actual
```

### Perfil de Usuario
```
GET    /api/v1/users/me           - Obtener mi perfil
PUT    /api/v1/users/me           - Actualizar perfil
GET    /api/v1/users/:id          - Ver perfil público
POST   /api/v1/users/me/friends   - Solicitar amistad
GET    /api/v1/users/me/medals    - Mis medallas
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
