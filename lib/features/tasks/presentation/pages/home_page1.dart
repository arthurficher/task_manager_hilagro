import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_hilagro/features/auth/presentation/providers/auth_provider.dart'
    as custom_auth;
import 'package:task_manager_hilagro/features/auth/presentation/pages/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: const Color(0xFF40B7AD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Consumer<custom_auth.AuthProvider>(
        builder: (context, authProvider, _) {
          // ⬇️ ESCUCHAR CAMBIOS DE ESTADO PARA AUTO-NAVEGACIÓN
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.status == custom_auth.AuthStatus.unauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          });

          // ⬇️ USAR SINGLECHILDSCROLLVIEW PARA EVITAR OVERFLOW
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          kToolbarHeight - 48, // AppBar height + padding
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ⬇️ INFORMACIÓN DEL USUARIO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60, // ⬅️ Reducido de 80 a 60
                        ),
                        const SizedBox(height: 12), // ⬅️ Reducido de 16 a 12
                        const Text(
                          '¡Login Exitoso!',
                          style: TextStyle(
                            fontSize: 20, // ⬅️ Reducido de 24 a 20
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF40B7AD),
                          ),
                        ),
                        const SizedBox(height: 6), // ⬅️ Reducido de 8 a 6
                        const Text(
                          'Has iniciado sesión correctamente.',
                          style: TextStyle(fontSize: 14), // ⬅️ Reducido de 16 a 14
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12), // ⬅️ Reducido de 16 a 12
                        // ⬇️ MOSTRAR EMAIL DEL USUARIO
                        if (authProvider.currentUser?.email != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, // ⬅️ Reducido de 16 a 12
                              vertical: 6,    // ⬅️ Reducido de 8 a 6
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF40B7AD).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Color(0xFF40B7AD),
                                  size: 16, // ⬅️ Reducido de 20 a 16
                                ),
                                const SizedBox(width: 6), // ⬅️ Reducido de 8 a 6
                                Flexible( // ⬅️ Cambiado Text por Flexible
                                  child: Text(
                                    authProvider.currentUser!.email!,
                                    style: const TextStyle(
                                      fontSize: 12, // ⬅️ Reducido de 14 a 12
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF40B7AD),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24), // ⬅️ Reducido de 40 a 24

                  // ⬇️ BOTÓN DE LOGOUT
                  SizedBox(
                    width: double.infinity,
                    height: 48, // ⬅️ Reducido de 56 a 48
                    child: ElevatedButton.icon(
                      onPressed:
                          authProvider.status == custom_auth.AuthStatus.loading
                          ? null
                          : () => _handleLogout(context),
                      icon: authProvider.status == custom_auth.AuthStatus.loading
                          ? const SizedBox(
                              width: 16, // ⬅️ Reducido de 20 a 16
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.logout, size: 20), // ⬅️ Tamaño específico
                      label: Text(
                        authProvider.status == custom_auth.AuthStatus.loading
                            ? 'Cerrando sesión...'
                            : 'Cerrar Sesión',
                        style: const TextStyle(fontSize: 16), // ⬅️ Tamaño específico
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // ⬇️ MOSTRAR ERROR SI HAY (COMPACTO)
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, 
                               color: Colors.red.shade600, 
                               size: 20), // ⬅️ Tamaño específico
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12, // ⬅️ Reducido
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16), // ⬅️ Reducido
                            onPressed: () => authProvider.clearError(),
                            color: Colors.red.shade600,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ⬇️ MÉTODO PARA MANEJAR EL LOGOUT
  void _handleLogout(BuildContext context) {
    final authProvider = Provider.of<custom_auth.AuthProvider>(
      context,
      listen: false,
    );

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                authProvider.logout(); // Ejecutar logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}