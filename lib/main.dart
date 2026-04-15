import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

import 'providers/theme_provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load Env for OpenAI Key
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const AIAstrologyApp(),
    ),
  );
}

class AIAstrologyApp extends StatelessWidget {
  const AIAstrologyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Lumina AI',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

// Wrapper to decide whether to show Login, Profile Setup, or Home Dashboard
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // Checking Global Auth and Loading States
        if (appState.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final authServiceUser = appState.currentUserData == null && !appState.isLoading;
        // The AppStateProvider listens to Firebase Auth. We check if userdata is loaded
        
        // Actually, we need to check firebase user first to see if they're logged in.
        // If logged in but currentUserData is null and not loading, they need setup.
        // In our appStateProvider, if they are logged in but don't have a profile, currentUserData will remain null.
        
        final user = FirebaseAuth.instance.currentUser;
        
        if (user == null) {
          return const LoginScreen();
        }

        if (appState.currentUserData == null) {
          return ProfileSetupScreen(user: user);
        }

        return const HomeScreen();
      },
    );
  }
}
