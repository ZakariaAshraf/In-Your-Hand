import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_your_hand/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:in_your_hand/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:in_your_hand/features/orders/presentation/cubit/payments_cubit.dart';
import 'package:in_your_hand/features/home/presentation/screens/home_screen.dart';
import 'package:in_your_hand/features/orders/presentation/cubit/orders_cubit.dart';
import 'core/cache/cache_helper.dart';
import 'core/config/app_status_service.dart';
import 'core/config/screens/force_update_screen.dart';
import 'core/config/screens/maintenance_screen.dart';
import 'core/premium/ai_quota_service.dart';
import 'core/premium/premium_service.dart';
import 'core/premium/revenuecat_service.dart';
import 'core/session/session_bootstrap.dart';
import 'core/services/mobile_ads_initializer.dart';
import 'core/session/session_cubit.dart';
import 'core/sync/auth_sync_coordinator.dart';
import 'core/sync/sync_engine.dart';
import 'core/locale/providers/locale_provider.dart';
import 'core/themes/providers/theme_provider.dart';
import 'core/themes/text_theme.dart';
import 'features/authenticate/data/repositories/auth_repository_impl.dart';
import 'features/authenticate/domain/use_cases/auth_usecases.dart';
import 'features/authenticate/presentation/manager/auth_cubit.dart';
import 'features/authenticate/presentation/pages/sign_in.dart';
import 'features/authenticate/presentation/pages/sign_up.dart';
import 'features/settings/presentation/Cubit/user_cubit.dart';
import 'features/business_profile/data/datasources/business_profile_remote_data_source_firestore.dart';
import 'features/business_profile/data/repositories/business_profile_repository_prefs.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'main_screen.dart';
import 'features/clients/data/datasources/clients_local_data_source_sqflite.dart';
import 'features/clients/data/datasources/clients_remote_data_source_firestore.dart';
import 'features/clients/data/repositories/offline_first_clients_repository.dart';
import 'features/clients/domain/repositories/clients_repository.dart';
import 'features/orders/data/datasources/orders_local_data_source_sqflite.dart';
import 'features/orders/data/datasources/orders_remote_data_source_firestore.dart';
import 'features/orders/data/datasources/payments_local_data_source_sqflite.dart';
import 'features/orders/data/datasources/payments_remote_data_source_firestore.dart';
import 'features/orders/data/repositories/offline_first_orders_repository.dart';
import 'features/orders/data/repositories/offline_first_payments_repository.dart';
import 'features/orders/domain/repositories/orders_repository.dart';
import 'features/orders/domain/repositories/payments_repository.dart';

/// Shared for [FirebaseAnalyticsObserver] in [MaterialApp.navigatorObservers].
final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeMobileAds();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await CacheHelper.init();
  // Guest workspace + optional restored Firebase session before first frame.
  final sessionContext = await SessionBootstrap.load();

  final startupGate = await AppStatusService.instance.evaluate();
  final Widget initialHome = switch (startupGate) {
    AppStartupMaintenance() => const MaintenanceScreen(),
    AppStartupForceUpdate(:final storeUrl) =>
      ForceUpdateScreen(storeUrl: storeUrl),
    AppStartupOk() => CacheHelper.isOnboardingSeen
        ? const MainScreen()
        : const OnboardingScreen(),
  };

  if (startupGate is AppStartupOk) {
    await RevenueCatService.instance.init(sessionContext.workspaceId);
    await PremiumService.init();
  }

  runApp(ProviderScope(child: MyApp(initialHome: initialHome)));
}

class MyApp extends ConsumerWidget {
  /// Root after bootstrap ([MainScreen]) or first-time onboarding.
  final Widget initialHome;

  // Cannot be const: [initialHome] is chosen at startup from persisted prefs.
  // ignore: prefer_const_constructors_in_immutables
  MyApp({super.key, required this.initialHome});

  @override
  Widget build(BuildContext context, ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    final clientsLocalDs = ClientsLocalDataSourceSqflite();
    final ordersLocalDs = OrdersLocalDataSourceSqflite();
    final paymentsLocalDs = PaymentsLocalDataSourceSqflite();

    final clientsRemoteDs = ClientsRemoteDataSourceFirestore();
    final ordersRemoteDs = OrdersRemoteDataSourceFirestore();
    final paymentsRemoteDs = PaymentsRemoteDataSourceFirestore();
    final businessProfileRemoteDs =
        BusinessProfileRemoteDataSourceFirestore();

    final businessProfileRepository =
        BusinessProfileRepositoryPrefs();

    final syncEngine = SyncEngine(
      clientsLocal: clientsLocalDs,
      ordersLocal: ordersLocalDs,
      paymentsLocal: paymentsLocalDs,
      clientsRemote: clientsRemoteDs,
      ordersRemote: ordersRemoteDs,
      paymentsRemote: paymentsRemoteDs,
      businessProfileRepository: businessProfileRepository,
      businessProfileRemote: businessProfileRemoteDs,
    );

    final authSyncCoordinator = AuthSyncCoordinator(engine: syncEngine);

    final sessionCubit = SessionCubit(
      onAuthenticatedPendingUpload: (uid) =>
          authSyncCoordinator.runAuthenticatedFlow(uid),
    );

    final ClientsRepository clientsRepository = OfflineFirstClientsRepository(
      local: clientsLocalDs,
      remote: clientsRemoteDs,
    );
    final OrdersRepository ordersRepository = OfflineFirstOrdersRepository(
      local: ordersLocalDs,
      remote: ordersRemoteDs,
    );
    final PaymentsRepository paymentsRepository = OfflineFirstPaymentsRepository(
      local: paymentsLocalDs,
      remote: paymentsRemoteDs,
    );
    final clientsCubit = ClientsCubit(
      repository: clientsRepository,
      sessionCubit: sessionCubit,
    );
    final ordersCubit = OrdersCubit(
      repository: ordersRepository,
      sessionCubit: sessionCubit,
    );
    final paymentsCubit = PaymentsCubit(
      paymentsRepository: paymentsRepository,
      ordersRepository: ordersRepository,
      sessionCubit: sessionCubit,
    );
    final dashboardCubit = DashboardCubit(
      ordersRepository: ordersRepository,
      sessionCubit: sessionCubit,
    );

    final AiQuotaService aiQuotaService = AiQuotaService();
    const PremiumService premiumService = PremiumService();

    Future<void> onLocalDatabaseCleared() async {
      paymentsCubit.resetAfterLocalDatabaseReset();
      await Future.wait<Object?>([
        clientsCubit.refreshAfterLocalDatabaseReset(),
        ordersCubit.refreshAfterLocalDatabaseReset(),
        dashboardCubit.refreshAfterLocalDatabaseReset(),
      ]);
    }

    final userCubit = UserCubit(
      businessProfileRepository: businessProfileRepository,
      sessionCubit: sessionCubit,
      onLocalDatabaseCleared: onLocalDatabaseCleared,
    );

    authSyncCoordinator.attachRefreshAll(() async {
      paymentsCubit.resetAfterLocalDatabaseReset();
      await Future.wait<Object?>([
        clientsCubit.refreshAfterLocalDatabaseReset(),
        ordersCubit.refreshAfterLocalDatabaseReset(),
        dashboardCubit.refreshAfterLocalDatabaseReset(),
        userCubit.loadProfile(),
      ]);
    });


    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AiQuotaService>.value(value: aiQuotaService),
        RepositoryProvider<PremiumService>.value(value: premiumService),
        RepositoryProvider<ClientsRepository>.value(value: clientsRepository),
        RepositoryProvider<OrdersRepository>.value(value: ordersRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: sessionCubit),
          BlocProvider(
            create: (context) {
              final authRepository = FirebaseAuthRepository();
              return AuthCubit(
                signInUseCase: SignInUseCase(authRepository),
                registerUseCase: RegisterUseCase(authRepository),
                completeGoogleProfileUseCase:
                    CompleteGoogleProfileUseCase(authRepository),
                signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepository),
                userDocumentExistsUseCase:
                    UserDocumentExistsUseCase(authRepository),
                signOutUseCase: SignOutUseCase(authRepository),
              );
            },
          ),
          BlocProvider.value(value: clientsCubit),
          BlocProvider.value(value: ordersCubit),
          BlocProvider.value(value: paymentsCubit),
          BlocProvider.value(value: dashboardCubit),
          BlocProvider.value(value: userCubit),
        ],
        child: MaterialApp(
          builder: (context, child) {
            final currentTheme = Theme.of(context);
            final isDark = currentTheme.brightness == Brightness.dark;
            return Theme(
              data: currentTheme.copyWith(
                primaryColor: Colors.green,
                textTheme: isDark
                    ? AppTextTheme.darkTextTheme(context)
                    : AppTextTheme.lightTextTheme(context),
              ),
              child: child!,
            );
          },
          title: 'In Your Hand',
          home: initialHome,
          routes: {
            "/onboarding": (context) => const OnboardingScreen(),
            "/signIn": (context) => const SignIn(),
            "/signUp": (context) => const SignUp(),
            // "/wrapper": (context) => const AuthWrapper(),
            "/home": (context) => HomeScreen(),
            "/main_screen": (context) => const MainScreen(),
          },
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          themeMode: theme,
          darkTheme: ThemeData.dark(),
          theme: ThemeData.light(),
          navigatorObservers: <NavigatorObserver>[
            FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
          ],
        ),
      ),
    );
  }
}
