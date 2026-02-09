import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_your_hand/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:in_your_hand/features/home/presentation/screens/home_screen.dart';
import 'package:in_your_hand/features/orders/presentation/cubit/orders_cubit.dart';

import 'core/cache/cache_helper.dart';
import 'core/locale/providers/locale_provider.dart';
import 'core/themes/providers/theme_provider.dart';
import 'features/authenticate/data/repositories/auth_repository_impl.dart';
import 'features/authenticate/domain/use_cases/auth_usecases.dart';
import 'features/authenticate/presentation/manager/auth_cubit.dart';
import 'features/authenticate/presentation/pages/sign_in.dart';
import 'features/authenticate/presentation/pages/sign_up.dart';
import 'features/settings/presentation/Cubit/user_cubit.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // NotificationServices.init();
  await CacheHelper.init();
  bool? onBoarding = CacheHelper.getBool(key: CacheKeys.isOnBoardingSeen);
  String? uId = CacheHelper.getString(key: CacheKeys.uId);
  Widget startWidget;
  // if (onBoarding != null) {
    if (uId != null) {
      startWidget = const MainScreen();
    } else {
      startWidget = const SignIn();
    }
  // } else {
  //   startWidget = SignIn();// will be the splash in the future
  // }
  runApp(ProviderScope(child: MyApp(startWidget:startWidget)));
}

class MyApp extends ConsumerWidget {
  final Widget startWidget;

  const MyApp({required this.startWidget,super.key});

  @override
  Widget build(BuildContext context, ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(
            signInUseCase: SignInUseCase(FirebaseAuthRepository()),
            registerUseCase: RegisterUseCase(FirebaseAuthRepository()),
          ),
        ),
        BlocProvider(create: (context) => ClientsCubit()..getClients(),),
        BlocProvider(create: (context) => OrdersCubit()..getOrders(),),
        BlocProvider(
          create: (context) {
            final cubit = UserCubit();
            final uId = CacheHelper.getString(key: CacheKeys.uId);
            if (uId != null) {
              cubit.listenToFirebaseStream(uId);
            }
            return cubit;
          },
        ),
      ],
      child: MaterialApp(
        title: 'In Your Hand',
        // initialRoute: "/main_screen",
        home:startWidget,
        routes: {
        // "/": (context) => OnboardingScreen(),
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
      ),
    );
  }
}
