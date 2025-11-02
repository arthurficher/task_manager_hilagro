import 'package:flutter/material.dart';
import 'package:task_manager_hilagro/features/auth/presentation/pages/login_page.dart';
import 'package:task_manager_hilagro/features/splash/presentation/widgets/title_task.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

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
                    const TitleTask(text: 'Administrador de Tareas'),
                    SizedBox(height: height * 0.02), 
                    const Text(
                      'La mejor forma para que no se te olvide nada es anotarlo. '
                      'Guardar tus tareas y ve completando poco a poco para aumentar tu productividad',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.05),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const Text('Comenzar'),
                      
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
