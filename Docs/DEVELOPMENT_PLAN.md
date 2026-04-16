# Plan de Desarrollo - LoneWalker

**Versión**: 1.0  
**Fecha**: Abril 2026  
**Estado**: Aprobado para implementación

---

## 📋 Tabla de Contenidos

1. [Context](#context)
2. [Stack Tecnológico](#stack-tecnológico)
3. [Fases de Desarrollo](#fases-de-desarrollo)
4. [Criterios de Éxito](#criterios-de-éxito)
5. [Próximos Pasos](#próximos-pasos)

---

## Context

LoneWalker es una aplicación de exploración gamificada basada en GPS que transforma la forma de descubrir ciudades. El proyecto requiere una arquitectura cliente-servidor robusta para soportar:

- ✅ Exploración con Fog of War dinámico
- ✅ Búsqueda de tesoros con sistema de radar
- ✅ Ranking social competitivo
- ✅ Sistema comunitario de hitos con votación democrática
- ✅ Gamificación con medallas y puntos de experiencia

Se ha completado la documentación comprehensiva en `Docs/`. Ahora se requiere inicializar la estructura de desarrollo e implementar las características en 8 fases.

---

## Stack Tecnológico

### Stack Seleccionado

```
🔧 Backend:   Node.js 18+ + NestJS (TypeScript) + PostgreSQL + Redis
📱 Frontend:  Flutter 3.10+ (iOS + Android)
☁️  Hosting:   Google Cloud Platform (GCP)
🐳 DevOps:    Docker + GitHub Actions
```

### Componentes Detallados

#### Backend (NestJS + TypeScript)
```
Framework:        NestJS + Express (embebido)
Lenguaje:         TypeScript
Base de Datos:    PostgreSQL 14+ (con PostGIS para geo)
Cache:            Redis 7+
ORM:              TypeORM
Validación:       Class Validator + Class Transformer
Autenticación:    JWT + Passport.js
API Docs:         Swagger/OpenAPI
Testing:          Jest
```

#### Frontend (Flutter)
```
Framework:        Flutter 3.10+
Lenguaje:         Dart
State Management: BLoC + Riverpod
Mapas:            Google Maps SDK + Mapbox
Geolocalización:  Geolocator + Sensors
BD Local:         SQLite + Drift (ORM)
Autenticación:    Firebase Auth
Push:             Firebase Cloud Messaging
Testing:          Flutter test + Mockito
```

#### Google Cloud Platform
```
Servidor Backend:  Cloud Run (contenido Docker)
Base de Datos:     Cloud SQL (PostgreSQL 14)
Cache:             Redis Enterprise
Storage:           Cloud Storage (fotos, .STL)
DNS:               Cloud DNS
Monitoring:        Cloud Monitoring + Cloud Logging
CI/CD:             Cloud Build (integración con GitHub)
```

### Requisitos Previos

```bash
# Obligatorio
Node.js 18+
PostgreSQL 14+
Redis 7+
Flutter 3.10+
Docker 20+
Git
GCP Account

# Herramientas útiles
Postman o Insomnia (testing API)
Android Studio (Flutter development)
Xcode (Flutter iOS)
pgAdmin (database management)
```

---

## Fases de Desarrollo

### ⏱️ Estimación: 9 semanas
### 👤 Equipo: 1-2 developers recomendado
### 🚀 Prioridad: Backend primero, luego integración Frontend

---

### FASE 1: Setup Inicial e Infraestructura
**Duración**: Semana 1-2  
**Objetivo**: Estructura base, repositorio, entorno de desarrollo

#### 1.1 Repositorio Git
- Cambiar rama `claude/create-docs-exploration-HaPDX` → `main` (rama default)
- Crear `.gitignore` (Node.js + Flutter)
- Crear `.editorconfig`
- Crear `LICENSE` (MIT)

#### 1.2 Estructura del Proyecto
```
lonewalker/
├── backend/                          # NestJS + TypeScript
├── frontend/                         # Flutter
├── docs/                            # Documentación (ya existe)
├── .github/
│   ├── workflows/                   # CI/CD pipelines
│   └── ISSUE_TEMPLATE/
├── docker-compose.yml               # Desarrollo local
├── .env.example                     # Template variables
└── README.md
```

#### 1.3 Backend - Inicialización NestJS

```bash
npm i -g @nestjs/cli
nest new backend --package-manager npm
```

**Dependencias clave**:
```json
{
  "@nestjs/common": "^10.0.0",
  "@nestjs/core": "^10.0.0",
  "@nestjs/jwt": "^12.0.0",
  "@nestjs/passport": "^10.0.0",
  "@nestjs/config": "^3.0.0",
  "@nestjs/swagger": "^7.0.0",
  "typeorm": "^0.3.0",
  "pg": "^8.10.0",
  "redis": "^4.6.0",
  "class-validator": "^0.14.0",
  "class-transformer": "^0.5.1",
  "passport-jwt": "^4.0.1",
  "helmet": "^7.0.0"
}
```

**Estructura NestJS**:
```
backend/src/
├── main.ts
├── app.module.ts
├── config/
│   ├── database.config.ts
│   └── redis.config.ts
├── modules/
│   ├── auth/
│   ├── users/
│   ├── exploration/
│   ├── treasures/
│   ├── landmarks/
│   └── ranking/
├── common/
│   ├── filters/
│   ├── guards/
│   ├── interceptors/
│   └── pipes/
└── database/
    ├── entities/
    └── migrations/
```

#### 1.4 Frontend - Inicialización Flutter

```bash
flutter create frontend
```

**pubspec.yaml principales**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  geolocator: ^9.0.0
  google_maps_flutter: ^2.5.0
  sqflite: ^2.3.0
  drift: ^2.14.0
  firebase_auth: ^4.10.0
  firebase_messaging: ^14.6.0
  provider: ^6.0.0
  dio: ^5.3.0
```

**Estructura Flutter**:
```
frontend/lib/
├── main.dart
├── config/
│   └── app_config.dart
├── core/
│   ├── database/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   ├── map/
│   ├── treasure/
│   ├── profile/
│   └── landmarks/
└── assets/
    ├── images/
    └── fonts/
```

#### 1.5 Docker Compose

**Servicios**:
- `postgres`: PostgreSQL 14
- `redis`: Redis 7
- `backend`: NestJS (puerto 3000)
- `pgadmin`: Admin BD (puerto 5050)

```bash
docker-compose up -d
```

#### 1.6 CI/CD - GitHub Actions

**Workflows**:
- `.github/workflows/backend-ci.yml`: Lint + Tests + Build
- `.github/workflows/frontend-ci.yml`: Analyze + Tests

#### ✅ Criterios de Éxito
- [ ] Repositorio con rama `main` activa
- [ ] Docker Compose levantando todos los servicios
- [ ] Backend NestJS compilando sin errores
- [ ] Frontend Flutter compilando sin errores
- [ ] GitHub Actions ejecutando exitosamente
- [ ] Variables de entorno configuradas

---

### FASE 2: Autenticación
**Duración**: Semana 2-3  
**Objetivo**: Sistema de auth robusto con JWT

#### 2.1 Backend - Módulo de Autenticación

**Archivos**:
```
backend/src/modules/auth/
├── auth.controller.ts
├── auth.service.ts
├── auth.module.ts
├── dto/
│   ├── login.dto.ts
│   ├── register.dto.ts
│   └── auth-response.dto.ts
├── strategies/
│   └── jwt.strategy.ts
└── guards/
    └── jwt-auth.guard.ts
```

**Database - Entity Users**:
```typescript
@Entity('users')
export class UserEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column({ length: 50, unique: true })
  username: string;

  @Column({ length: 100, unique: true })
  email: string;

  @Column()
  password_hash: string;

  @Column({ nullable: true })
  avatar_url: string;

  @Column({ nullable: true, type: 'text' })
  bio: string;

  @Column({ default: 'PUBLIC' })
  privacy_mode: string;

  @Column({ type: 'decimal', default: 0 })
  exploration_percent: number;

  @Column({ default: 0 })
  total_xp: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
```

**Endpoints**:
```
POST   /api/v1/auth/register     - Crear cuenta
POST   /api/v1/auth/login        - Login
POST   /api/v1/auth/refresh      - Renovar JWT
POST   /api/v1/auth/logout       - Logout
GET    /api/v1/auth/verify       - Verificar token
```

**Validaciones**:
- Email válido (RFC 5322)
- Contraseña mínimo 8 caracteres
- Username 3-50 caracteres, alphanumeric + underscore
- Email y username únicos

#### 2.2 Frontend - Pantallas de Autenticación

**BLoC Architecture**:
```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login_usecase.dart
│       ├── register_usecase.dart
│       └── logout_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    └── pages/
        ├── login_page.dart
        ├── register_page.dart
        └── forgot_password_page.dart
```

**Screens**:
- Login (email + password)
- Register (form)
- Forgot Password
- Splash Screen (auto-login)

#### 2.3 Integración

- Token storage en SharedPreferences (encriptado)
- Auto-refresh de JWT tokens
- Interceptor HTTP para incluir tokens
- Logout automático si token expirado
- Persistent login (recordar sesión)

#### ✅ Criterios de Éxito
- [ ] Register, Login, Logout funcionando en backend
- [ ] JWT tokens generándose correctamente
- [ ] Tests unitarios > 80% coverage (auth.service)
- [ ] Flutter screens de auth funcionando
- [ ] Tokens almacenándose y refrescándose en Flutter
- [ ] API protegida con JWT guard

---

### FASE 3: Core - Sistema de Mapas y Exploración
**Duración**: Semana 3-4  
**Objetivo**: Base de exploración con Fog of War

#### 3.1 Backend - Módulo Exploración

**Archivos**:
```
backend/src/modules/exploration/
├── exploration.controller.ts
├── exploration.service.ts
├── exploration.module.ts
├── dto/
│   ├── create-exploration.dto.ts
│   └── exploration-response.dto.ts
└── entities/
    └── exploration.entity.ts
```

**Database - Entity Exploration**:
```typescript
@Entity('exploration')
export class ExplorationEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column('uuid')
  user_id: string;

  @Column('decimal', { precision: 10, scale: 8 })
  latitude: number;

  @Column('decimal', { precision: 11, scale: 8 })
  longitude: number;

  @CreateDateColumn()
  explored_at: Date;

  // PostGIS geometry para queries espaciales
  @Column('geometry', { spatialFeatureType: 'Point', srid: 4326 })
  location: string;
}

// Índice PostGIS
CREATE INDEX idx_exploration_location 
ON exploration USING GIST(location);
```

**Endpoints**:
```
POST   /api/v1/exploration             - Registrar exploración
GET    /api/v1/exploration/progress    - Obtener progreso
GET    /api/v1/exploration/map         - Obtener mapa con FOW
```

**Lógica**:
1. Validar velocidad (rechazar si > 20 km/h)
2. Calcular área circular (radio 75m por defecto)
3. Marcar área como explorada en BD
4. Calcular nuevas áreas despejadas
5. Retornar progreso actualizado con XP ganado

#### 3.2 Frontend - Pantalla de Mapa

**BLoC Architecture**:
```
lib/features/map/
├── data/
│   ├── datasources/
│   │   └── map_remote_datasource.dart
│   ├── models/
│   │   └── fog_of_war_model.dart
│   └── repositories/
│       └── map_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── map_state.dart
│   └── repositories/
│       └── map_repository.dart
└── presentation/
    ├── bloc/
    │   ├── map_bloc.dart
    │   ├── map_event.dart
    │   └── map_state.dart
    ├── pages/
    │   └── map_page.dart
    └── widgets/
        ├── fog_of_war_widget.dart
        ├── user_marker_widget.dart
        └── exploration_stats_widget.dart
```

**Funcionalidades**:
- Google Maps renderizando
- Capa de Fog of War (Canvas overlay con degradado)
- GPS tracking en tiempo real
- Marcador de usuario actualizado
- Zoom/Pan controls
- Estadísticas en tiempo real (% exploración, XP ganado)
- Indicador de velocidad (aviso si > 20 km/h)

#### 3.3 Offline Mode

**Implementación**:
- Caché de tiles de mapas (hasta 500MB)
- Almacenamiento local de coordenadas exploradas
- Cola de sincronización para cambios offline
- Indicador visual de modo online/offline

#### ✅ Criterios de Éxito
- [ ] Mapa renderizando con Google Maps
- [ ] Fog of War visible y actualizándose
- [ ] GPS tracking funcionando en tiempo real
- [ ] Exploración registrándose en backend
- [ ] Porcentaje de exploración calculándose
- [ ] Modo offline cacheando y sincronizando
- [ ] Tests de integration para exploración

---

### FASE 4: Búsqueda de Tesoros
**Duración**: Semana 4-5  
**Objetivo**: Sistema de tesoros con radar y validación GPS

#### 4.1 Backend - Módulo Tesoros

**Archivos**:
```
backend/src/modules/treasures/
├── treasures.controller.ts
├── treasures.service.ts
├── treasures.module.ts
├── dto/
│   ├── create-treasure.dto.ts
│   ├── claim-treasure.dto.ts
│   └── treasure-response.dto.ts
└── entities/
    ├── treasure.entity.ts
    └── treasure-claim.entity.ts
```

**Database - Entities**:
```typescript
@Entity('treasures')
export class TreasureEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column('uuid')
  creator_id: string;

  @Column({ length: 200 })
  title: string;

  @Column('text')
  description: string;

  @Column('decimal', { precision: 10, scale: 8 })
  latitude: number;

  @Column('decimal', { precision: 11, scale: 8 })
  longitude: number;

  @Column({ default: 'ACTIVE' })
  status: 'ACTIVE' | 'DEPLETED' | 'ARCHIVED';

  @Column({ nullable: true })
  max_uses: number;

  @Column({ default: 0 })
  current_uses: number;

  @Column({ nullable: true })
  rarity: 'COMMON' | 'UNCOMMON' | 'RARE' | 'EPIC' | 'LEGENDARY';

  @Column({ nullable: true })
  stl_file_url: string;

  @CreateDateColumn()
  created_at: Date;

  @Column('geometry', { spatialFeatureType: 'Point', srid: 4326 })
  location: string;
}

@Entity('treasure_claims')
export class TreasureClaimEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column('uuid')
  user_id: string;

  @Column('uuid')
  treasure_id: string;

  @Column({ default: 100 })
  xp_earned: number;

  @CreateDateColumn()
  claimed_at: Date;

  @Unique(['user_id', 'treasure_id'])
  unique_claim: void;
}
```

**Endpoints**:
```
GET    /api/v1/treasures?lat=...&lng=...&radius=...   - Cercanos
GET    /api/v1/treasures/{id}                         - Detalles
POST   /api/v1/treasures                              - Crear (Maker)
POST   /api/v1/treasures/{id}/claim                   - Reclamar
GET    /api/v1/treasures/{id}/wall-of-fame            - Muro fama
```

**Lógica de Reclamación**:
```
1. Usuario a < 10m del tesoro
2. Validar GPS durante 3-5 segundos
3. Crear registro en treasure_claims
4. Decrementar current_uses
5. Si current_uses >= max_uses → cambiar status a DEPLETED
6. Otorgar XP (100 base + bonus por rareza)
7. Desbloquear medalla si aplica
8. Retornar detalles de recompensa
```

#### 4.2 Frontend - Pantalla Radar

**BLoC Architecture**:
```
lib/features/treasure/
├── data/
│   ├── datasources/
│   │   └── treasure_remote_datasource.dart
│   ├── models/
│   │   └── treasure_model.dart
│   └── repositories/
│       └── treasure_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── treasure.dart
│   └── repositories/
│       └── treasure_repository.dart
└── presentation/
    ├── bloc/
    │   ├── treasure_bloc.dart
    │   ├── treasure_event.dart
    │   └── treasure_state.dart
    ├── pages/
    │   └── radar_page.dart
    └── widgets/
        ├── radar_widget.dart
        ├── temperature_indicator_widget.dart
        └── claim_button_widget.dart
```

**Funcionalidades**:
- Activación automática radar (50-100m)
- Indicador caliente/frío (gradiente azul → rojo)
- Colores dinámicos según distancia:
  - 🔵 Azul: > 30m (Frío)
  - 🟡 Amarillo: 15-30m (Tibio)
  - 🟠 Naranja: 5-15m (Caliente)
  - 🔴 Rojo: < 5m (Muy caliente)
- Vibración háptica intensidad variable
- Brújula de radar mostrando dirección
- Botón "Reclamar" cuando < 10m
- Validación GPS visual (spinner)
- Muro de la fama post-reclamación

#### ✅ Criterios de Éxito
- [ ] Backend creando tesoros exitosamente
- [ ] Endpoint de búsqueda por proximidad funcionando
- [ ] Validación GPS funcionando
- [ ] Reclamación de tesoros registrándose
- [ ] XP otorgándose correctamente
- [ ] Flutter mostrando radar
- [ ] Indicador caliente/frío actualizándose en tiempo real
- [ ] Vibración háptica funcionando
- [ ] Tests de reclamación de tesoros

---

### FASE 5: Sistema de Ranking
**Duración**: Semana 5-6  
**Objetivo**: Ranking social con privacidad

#### 5.1 Backend - Módulo Ranking

**Archivos**:
```
backend/src/modules/ranking/
├── ranking.controller.ts
├── ranking.service.ts
├── ranking.module.ts
├── entities/
│   └── ranking.entity.ts
└── jobs/
    └── ranking-calculator.job.ts
```

**Database - Entity Ranking**:
```typescript
@Entity('rankings')
export class RankingEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column('uuid')
  user_id: string;

  @Column('integer')
  rank: number;

  @Column('decimal', { precision: 5, scale: 2 })
  exploration_percent: number;

  @Column('integer')
  treasures_found: number;

  @Column('integer')
  xp_total: number;

  @Column('integer')
  medals_count: number;

  @Column('decimal', { precision: 10, scale: 2 })
  score: number;

  @UpdateDateColumn()
  updated_at: Date;

  // Índice para queries rápidas
  @Index()
  score: number;
}
```

**Endpoints**:
```
GET    /api/v1/ranking/global               - Ranking global
GET    /api/v1/ranking/district/{id}        - Ranking distrito
GET    /api/v1/ranking/weekly               - Ranking semanal
GET    /api/v1/ranking/position             - Mi posición
```

**Cálculo de Score**:
```
Score = (exploración% × 0.4) + 
         (treasures × 0.3) + 
         (xp/1000 × 0.2) + 
         (medals × 0.1)

Ranking = ORDER BY score DESC
```

**Job Automático**: Recalcular ranking cada 1 hora (Cron)
- Usa Redis para caché
- Actualiza tabla rankings
- Notifica cambios significativos

#### 5.2 Frontend - Pantalla Ranking

**BLoC Architecture**:
```
lib/features/ranking/
├── data/
│   ├── datasources/
│   │   └── ranking_remote_datasource.dart
│   ├── models/
│   │   └── ranking_model.dart
│   └── repositories/
│       └── ranking_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── ranking.dart
│   └── repositories/
│       └── ranking_repository.dart
└── presentation/
    ├── bloc/
    │   ├── ranking_bloc.dart
    │   ├── ranking_event.dart
    │   └── ranking_state.dart
    ├── pages/
    │   └── ranking_page.dart
    └── widgets/
        ├── ranking_item_widget.dart
        ├── user_position_widget.dart
        └── district_ranking_widget.dart
```

**Funcionalidades**:
- Ranking global scrolleable con foto + nombre + stats
- Tu posición destacada con colores
- Filtro por distrito
- Ranking semanal con countdown
- Perfil público clickeable
- Toggle privacidad (ocultar/mostrar en ranking)
- Medallas mostradas junto a ranking

#### ✅ Criterios de Éxito
- [ ] Job de ranking calculándose correctamente
- [ ] Scores calculándose con fórmula correcta
- [ ] Ranking global visible en API
- [ ] Flutter mostrando ranking global
- [ ] Tu posición destacada
- [ ] Filtro de distrito funcionando
- [ ] Control de privacidad funcionando
- [ ] Tests de cálculo de ranking

---

### FASE 6: Sistema Comunitario - Hitos
**Duración**: Semana 6-7  
**Objetivo**: Votación de hitos con curación social

#### 6.1 Backend - Módulo Landmarks

**Archivos**:
```
backend/src/modules/landmarks/
├── landmarks.controller.ts
├── landmarks.service.ts
├── landmarks.module.ts
├── dto/
│   ├── create-landmark.dto.ts
│   ├── vote-landmark.dto.ts
│   └── landmark-response.dto.ts
└── entities/
    ├── landmark.entity.ts
    └── landmark-vote.entity.ts
```

**Database - Entities**:
```typescript
@Entity('landmarks')
export class LandmarkEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column('uuid')
  creator_id: string;

  @Column({ length: 200 })
  title: string;

  @Column('text')
  description: string;

  @Column({ length: 50 })
  category: string;

  @Column('decimal', { precision: 10, scale: 8 })
  latitude: number;

  @Column('decimal', { precision: 11, scale: 8 })
  longitude: number;

  @Column({ default: 'DRAFT' })
  status: 'DRAFT' | 'VOTING' | 'APPROVED' | 'REJECTED';

  @Column({ default: 0 })
  votes_positive: number;

  @Column({ default: 0 })
  votes_negative: number;

  @Column({ nullable: true })
  photo_url: string;

  @CreateDateColumn()
  created_at: Date;

  @Column({ nullable: true })
  approved_at: Date;

  @Column('geometry', { spatialFeatureType: 'Point', srid: 4326 })
  location: string;
}

@Entity('landmark_votes')
export class LandmarkVoteEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column('uuid')
  landmark_id: string;

  @Column('uuid')
  user_id: string;

  @Column('integer')  // +1 o -1
  vote: number;

  @Column('text')
  comment: string;  // Obligatorio

  @Column({ nullable: true })
  evidence_type: string;

  @CreateDateColumn()
  created_at: Date;

  @Unique(['landmark_id', 'user_id'])
  unique_vote: void;
}
```

**Endpoints**:
```
POST   /api/v1/landmarks                     - Proponer hito
GET    /api/v1/landmarks?status=VOTING       - Hitos en votación
GET    /api/v1/landmarks/{id}                - Detalles + votos
POST   /api/v1/landmarks/{id}/votes          - Votar
GET    /api/v1/landmarks/{id}/comments       - Comentarios
```

**Lógica de Aprobación**:
```
1. Hito creado → Status DRAFT
2. Visible en pestaña "Hitos en Votación" por 14 días
3. Comunidad vota + comenta (comentario obligatorio)
4. Si votos_positive - votos_negative >= +20:
   → Status APPROVED (visible en mapa)
5. Si 14 días sin +20 netos o votos_negative > positivos:
   → Status REJECTED (desaparece del mapa)
6. Si hito APROBADO y (votos_negative > votos_positive + 10):
   → Vuelve a REJECTED (ya no existe)
```

**Puntos de Reputación "Cartógrafo"**:
```
Proponer hito:        +10 puntos
Hito aprobado:        +50 puntos
Hito rechazado:       -5 puntos
Voto positivo:        +1 punto
Voto útil (recibe +5): +2 puntos
Comentario destacado: +3 puntos
```

**Niveles**:
```
0-50:      Explorador Novato
50-150:    Cartógrafo Aprendiz
150-400:   Cartógrafo Confirmado
400-1000:  Cartógrafo Maestro
1000+:     Guardián del Mapa
```

#### 6.2 Frontend - Pantalla Landmarks

**BLoC Architecture**:
```
lib/features/landmarks/
├── data/
│   ├── datasources/
│   │   └── landmark_remote_datasource.dart
│   ├── models/
│   │   └── landmark_model.dart
│   └── repositories/
│       └── landmark_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── landmark.dart
│   └── repositories/
│       └── landmark_repository.dart
└── presentation/
    ├── bloc/
    │   ├── landmark_bloc.dart
    │   ├── landmark_event.dart
    │   └── landmark_state.dart
    ├── pages/
    │   ├── voting_page.dart
    │   └── proposal_page.dart
    └── widgets/
        ├── landmark_card_widget.dart
        ├── vote_widget.dart
        └── comments_widget.dart
```

**Funcionalidades**:
- Pestaña "Hitos en Votación"
- Formulario de propuesta (foto, nombre, descripción, categoría)
- Validación: usuario a < 50m del punto
- Votación con comentario obligatorio
- Visualización de votos/comentarios
- Contador de días restantes
- Comentarios destacados (con +5 votos)
- Muro de hitos aprobados en mapa
- Puntos de Cartógrafo mostrados en perfil

#### ✅ Criterios de Éxito
- [ ] Creación de hitos funcionando
- [ ] Sistema de votación con comentario obligatorio
- [ ] Aprobación automática en +20 votos netos
- [ ] Rechazo automático por tiempo o votos negativos
- [ ] Flutter mostrando hitos en votación
- [ ] Formulario de propuesta validando ubicación
- [ ] Comentarios visibles y ordenados
- [ ] Puntos de Cartógrafo acumulándose
- [ ] Tests de lógica de aprobación

---

### FASE 7: Medallas y Gamificación
**Duración**: Semana 7-8  
**Objetivo**: Sistema de recompensas completo

#### 7.1 Backend - Módulo Medallas

**Database - Entities**:
```typescript
@Entity('medals')
export class MedalEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column({ length: 100 })
  name: string;

  @Column('text')
  description: string;

  @Column({ nullable: true })
  icon_url: string;

  @Column()
  rarity: 'COMMON' | 'UNCOMMON' | 'RARE' | 'EPIC' | 'LEGENDARY';

  @Column('text')
  unlock_condition: string;

  @CreateDateColumn()
  created_at: Date;
}

@Entity('user_medals')
export class UserMedalEntity {
  @PrimaryColumn('uuid')
  id: string;

  @Column('uuid')
  user_id: string;

  @Column('uuid')
  medal_id: string;

  @CreateDateColumn()
  unlocked_at: Date;

  @Unique(['user_id', 'medal_id'])
  unique_medal: void;
}
```

**Medallas a Implementar**:
```
🏆 Exploración:
  - Conquistador (100% distrito)
  - Explorador (X% ciudad)
  - Cartógrafo (X hitos aprobados)

🎯 Tesoros:
  - Buscador (X tesoros encontrados)
  - Cazador Raro (X tesoros raros)
  - Ganador (Primer tesoro)

✅ Social:
  - Verificador (X votos útiles)
  - Historiador (X comentarios con +10 votos)
  - Influencer (X amigos con mismo distrito)

🌟 Especiales:
  - Paz Territorial (Hitos en distritos rivales)
  - Maestro de Madrid (Completar todo)
```

**Sistema XP**:
```
Exploración:      +10 XP per 1% nuevo
Tesoro:           +100 base + rareza bonus
  - COMMON:       +100 XP
  - UNCOMMON:     +150 XP
  - RARE:         +250 XP
  - EPIC:         +400 XP
  - LEGENDARY:    +1000 XP
Voto útil:        +1-5 XP (según votación)
Medalla:          Variable (50-500 XP)
Landmark votado:  +50 XP si pasa +20
```

**Service de Logros**: 
Servicio que verifica automáticamente si usuario ha desbloqueado medalla

#### 7.2 Frontend - Galería Medallas

**Funcionalidades**:
- Galería de medallas desbloqueadas
- Medallas bloqueadas con progreso (barra)
- Descripción de cómo desbloquear
- Medallas mostradas en perfil público
- Contador de XP acumulado
- Historial de logros recientes

#### ✅ Criterios de Éxito
- [ ] Medallas creadas en base de datos
- [ ] Service de logros funcionando
- [ ] XP acumulándose correctamente
- [ ] Medallas desbloqueándose automáticamente
- [ ] Flutter mostrando galería de medallas
- [ ] Progreso hacia medalla visible
- [ ] Tests de unlock de medallas

---

### FASE 8: Testing e Integración
**Duración**: Semana 8-9  
**Objetivo**: Cobertura de tests completa e integración end-to-end

#### 8.1 Backend - Test Suite

**Unit Tests** (Jest):
```
backend/test/
├── auth/
│   ├── auth.service.spec.ts
│   └── auth.controller.spec.ts
├── exploration/
│   ├── exploration.service.spec.ts
│   └── exploration-calculator.spec.ts
├── treasures/
│   ├── treasure.service.spec.ts
│   └── treasure-claim.spec.ts
├── landmarks/
│   ├── landmark-vote.service.spec.ts
│   └── landmark-approval.spec.ts
├── ranking/
│   └── ranking-calculator.spec.ts
└── medals/
    └── medal-unlock.spec.ts
```

**Integration Tests**:
```
backend/test/integration/
├── auth-flow.test.ts
├── exploration-flow.test.ts
├── treasure-claim-flow.test.ts
├── landmark-voting-flow.test.ts
└── ranking-calculation.test.ts
```

**Coverage Mínimo**: 80%

#### 8.2 Frontend - Test Suite

**Unit Tests** (Flutter test):
```
frontend/test/
├── features/auth/
│   ├── data/repositories/
│   │   └── auth_repository_test.dart
│   └── presentation/bloc/
│       └── auth_bloc_test.dart
├── features/map/
│   └── presentation/bloc/
│       └── map_bloc_test.dart
├── features/treasure/
│   └── presentation/bloc/
│       └── treasure_bloc_test.dart
└── features/ranking/
    └── data/repositories/
        └── ranking_repository_test.dart
```

**Coverage Mínimo**: 75%

#### 8.3 Integration Tests

**E2E Flows**:
1. **Registro → Login → Exploración**
   - Usuario registra → Login exitoso → Explora mapa → XP acumulándose

2. **Exploración → Tesoro → Reclamación**
   - Explorar zona → Tesoro activado → Reclamar → XP otorgado

3. **Votación de Hito**
   - Proponer hito → Comunidad vota → Aprobación automática

4. **Ranking Actualizado**
   - Todas las acciones anteriores → Ranking recalculándose

#### 8.4 Performance Testing

**Benchmarks**:
- API response time < 500ms (p95)
- Maps rendering > 60fps
- Load test: 1000 usuarios simultáneos en ranking
- Explore 100k landmarks sin lag

#### ✅ Criterios de Éxito
- [ ] Tests unitarios > 80% (backend)
- [ ] Tests unitarios > 75% (frontend)
- [ ] Todos los integration tests pasando
- [ ] E2E flows funcionando
- [ ] Performance benchmarks alcanzados
- [ ] CI/CD ejecutando tests automáticamente
- [ ] Documentación de tests completa

---

## Criterios de Éxito Global

### Por Fase
| Fase | Objetivo | Criterio |
|------|----------|----------|
| 1 | Setup e Infraestructura | Docker up, CI/CD activo |
| 2 | Autenticación | Login/Register funcionando, JWT validado |
| 3 | Mapas | Mapa renderizado, FOW actualizado, exploración registrada |
| 4 | Tesoros | Radar activo, reclamaciones validadas, XP otorgado |
| 5 | Ranking | Ranking calculado, privacidad funcionando |
| 6 | Hitos | Votación funcionando, aprobación automática |
| 7 | Medallas | Medallas desbloqueándose, XP acumulándose |
| 8 | Testing | Coverage > 80%, E2E tests pasando |

### Definición de "Hecho"

**Backend**:
- ✅ Endpoint implementado y documentado en Swagger
- ✅ Tests unitarios pasando
- ✅ Validaciones en lugar
- ✅ Error handling completo
- ✅ CORS y seguridad configurados

**Frontend**:
- ✅ Screen renderizando correctamente
- ✅ BLoC implementado y testeado
- ✅ Integración con API completa
- ✅ Offline mode soportado
- ✅ Tests unitarios pasando

---

## Próximos Pasos Inmediatos

### 🚀 Semana 1 - Kickoff

1. **Cambiar rama a `main`**
   ```bash
   git branch -m claude/create-docs-exploration-HaPDX main
   git push -u origin main
   ```

2. **Crear estructura base**
   ```
   ├── backend/
   ├── frontend/
   ├── .github/workflows/
   ├── docker-compose.yml
   └── .env.example
   ```

3. **Inicializar backend NestJS**
   ```bash
   nest new backend
   # Agregar dependencias
   # Configurar TypeORM + PostgreSQL
   # Configurar Redis
   ```

4. **Inicializar frontend Flutter**
   ```bash
   flutter create frontend
   # Configurar pubspec.yaml
   # Setup carpeta structure
   ```

5. **Setup Docker**
   ```bash
   docker-compose up -d
   # PostgreSQL + Redis levantados
   ```

6. **Configurar CI/CD**
   - Crear workflows para backend tests
   - Crear workflows para frontend tests
   - Integración con Cloud Build (GCP)

7. **Primer commit**
   ```bash
   git commit -m "chore: initialize NestJS backend and Flutter frontend boilerplate"
   git push origin main
   ```

### 📋 Checklist de Inicio

- [ ] Rama `main` activa como default
- [ ] Documentación (Docs/) presente y actualizada
- [ ] Backend NestJS compilando sin errores
- [ ] Frontend Flutter compilando sin errores
- [ ] Docker Compose levantando todos los servicios
- [ ] GitHub Actions ejecutando exitosamente
- [ ] `.env.example` configurado
- [ ] README.md actualizado con instrucciones de setup

---

## Decisiones Confirmadas ✅

```
✅ Backend:        Node.js 18+ + NestJS (TypeScript)
✅ Frontend:       Flutter 3.10+
✅ Database:       PostgreSQL 14+ + Redis 7+
✅ Hosting:        Google Cloud Platform (GCP)
✅ Prioridad:      Backend primero, luego integración
✅ Rama default:   main (renombrada de claude/create-docs-exploration-HaPDX)
✅ CI/CD:          GitHub Actions + Cloud Build
✅ Testing:        Jest (backend) + Flutter test (frontend)
```

---

## Referencias Documentación

- [README - Descripción General](./README.md)
- [Características - Exploración](./features/exploration-mechanics.md)
- [Características - Tesoros](./features/treasure-hunt-radar.md)
- [Características - Ranking](./features/social-system.md)
- [Características - Hitos Comunitarios](./features/community-landmarks.md)
- [Privacidad](./features/privacy-settings.md)
- [Arquitectura Técnica](./technical/architecture.md)
- [Setup](./technical/setup.md)
- [API Reference](./technical/api-reference.md)

---

**Documento creado**: Abril 2026  
**Versión**: 1.0  
**Estado**: Aprobado para implementación  
**Próxima revisión**: Semana 2 (después de Fase 1)
