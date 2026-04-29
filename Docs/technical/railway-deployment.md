# Despliegue en Railway

Guía paso a paso para desplegar el backend de LoneWalker en [Railway](https://railway.app) para pruebas y staging.

## Requisitos previos

- Cuenta en [railway.app](https://railway.app) (puedes entrar con GitHub)
- Repositorio de LoneWalker en GitHub

---

## 1. Crear el proyecto en Railway

1. Inicia sesión en Railway → botón **New Project**
2. Selecciona **Deploy from GitHub repo**
3. Autoriza Railway a acceder a tu cuenta de GitHub y selecciona el repositorio `LoneWalker`

---

## 2. Añadir PostgreSQL con PostGIS

El backend requiere PostgreSQL **con la extensión PostGIS**. Railway provee PostgreSQL estándar y PostGIS se habilita manualmente.

1. En el proyecto → **+ New** → **Database** → **Add PostgreSQL**
2. Una vez creado el plugin, ve a su pestaña **Query** y ejecuta:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```

3. Verifica que funcionó:

```sql
SELECT PostGIS_Version();
```

Deberías ver algo como `3.4 USE_GEOS=1 ...`.

---

## 3. Configurar el servicio del backend

1. En el proyecto ya debería haberse creado un servicio desde el repo. Si no, **+ New** → **GitHub Repo**
2. Ve a **Settings** del servicio:
   - **Root Directory**: `backend`
   - Railway detecta el `Dockerfile` automáticamente gracias al `railway.toml`
3. En la pestaña **Networking** → **Generate Domain** para obtener la URL pública (la necesitarás en el paso 4)

---

## 4. Variables de entorno

Ve a la pestaña **Variables** del servicio del backend y añade las siguientes:

### Variables de referencia del plugin PostgreSQL

Haz clic en **+ New Variable** → **Add Reference**:

| Variable en el servicio | Referencia al plugin |
|---|---|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` |

Railway inyecta `PORT` automáticamente — no hace falta configurarlo.

### Variables que debes configurar manualmente

| Variable | Valor |
|---|---|
| `NODE_ENV` | `production` |
| `JWT_SECRET` | Cadena aleatoria larga (ver abajo cómo generarla) |
| `JWT_EXPIRATION` | `3600` |
| `REFRESH_TOKEN_EXPIRATION` | `604800` |
| `DB_SYNCHRONIZE` | `true` *(solo para testing — crea las tablas automáticamente)* |
| `DB_LOGGING` | `false` |
| `CORS_ORIGIN` | La URL pública de Railway del servicio, p.ej. `https://lonewalker-backend.up.railway.app` |
| `CORS_CREDENTIALS` | `true` |

**Generar JWT_SECRET** (ejecuta esto en tu terminal local):

```bash
openssl rand -hex 64
```

---

## 5. Desplegar

Railway despliega automáticamente al guardar las variables. Si quieres forzarlo manualmente:

1. Ve a la pestaña **Deployments**
2. Botón **Deploy** → **Deploy Latest Commit**

El primer build tarda ~3-5 minutos (pnpm install + compilación TypeScript).

Puedes seguir el progreso en tiempo real en los logs del deployment.

---

## 6. Verificar que funciona

Una vez desplegado, verifica estos endpoints en el navegador o con curl:

```bash
# Health check básico
curl https://TU_DOMINIO.up.railway.app/

# Health check de la API
curl https://TU_DOMINIO.up.railway.app/api/v1/health

# Swagger — documentación interactiva de todos los endpoints
# Abre en el navegador:
https://TU_DOMINIO.up.railway.app/api/docs
```

Todos deberían devolver respuesta 200.

---

## 7. Configurar la app Flutter para apuntar a Railway

En el build de Android/iOS, pasa la URL de Railway como variable de compilación:

```bash
# Build de APK apuntando a Railway
flutter build apk \
  --dart-define=API_BASE_URL=https://TU_DOMINIO.up.railway.app/api/v1 \
  --dart-define=FLUTTER_ENVIRONMENT=staging
```

Para desarrollo local (hot reload) apuntando a Railway:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://TU_DOMINIO.up.railway.app/api/v1
```

---

## 8. Actualizaciones automáticas

Cada vez que hagas `git push` a la rama `main`, Railway detecta el cambio y redespliega automáticamente. No necesitas hacer nada más.

---

## Notas importantes

| Tema | Detalle |
|---|---|
| **DB_SYNCHRONIZE** | Déjalo en `true` para pruebas. Antes de pasar a producción real, crea migraciones con TypeORM y cámbialo a `false`. |
| **Free plan** | Railway incluye $5/mes de crédito. Un backend pequeño con PostgreSQL y sin Redis consume aproximadamente $3-4/mes. |
| **Logs** | Railway Dashboard → Deployments → ícono de logs. Muy útil para depurar errores en arranque. |
| **Variables secretas** | Nunca subas `.env` al repositorio. Usa siempre el dashboard de Railway para secretos. |
| **PostGIS** | Cada vez que el plugin de PostgreSQL se recree habrá que volver a ejecutar `CREATE EXTENSION IF NOT EXISTS postgis`. |

---

## Troubleshooting frecuente

**El deploy falla en el build**
→ Revisa que `backend/Dockerfile` existe y que el Root Directory está configurado como `backend` en Settings.

**Error `DB_PASSWORD is required` en los logs**
→ `DATABASE_URL` no está configurada como referencia al plugin de PostgreSQL. Verifica el paso 4.

**404 en todos los endpoints**
→ El servicio arrancó pero PostGIS no está habilitado y TypeORM falló al sincronizar. Ejecuta el `CREATE EXTENSION` del paso 2 y redespliega.

**CORS error desde la app Flutter**
→ `CORS_ORIGIN` no incluye el origen exacto desde donde la app hace las peticiones. Añade la URL que falta separada por coma.

**500 en `POST /exploration` — `unknown GeoJSON type` en los logs de PostgreSQL**
→ TypeORM genera `ST_GeomFromGeoJSON($6)` para columnas `geometry`, por lo que el valor debe ser GeoJSON (`{"type":"Point","coordinates":[lng,lat]}`), no WKT (`POINT(lng lat)`). Verifica que `buildGeoJsonPoint` en `geo.constants.ts` retorna `JSON.stringify(...)` y redespliega.
