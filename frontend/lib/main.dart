import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'config/app_config.dart';
import 'core/database/app_database.dart';
import 'core/network/api_client.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/location_service.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/landmarks/data/datasources/landmark_remote_datasource.dart';
import 'features/landmarks/presentation/bloc/landmark_bloc.dart';
import 'features/landmarks/presentation/pages/landmarks_page.dart';
import 'features/map/data/datasources/map_remote_datasource.dart';
import 'features/map/presentation/bloc/map_bloc.dart';
import 'features/map/presentation/pages/map_page.dart';
import 'features/profile/data/datasources/medals_remote_datasource.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/ranking/data/datasources/ranking_remote_datasource.dart';
import 'features/ranking/presentation/bloc/ranking_bloc.dart';
import 'features/ranking/presentation/pages/ranking_page.dart';
import 'features/treasure/data/datasources/treasure_remote_datasource.dart';
import 'features/treasure/presentation/bloc/treasure_bloc.dart';
import 'features/treasure/presentation/pages/treasure_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await ConnectivityService.instance.initialize();

  final apiClient = ApiClient();
  final db = AppDatabase();
  final mapRemoteDs = MapRemoteDataSource(apiClient: apiClient);
  final syncService = SyncService(db: db, remoteDataSource: mapRemoteDs);

  runApp(MyApp(
    apiClient: apiClient,
    db: db,
    mapRemoteDs: mapRemoteDs,
    syncService: syncService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AppDatabase db;
  final MapRemoteDataSource mapRemoteDs;
  final SyncService syncService;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.db,
    required this.mapRemoteDs,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            remoteDataSource: AuthRemoteDataSource(apiClient: apiClient),
          )..add(const AuthCheckStatusEvent()),
        ),
        BlocProvider(
          create: (_) => MapBloc(
            remoteDataSource: mapRemoteDs,
            locationService: LocationService.instance,
            db: db,
            connectivityService: ConnectivityService.instance,
            syncService: syncService,
          ),
        ),
        BlocProvider(
          create: (_) => TreasureBloc(
            remoteDataSource:
                TreasureRemoteDataSourceImpl(apiClient: apiClient),
          ),
        ),
        BlocProvider(
          create: (_) => RankingBloc(
            remoteDataSource: RankingRemoteDataSource(apiClient: apiClient),
          ),
        ),
        BlocProvider(
          create: (_) => LandmarkBloc(
            remoteDataSource: LandmarkRemoteDataSource(apiClient: apiClient),
          ),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
            remoteDataSource: MedalsRemoteDataSource(apiClient: apiClient),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        if (current is AuthLoading &&
            (previous is AuthUnauthenticated || previous is AuthError)) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const _MainApp();
        }
        if (state is AuthUnauthenticated || state is AuthError) {
          return const _AuthFlow();
        }
        return const _SplashScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: AppTheme.primaryColor),
            SizedBox(height: 24),
            Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _AuthFlow extends StatefulWidget {
  const _AuthFlow();

  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    if (_showRegister) {
      return RegisterPage(
        onNavigateToLogin: () => setState(() => _showRegister = false),
      );
    }
    return LoginPage(
      onNavigateToRegister: () => setState(() => _showRegister = true),
    );
  }
}

class _MainApp extends StatefulWidget {
  const _MainApp();

  @override
  State<_MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<_MainApp> {
  int _currentIndex = 0;

  static const _tabs = [
    MapPage(),
    TreasurePage(),
    RankingPage(),
    LandmarksPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar),
            label: 'Tesoros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Landmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
