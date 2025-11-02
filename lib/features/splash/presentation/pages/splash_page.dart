import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_hilagro/features/auth/presentation/providers/auth_provider.dart' as custom_auth;
import 'package:task_manager_hilagro/features/splash/presentation/widgets/title_task.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final authProvider = Provider.of<custom_auth.AuthProvider>(context, listen: false);
      authProvider.checkAuthState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.25), 
                    const Icon(
                      Icons.task_alt,
                      size: 100,
                      color: Color(0xFF40B7AD),
                    ),
                    SizedBox(height: height * 0.04), 
                    const TitleTask(text: 'Administrador de Tareas'),
                    SizedBox(height: height * 0.02), 
                    const Text(
                      'La mejor forma para que no se te olvide nada es anotarlo. '
                      'Guardar tus tareas y ve completando poco a poco para aumentar tu productividad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: height * 0.08),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF40B7AD)),
                    ),
                    SizedBox(height: height * 0.02),
                    const Text(
                      'Cargando...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
