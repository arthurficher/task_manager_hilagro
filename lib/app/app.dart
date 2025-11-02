import 'package:flutter/material.dart';
import 'package:task_manager_hilagro/features/splash/presentation/pages/splash_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(context).size;
    final width = size.width; 
    final height = size.height;
    const primary = Color(0xFF40B7AD);
    const textColor = Color(0xFF4A4A4A);
    const backgroundColor = Color(0xFFF5F5F5);
    return MaterialApp(
      title: 'Administrador de Tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: backgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Poppins',
          bodyColor: textColor,
          displayColor: textColor,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, width*0.1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.010)
            ),
            backgroundColor: primary,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: height *0.02,
              fontWeight: FontWeight.w700,
            )
          )
        ),
      ),
      home: SplashPage(),
    );
  }
}
