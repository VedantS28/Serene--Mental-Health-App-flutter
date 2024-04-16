import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mental_health/backend/utils.dart';
import 'package:mental_health/consts.dart';
import 'package:mental_health/firebase_options.dart';
import 'backend/services/auth_service.dart';
import 'backend/services/navigation_service.dart';
import 'frontend/app_theme.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await registerServices();
  Gemini.init(apiKey: GEMINI_API_KEY);
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  final GetIt getIt = GetIt.instance;
  late NavigationService _navigationService;
  // late DatabaseService databaseService;
  late AuthService _authService;
  MyApp({super.key}) {
    _navigationService = getIt.get<NavigationService>();
    _authService = getIt.get<AuthService>();
    // // databaseService = getIt.get<DatabaseService>();

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serene',
      debugShowCheckedModeBanner: false,
      routes: _navigationService.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.android,
      ),
      navigatorKey: _navigationService.navigatorKey,
      initialRoute: _authService.user != null ? '/navscreen' : '/login',
      // home: _authService.user != null
      //     ? NavigationHomeScreen(
      //         // name: _authService.user!.displayName!,
      //         // pfpUrl: _authService.user!.photoURL!,
      //       )
      //     : const LoginPage(),
    );
  }
}
