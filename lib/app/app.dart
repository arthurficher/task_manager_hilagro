import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_hilagro/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager_hilagro/features/auth/presentation/providers/auth_provider.dart' as custom_auth;
import 'package:task_manager_hilagro/features/splash/presentation/pages/splash_page.dart';
import 'package:task_manager_hilagro/features/tasks/presentation/pages/home_page1.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF40B7AD);
    const textColor = Color(0xFF4A4A4A);
    const backgroundColor = Color(0xFFF5F5F5);
    
    return MaterialApp(
      title: 'Administrador de Tareas',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
        ),
        scaffoldBackgroundColor: backgroundColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ),
        useMaterial3: true,
      ),

      home: Consumer<custom_auth.AuthProvider>(
        builder: (context, authProvider, _) {
          print('APP: Building with status: ${authProvider.status}');
          switch (authProvider.status) {
            case custom_auth.AuthStatus.initial:
            case custom_auth.AuthStatus.loading:
              return const SplashPage();
            case custom_auth.AuthStatus.authenticated:
              return const HomePage();
            case custom_auth.AuthStatus.unauthenticated:
              return const LoginPage();
            case custom_auth.AuthStatus.error:
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ocurrió un error',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          authProvider.errorMessage ?? 'Error desconocido',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                authProvider.checkAuthState();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Reintentar'),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () {
                                authProvider.clearError();
                              },
                              child: const Text('Ir al Login'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
