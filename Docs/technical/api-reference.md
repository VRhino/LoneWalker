# Referencia de API - LoneWalker

## Información General

**Base URL**: `https://api.lonewalker.com/api/v1`

**Autenticación**: JWT Token en header `Authorization: Bearer {token}`

**Response Format**: JSON

**Rate Limits**:
- GET requests: 500/min
- POST requests: 100/min
- Rate limit headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`

## 1. Autenticación (Auth Endpoints)

### Registrar Usuario
```http
POST /auth/register
Content-Type: application/json

{
  "username": "explorador123",
  "email": "user@example.com",
  "password": "SecurePass123!",
  "privacy_mode": "PUBLIC"
}
```

**Respuesta 201**:
```json
{
  "user": {
    "id": "uuid-1234",
    "username": "explorador123",
    "email": "user@example.com",
    "privacy_mode": "PUBLIC",
    "created_at": "2026-04-16T10:30:00Z"
  },
  "tokens": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

**Errores**:
- `400`: Usuario o email ya existe
- `422`: Validación fallida

---

### Iniciar Sesión
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Respuesta 200**:
```json
{
  "user": {
    "id": "uuid-1234",
    "username": "explorador123",
    "email": "user@example.com",
    "avatar_url": "https://...",
    "privacy_mode": "PUBLIC"
  },
  "tokens": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

**Errores**:
- `401`: Email o contraseña incorrectos
- `429`: Demasiados intentos de login (5 en 15 min)

---

### Renovar Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGc..."
}
```

**Respuesta 200**:
```json
{
  "access_token": "eyJhbGc...",
  "expires_in": 3600
}
```

---

### Cerrar Sesión
```http
POST /auth/logout
Authorization: Bearer {access_token}
```

**Respuesta 204**: Sin contenido

---

## 2. Exploración (Map Endpoints)

### Registrar Exploración
```http
POST /exploration
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "latitude": 40.4168,
  "longitude": -3.7038,
  "accuracy_meters": 15,
  "speed_kmh": 1.5,
  "timestamp": "2026-04-16T14:30:00Z"
}
```

**Respuesta 201**:
```json
{
  "exploration_id": "exp-uuid",
  "new_areas_cleared": 2,
  "xp_earned": 50,
  "fog_updated": true,
  "current_progress": {
    "exploration_percent": 23.5,
    "districts_mastered": 1
  }
}
```

**Reglas de Negocio**:
- Si `speed_kmh > 20`: Solicitud rechazada con `400`
- GPS accuracy debe ser < 50m
- Solo se registra 1 por minuto máximo

---

### Obtener Progreso de Exploración
```http
GET /exploration/progress
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "user_id": "uuid-1234",
  "exploration_percent": 45.3,
  "districts_explored": [
    {
      "district_id": "madrid_001",
      "name": "Centro Histórico",
      "exploration_percent": 87.5,
      "mastery_level": "GOLD",
      "completed_at": "2026-04-10T00:00:00Z"
    }
  ],
  "total_xp": 5420,
  "medals_earned": 8,
  "last_exploration": "2026-04-16T14:30:00Z"
}
```

---

### Obtener Mapa de Exploración
```http
GET /exploration/map?lat=40.4168&lng=-3.7038&zoom=15
Authorization: Bearer {access_token}
```

**Parámetros Query**:
- `lat`: Latitud (requerido)
- `lng`: Longitud (requerido)
- `zoom`: Nivel de zoom (1-20, default=15)
- `include_fog`: Incluir capas de niebla (default=true)
- `include_pois`: Incluir puntos de interés (default=true)

**Respuesta 200**:
```json
{
  "center": {
    "latitude": 40.4168,
    "longitude": -3.7038
  },
  "zoom": 15,
  "fog_of_war": {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[...]]
        },
        "properties": {
          "explored": true,
          "last_visited": "2026-04-16T14:30:00Z"
        }
      }
    ]
  },
  "points_of_interest": [...]
}
```

---

### Descargar Tiles de Mapa
```http
GET /map/tiles/{z}/{x}/{y}.png
Authorization: Bearer {access_token} (opcional para offline)
```

**Parámetros**:
- `z`: Zoom level (0-20)
- `x`, `y`: Tile coordinates

**Respuesta 200**: Imagen PNG

**Caching**: 
- `Cache-Control: public, max-age=2592000` (30 días)
- CDN habilitado

---

## 3. Tesoros (Treasure Endpoints)

### Listar Tesoros Cercanos
```http
GET /treasures?lat=40.4168&lng=-3.7038&radius=500
Authorization: Bearer {access_token}
```

**Parámetros Query**:
- `lat`, `lng`: Centro (requerido)
- `radius`: Radio en metros (default=1000, max=5000)
- `status`: Filtrar por estado (ACTIVE, DEPLETED, ARCHIVED)
- `rarity`: Filtrar por rareza

**Respuesta 200**:
```json
{
  "treasures": [
    {
      "id": "treasure-uuid",
      "title": "Moneda Antigua del Retiro",
      "creator": {
        "username": "YouTuberMadrid",
        "avatar_url": "https://..."
      },
      "latitude": 40.4158,
      "longitude": -3.6878,
      "distance_meters": 245,
      "status": "ACTIVE",
      "rarity": "RARE",
      "uses_remaining": 2,
      "uses_total": 5,
      "rewards": {
        "xp": 250,
        "medal": {
          "id": "medal-uuid",
          "name": "Buscador de Rarezas",
          "rarity": "RARE"
        },
        "stl_file": "https://s3.../moneda.stl"
      },
      "radar_active": false,
      "created_at": "2026-04-01T00:00:00Z"
    }
  ],
  "count": 3,
  "total": 15
}
```

---

### Obtener Detalles del Tesoro
```http
GET /treasures/{treasure_id}
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "id": "treasure-uuid",
  "title": "Moneda Antigua del Retiro",
  "description": "Una moneda del siglo XVIII escondida en el Retiro",
  "creator": {
    "id": "user-uuid",
    "username": "YouTuberMadrid",
    "avatar_url": "https://..."
  },
  "location": {
    "latitude": 40.4158,
    "longitude": -3.6878,
    "address": "Parque del Retiro, Madrid"
  },
  "status": "ACTIVE",
  "rarity": "RARE",
  "clues": "Busca cerca del lago, hacia el lado este",
  "uses": {
    "total": 5,
    "remaining": 2,
    "claimed_by": 3
  },
  "rewards": {
    "xp": 250,
    "medal": { ... },
    "stl_file": "https://s3.../moneda.stl"
  },
  "created_at": "2026-04-01T00:00:00Z",
  "updated_at": "2026-04-15T10:30:00Z"
}
```

---

### Crear Tesoro (Treasure Maker)
```http
POST /treasures
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "Tesoro Especial",
  "description": "Descripción del tesoro",
  "latitude": 40.4158,
  "longitude": -3.6878,
  "clues": "Pistas para encontrarlo",
  "max_uses": 5,
  "rarity": "RARE",
  "stl_file_url": "https://s3.../modelo.stl",
  "medal_name": "Buscador Especial"
}
```

**Respuesta 201**:
```json
{
  "id": "treasure-uuid",
  "title": "Tesoro Especial",
  "status": "ACTIVE",
  "created_at": "2026-04-16T14:30:00Z"
}
```

**Errores**:
- `403`: No eres un Treasure Maker verificado
- `422`: Datos de validación fallida

---

### Reclamar Tesoro
```http
POST /treasures/{treasure_id}/claim
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "latitude": 40.4157,
  "longitude": -3.6879,
  "accuracy_meters": 8,
  "timestamp": "2026-04-16T14:32:00Z"
}
```

**Respuesta 201**:
```json
{
  "claim_id": "claim-uuid",
  "treasure_id": "treasure-uuid",
  "success": true,
  "rewards": {
    "xp": 250,
    "medal": {
      "id": "medal-uuid",
      "name": "Buscador de Rarezas",
      "rarity": "RARE",
      "unlocked_at": "2026-04-16T14:32:00Z"
    },
    "stl_download_url": "https://s3.../moneda.stl"
  },
  "treasure_status": "ACTIVE",
  "remaining_uses": 1,
  "wall_of_fame_position": 3
}
```

**Errores**:
- `400`: Posición no válida (> 10m del tesoro)
- `403`: Tesoro ya reclamado por este usuario
- `410`: Tesoro agotado
- `422`: GPS accuracy insuficiente

---

### Obtener Muro de Fama
```http
GET /treasures/{treasure_id}/wall-of-fame
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "treasure_id": "treasure-uuid",
  "treasure_title": "Moneda Antigua del Retiro",
  "status": "DEPLETED",
  "total_claimed": 5,
  "wall": [
    {
      "position": 1,
      "username": "ExploradorPro",
      "claimed_at": "2026-04-05T10:00:00Z",
      "xp_earned": 250,
      "avatar_url": "https://..."
    },
    ...
  ]
}
```

---

## 4. Ranking (Ranking Endpoints)

### Ranking Global
```http
GET /ranking/global?limit=100&offset=0
Authorization: Bearer {access_token}
```

**Parámetros Query**:
- `limit`: Resultados por página (default=50, max=100)
- `offset`: Paginación (default=0)
- `sort_by`: Campo para ordenar (default=score)

**Respuesta 200**:
```json
{
  "rankings": [
    {
      "rank": 1,
      "user": {
        "id": "user-uuid",
        "username": "AlexWalker",
        "avatar_url": "https://..."
      },
      "stats": {
        "exploration_percent": 87.3,
        "treasures_found": 12,
        "xp_total": 15420,
        "medals_earned": 8
      },
      "score": 875.5,
      "your_position": false
    },
    ...
  ],
  "total_users": 15000,
  "your_rank": 523,
  "your_score": 245.3
}
```

---

### Ranking de Distrito
```http
GET /ranking/district/{district_id}?limit=50
Authorization: Bearer {access_token}
```

**Parámetros**:
- `district_id`: ID del distrito (requerido)
- `limit`: Resultados (default=50)

**Respuesta 200**: Similar al ranking global

---

### Ranking Semanal
```http
GET /ranking/weekly
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "period": {
    "start": "2026-04-14T00:00:00Z",
    "end": "2026-04-20T23:59:59Z",
    "week_number": 16,
    "year": 2026
  },
  "rankings": [...],
  "resets_at": "2026-04-21T00:00:00Z",
  "your_position": 42
}
```

---

### Mi Posición en Ranking
```http
GET /ranking/position
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "global": {
    "rank": 523,
    "total_users": 15000,
    "percentile": 96.5,
    "score": 245.3
  },
  "districts": [
    {
      "district_id": "madrid_001",
      "district_name": "Centro",
      "rank": 145,
      "total_in_district": 8500
    }
  ],
  "weekly": {
    "rank": 1523,
    "score_this_week": 45.3
  }
}
```

---

## 5. Perfil de Usuario (User Endpoints)

### Obtener Mi Perfil
```http
GET /users/me
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "id": "user-uuid",
  "username": "explorador123",
  "email": "user@example.com",
  "avatar_url": "https://...",
  "bio": "Explorador de Madrid",
  "privacy_mode": "PUBLIC",
  "stats": {
    "exploration_percent": 45.3,
    "treasures_found": 8,
    "xp_total": 5420,
    "medals_earned": 5,
    "ranking_position": 523
  },
  "preferences": {
    "notifications_enabled": true,
    "haptics_enabled": true,
    "dark_mode": true
  },
  "created_at": "2026-01-15T00:00:00Z",
  "updated_at": "2026-04-16T14:30:00Z"
}
```

---

### Actualizar Mi Perfil
```http
PUT /users/me
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "username": "newusername",
  "bio": "Nueva biografía",
  "avatar_url": "https://s3.../avatar.jpg",
  "privacy_mode": "PRIVATE",
  "preferences": {
    "notifications_enabled": true,
    "haptics_enabled": false
  }
}
```

**Respuesta 200**: Perfil actualizado

**Errores**:
- `409`: Username ya existe
- `422`: Validación fallida

---

### Ver Perfil Público
```http
GET /users/{user_id}
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "id": "user-uuid",
  "username": "AlexWalker",
  "avatar_url": "https://...",
  "bio": "Explorador de Madrid",
  "stats": {
    "exploration_percent": 87.3,
    "treasures_found": 12,
    "medals_earned": 8
  },
  "ranking_position": 1,
  "is_friend": false,
  "friend_status": "NONE"
}
```

**Nota**: Si usuario está en modo PRIVATE, solo muestra info básica

---

### Mis Medallas
```http
GET /users/me/medals
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "medals": [
    {
      "id": "medal-uuid",
      "name": "Conquistador del Centro",
      "description": "Explorar 100% Centro Histórico",
      "rarity": "LEGENDARY",
      "icon_url": "https://...",
      "unlocked_at": "2026-04-10T00:00:00Z",
      "progress": 100
    },
    {
      "id": "medal-uuid-2",
      "name": "Buscador Raras",
      "description": "Encontrar 10 tesoros raros",
      "rarity": "EPIC",
      "icon_url": "https://...",
      "unlocked_at": null,
      "progress": 6
    }
  ],
  "total_earned": 8,
  "total_available": 45
}
```

---

## 6. Amigos (Friends Endpoints)

### Enviar Solicitud de Amistad
```http
POST /users/me/friends/request
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "user_id": "friend-uuid"
}
```

**Respuesta 201**:
```json
{
  "request_id": "req-uuid",
  "from_user": "uuid-1234",
  "to_user": "friend-uuid",
  "status": "PENDING",
  "created_at": "2026-04-16T14:30:00Z"
}
```

---

### Aceptar Solicitud de Amistad
```http
POST /users/me/friends/request/{request_id}/accept
Authorization: Bearer {access_token}
```

**Respuesta 200**: Amistad establecida

---

### Listar Amigos
```http
GET /users/me/friends
Authorization: Bearer {access_token}
```

**Respuesta 200**:
```json
{
  "friends": [
    {
      "id": "friend-uuid",
      "username": "AmigoDeMadrid",
      "avatar_url": "https://...",
      "exploration_percent": 56.2,
      "treasures_found": 5,
      "last_seen": "2026-04-16T10:00:00Z"
    }
  ],
  "total": 12
}
```

---

## 7. Códigos de Estado HTTP

| Código | Significado | Ejemplo |
|--------|-------------|---------|
| 200 | OK | GET exitoso |
| 201 | Created | POST exitoso |
| 204 | No Content | DELETE exitoso |
| 400 | Bad Request | Validación fallida |
| 401 | Unauthorized | Token inválido/expirado |
| 403 | Forbidden | No tienes permiso |
| 404 | Not Found | Recurso no existe |
| 409 | Conflict | Usuario existe |
| 422 | Unprocessable Entity | Datos inválidos |
| 429 | Too Many Requests | Rate limit excedido |
| 500 | Internal Error | Error del servidor |

---

## 8. Ejemplo de Uso Completo

```javascript
// 1. Registrarse
const registerResponse = await fetch('https://api.lonewalker.com/api/v1/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'explorer123',
    email: 'user@example.com',
    password: 'SecurePass123!'
  })
});

const { tokens } = await registerResponse.json();
const accessToken = tokens.access_token;

// 2. Registrar exploración
const explorationResponse = await fetch('https://api.lonewalker.com/api/v1/exploration', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    latitude: 40.4168,
    longitude: -3.7038,
    accuracy_meters: 10,
    speed_kmh: 1.5
  })
});

// 3. Obtener progreso
const progressResponse = await fetch('https://api.lonewalker.com/api/v1/exploration/progress', {
  headers: { 'Authorization': `Bearer ${accessToken}` }
});

const progress = await progressResponse.json();
console.log(`Exploración: ${progress.exploration_percent}%`);
```

---

**Última actualización**: Abril 2026
**Versión API**: 1.0
**Changelog**: [Ver changelog](./API_CHANGELOG.md)
