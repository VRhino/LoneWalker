# 🗺️ LoneWalker

> **GPS-based exploration gamification app** - Discover your city like never before!

Transform ordinary walks into epic adventures. Explore your city, find hidden treasures, compete with friends, and unlock exclusive rewards.

---

## 📱 About LoneWalker

LoneWalker is a mobile application that gamifies urban exploration using GPS. Walk through your city, clear the Fog of War on the map, hunt for treasures, participate in a democratic voting system for community landmarks, and climb the global ranking.

**Key Features:**
- 🌫️ **Fog of War** - Explore to reveal hidden areas
- 🎯 **Treasure Hunt** - Find and claim hidden prizes with radar
- 🏆 **Ranking System** - Compete with friends and global explorers
- 🏛️ **Community Landmarks** - Vote for and propose POIs
- 🎖️ **Achievements** - Unlock medals and gain experience
- 🔒 **Privacy First** - Full control over your data

---

## 🚀 Quick Start

### Prerequisites

**Backend:**
- Node.js 18+
- PostgreSQL 14+
- Redis 7+
- Docker (optional)

**Frontend:**
- Flutter 3.16+
- Android Studio / Xcode

### Development Setup

#### 1. Clone Repository
```bash
git clone https://github.com/vrhino/lonewalker.git
cd lonewalker
```

#### 2. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Update .env with your configuration
nano .env
```

#### 3. Start Services (Docker)
```bash
# Start PostgreSQL and Redis
docker-compose up -d postgres redis

# Optional: Start pgAdmin for database management
docker-compose --profile dev up -d pgadmin
# Access at: http://localhost:5050
```

#### 4. Backend Setup
```bash
cd backend

# Install dependencies
npm install

# Run database migrations
npm run db:migrate

# Start development server
npm run start:dev

# API will be available at: http://localhost:3000
# Swagger docs at: http://localhost:3000/api/docs
```

#### 5. Frontend Setup
```bash
cd frontend

# Get Flutter dependencies
flutter pub get

# Run on emulator or device
flutter run

# Or build for specific platform
flutter run -d emulator-5554  # Android
flutter run -d iPhone          # iOS
```

---

## 📁 Project Structure

```
lonewalker/
├── backend/                    # NestJS + TypeScript backend
│   ├── src/
│   │   ├── main.ts            # Entry point
│   │   ├── app.module.ts       # Root module
│   │   ├── config/            # Configuration
│   │   └── modules/           # Feature modules (TBD)
│   ├── test/                  # Tests
│   ├── package.json
│   └── Dockerfile
├── frontend/                   # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart          # Entry point
│   │   ├── config/            # Configuration
│   │   ├── core/              # Core utilities
│   │   └── features/          # Feature modules (TBD)
│   ├── test/                  # Tests
│   └── pubspec.yaml
├── docs/                      # Documentation
│   ├── README.md              # Main documentation
│   ├── DEVELOPMENT_PLAN.md    # Development roadmap
│   ├── features/              # Feature specifications
│   └── technical/             # Technical documentation
├── .github/
│   └── workflows/             # CI/CD pipelines
├── docker-compose.yml         # Docker services
├── .env.example               # Environment template
└── .gitignore
```

---

## 🔧 Technology Stack

### Backend
```
Framework:     NestJS + Express (TypeScript)
Database:      PostgreSQL 14+ (with PostGIS)
Cache:         Redis 7+
ORM:           TypeORM
API Docs:      Swagger/OpenAPI
Testing:       Jest
```

### Frontend
```
Framework:     Flutter 3.16+
Language:      Dart
State Mgmt:    BLoC + Provider
Local DB:      SQLite + Drift
Maps:          Google Maps
Auth:          Firebase
```

### DevOps
```
Containerization: Docker
CI/CD:           GitHub Actions
Hosting:         Google Cloud Platform (GCP)
Monitoring:      Cloud Logging
```

---

## 📚 Documentation

- **[Full Documentation](./Docs/README.md)** - Comprehensive feature documentation
- **[Development Plan](./Docs/DEVELOPMENT_PLAN.md)** - 8-phase development roadmap
- **[Architecture](./Docs/technical/architecture.md)** - System architecture and design
- **[API Reference](./Docs/technical/api-reference.md)** - Complete API endpoints
- **[Setup Guide](./Docs/technical/setup.md)** - Detailed setup instructions
- **[Contributing](./Docs/CONTRIBUTING.md)** - How to contribute

---

## 🔄 Development Workflow

### Available Commands

**Backend:**
```bash
npm run start:dev        # Start development server with hot reload
npm run build            # Build for production
npm run test             # Run unit tests
npm run test:cov         # Run tests with coverage
npm run lint             # Check code style
npm run format           # Format code with Prettier
```

**Frontend:**
```bash
flutter run              # Run app on connected device/emulator
flutter test             # Run unit tests
flutter analyze          # Analyze code
dart format .            # Format code
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
```

---

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm run test             # Run all tests
npm run test:cov         # Coverage report
npm run test:watch       # Watch mode
```

### Frontend Tests
```bash
cd frontend
flutter test             # Run all tests
flutter test --coverage  # Coverage report
```

### CI/CD
Tests automatically run on:
- Push to `main` or `develop`
- Pull requests
- GitHub Actions workflows

---

## 🚢 Deployment

### Google Cloud Platform (GCP)

**Backend (Cloud Run):**
```bash
cd backend
gcloud builds submit --tag gcr.io/PROJECT_ID/lonewalker-backend
gcloud run deploy lonewalker-backend \
  --image gcr.io/PROJECT_ID/lonewalker-backend \
  --platform managed \
  --region europe-west1
```

**Database (Cloud SQL):**
```bash
# Proxy to local for testing
cloud_sql_proxy -instances=PROJECT:REGION:INSTANCE=tcp:5432
```

---

## 📊 Development Status

### Completed ✅
- [x] Project documentation
- [x] Development plan (8 phases)
- [x] Backend boilerplate (NestJS)
- [x] Frontend boilerplate (Flutter)
- [x] Docker setup
- [x] CI/CD pipelines

### In Progress 🔄
- Phase 1: Setup & Infrastructure (Current)
- Phase 2: Authentication (Next)
- Phase 3: Maps & Exploration

### Planned 📋
- Phase 4: Treasure Hunt
- Phase 5: Ranking
- Phase 6: Community Landmarks
- Phase 7: Gamification
- Phase 8: Testing & Integration

---

## 🤝 Contributing

We welcome contributions! Please see [Contributing Guide](./Docs/CONTRIBUTING.md) for details on:
- How to report bugs
- How to suggest features
- How to submit pull requests
- Code style guidelines

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

---

## 👥 Team

**Created by:** VRhino  
**Maintained by:** LoneWalker Community

---

## 📧 Contact & Support

- **Issues:** [GitHub Issues](https://github.com/vrhino/lonewalker/issues)
- **Discussions:** [GitHub Discussions](https://github.com/vrhino/lonewalker/discussions)
- **Documentation:** [Full Docs](./Docs/)
- **FAQ:** [Frequently Asked Questions](./Docs/FAQ.md)

---

## 🎯 Next Steps

**To get started with development:**

1. ✅ Clone repository and setup environment
2. ✅ Start Docker services
3. ✅ Run backend on localhost:3000
4. ✅ Run frontend on emulator/device
5. 📖 Read [Development Plan](./Docs/DEVELOPMENT_PLAN.md)
6. 🚀 Start Phase 2: Authentication

**Questions?** Check the [FAQ](./Docs/FAQ.md) or open a [discussion](https://github.com/vrhino/lonewalker/discussions).

---

**Made with ❤️ by explorers, for explorers**

🗺️ Discover. 🎯 Compete. 🏆 Conquer. 🎖️ Achieve.
