import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_hilagro/features/auth/presentation/providers/auth_provider.dart' as custom_auth;
import 'package:task_manager_hilagro/features/tasks/presentation/pages/home_page1.dart';
import 'package:task_manager_hilagro/shared/widgets/custom_text_field.dart';
import 'package:task_manager_hilagro/shared/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Iniciar Sesión')),
        backgroundColor: const Color(0xFF40B7AD),
        foregroundColor: Colors.white,
      ),
      body: Consumer<custom_auth.AuthProvider>(
        builder: (context, authProvider, _) {
          // Auto navigate when authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.status == custom_auth.AuthStatus.authenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          });

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title
                  const Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Color(0xFF40B7AD),
                  ),
                  const SizedBox(height: 32),
                  
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Button
                  CustomButton(
                    text: 'Iniciar Sesión',
                    onPressed: authProvider.status == custom_auth.AuthStatus.loading 
                        ? null 
                        : _handleLogin,
                    isLoading: authProvider.status == custom_auth.AuthStatus.loading,
                  ),
                  
                  // Error Message
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
                          Icon(Icons.error_outline, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
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

  // Validators
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // Event Handlers
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<custom_auth.AuthProvider>(context, listen: false);
      authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
