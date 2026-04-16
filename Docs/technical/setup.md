# Guía de Configuración: LoneWalker

## Requisitos Previos

### Para Desarrollo Mobile (Frontend)
```
- Flutter 3.10+ (si usas Flutter)
  o
- React Native 0.72+ (si usas React Native)
- Android Studio / Xcode
- Emulador Android / iOS Simulator
- Git
```

### Para Backend
```
- Node.js 18+ o Python 3.10+
- PostgreSQL 14+
- Redis 7+
- Docker (opcional)
```

### Para Producción
```
- Servidor Linux (Ubuntu 20.04 LTS recomendado)
- Dominio propio
- SSL/TLS (Let's Encrypt)
- Base de datos PostgreSQL
- Redis para cache
- Storage S3 o equivalent
```

## 1. Configuración del Desarrollo Local

### 1.1 Clonar el Repositorio

```bash
git clone https://github.com/vrhino/lonewalker.git
cd lonewalker
```

### 1.2 Configuración del Backend

#### Instalación de Dependencias
```bash
cd backend
npm install
# o
pip install -r requirements.txt
```

#### Variables de Entorno
Crear archivo `.env`:
```env
# Servidor
PORT=3000
NODE_ENV=development

# Base de Datos
DB_HOST=localhost
DB_PORT=5432
DB_NAME=lonewalker_dev
DB_USER=postgres
DB_PASSWORD=yourpassword

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your_super_secret_key_change_this
JWT_EXPIRATION=3600
REFRESH_TOKEN_EXPIRATION=604800

# Google Maps API
GOOGLE_MAPS_API_KEY=your_google_maps_key

# Firebase
FIREBASE_PROJECT_ID=your_firebase_project
FIREBASE_PRIVATE_KEY=your_firebase_key
FIREBASE_CLIENT_EMAIL=your_firebase_email

# AWS S3
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_S3_BUCKET=lonewalker-dev
AWS_REGION=eu-west-1
```

#### Inicializar Base de Datos
```bash
# Crear base de datos
createdb lonewalker_dev

# Ejecutar migraciones
npm run migrate:up
# o
alembic upgrade head
```

#### Iniciar Servidor
```bash
npm run dev
# o
uvicorn main:app --reload
```

El servidor estará en `http://localhost:3000`

### 1.3 Configuración del Frontend

#### Instalación de Dependencias
```bash
cd frontend
flutter pub get
# o
npm install
```

#### Configurar Archivo de Configuración
Crear `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:3000/api/v1';
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_KEY';
  static const String environment = 'development';
  static const bool enableDebugLogging = true;
}
```

#### Correr en Emulador/Simulator
```bash
# Android
flutter run -d emulator-5554

# iOS
flutter run -d iPhone
```

### 1.4 Base de Datos Local (SQLite)

#### Inicializar en Frontend
```dart
// El sistema SQLite se inicializa automáticamente
// al primer inicio de la aplicación
// Localización: /data/data/com.vrhino.lonewalker/databases/ (Android)
//              /Library/Application Support/lonewalker/ (iOS)
```

## 2. Docker Setup (Recomendado para Desarrollo)

### 2.1 Dockerfile para Backend
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000
CMD ["npm", "start"]
```

### 2.2 docker-compose.yml
```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=postgres
      - DB_NAME=lonewalker_dev
      - DB_USER=postgres
      - DB_PASSWORD=devpassword
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: lonewalker_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: devpassword
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

#### Iniciar con Docker Compose
```bash
docker-compose up -d
```

## 3. Configuración de APIs Externas

### 3.1 Google Maps API

1. Ir a [Google Cloud Console](https://console.cloud.google.com/)
2. Crear nuevo proyecto
3. Habilitar APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Maps Static API
   - Maps Embed API
4. Crear credenciales (API Key)
5. Restringir a:
   - Android (SHA-1 fingerprint)
   - iOS (Bundle ID)
   - Web (dominio)

### 3.2 Firebase Configuration

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Descargar `google-services.json` (Android)
3. Descargar `GoogleService-Info.plist` (iOS)
4. Habilitar:
   - Authentication (Google Sign-In)
   - Cloud Messaging (Push)
   - Cloud Storage (Archivos)
5. Copiar configuración a `backend/config/firebase.js`

### 3.3 AWS S3 Configuration

1. Crear cuenta AWS
2. Crear bucket S3:
   ```bash
   aws s3 mb s3://lonewalker-dev --region eu-west-1
   ```
3. Configurar CORS:
   ```json
   [
     {
       "AllowedHeaders": ["*"],
       "AllowedMethods": ["GET", "PUT", "POST"],
       "AllowedOrigins": ["*"],
       "ExposeHeaders": ["ETag"]
     }
   ]
   ```
4. Crear usuario IAM con permisos S3
5. Guardar Access Key y Secret en `.env`

## 4. Testing

### Backend Tests
```bash
# Unit tests
npm run test

# Integration tests
npm run test:integration

# Coverage
npm run test:coverage
```

### Frontend Tests
```bash
# Tests unitarios
flutter test

# Integration tests
flutter test integration_test/
```

## 5. Debugging

### Backend
```bash
# Habilitar debug logs
DEBUG=lonewalker:* npm run dev

# Inspector de Base de Datos
pgAdmin: http://localhost:5050
# Usuario: admin@example.com
# Contraseña: admin
```

### Frontend
```dart
// Agregar en main.dart para logs
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug mode enabled');
}
```

## 6. Configuración de Producción

### 6.1 Variables de Entorno Producción
```env
PORT=3000
NODE_ENV=production
DB_HOST=prod-db.example.com
DB_NAME=lonewalker_prod
DB_USER=db_user
DB_PASSWORD=secure_password_here
REDIS_HOST=prod-redis.example.com
JWT_SECRET=production_secret_key_very_secure
GOOGLE_MAPS_API_KEY=production_key
```

### 6.2 Deploy con Heroku (Ejemplo)
```bash
# Instalar Heroku CLI
# Crear app
heroku create lonewalker-app

# Configurable vars
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=...

# Deploy
git push heroku main
```

### 6.3 Deploy con Docker (Kubernetes)
```bash
# Build imagen
docker build -t lonewalker-backend:1.0 ./backend

# Push a registry
docker tag lonewalker-backend:1.0 registry.example.com/lonewalker:1.0
docker push registry.example.com/lonewalker:1.0

# Deployment YAML
kubectl apply -f k8s/deployment.yaml
```

## 7. Monitoreo y Logs

### Backend Logging
```javascript
// Usar logger centralizado
const logger = require('./utils/logger');

logger.info('Server started', { port: 3000 });
logger.error('Database error', { error: err });
```

### Monitoring
```
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- ELK Stack para logs centralizados
```

## 8. Checklist Pre-Lanzamiento

- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integración pasando
- [ ] Variables de entorno configuradas
- [ ] HTTPS habilitado
- [ ] CORS configurado correctamente
- [ ] Rate limiting activo
- [ ] Backups de BD configurados
- [ ] Logs centralizados
- [ ] Monitoreo activo
- [ ] Plan de rollback documentado
- [ ] Documentación API actualizada
- [ ] Seguridad: OWASP Top 10 revisado

## 9. Troubleshooting

### Error: "ECONNREFUSED" para PostgreSQL
```bash
# Verificar si PostgreSQL está corriendo
pg_isready -h localhost -p 5432

# Si no está:
brew services start postgresql  # macOS
sudo service postgresql start   # Linux
```

### Error: "Redis connection refused"
```bash
# Verificar Redis
redis-cli ping

# Si no está corriendo:
redis-server
```

### Error: "Google Maps API key not valid"
- Verificar key en console.cloud.google.com
- Asegurar que la API esté habilitada
- Revisar restricciones de dominio/bundle

### Error: "Build failed" en Flutter
```bash
# Limpiar build
flutter clean

# Obtener dependencias nuevamente
flutter pub get

# Reconstruir
flutter run
```

---

**Última actualización**: Abril 2026
**Versión**: 2.0
