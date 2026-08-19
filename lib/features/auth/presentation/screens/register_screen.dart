import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../restaurants/presentation/screens/owner_menu_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  String? _emailError;
  String? _nameError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _emailError = null;
    _nameError = null;
    _passwordError = null;
    _confirmPasswordError = null;

    if (_emailController.text.isEmpty) {
      _emailError = 'Email tidak boleh kosong';
    } else if (!_emailController.text.contains('@')) {
      _emailError = AppStrings.invalidEmail;
    }

    if (_nameController.text.isEmpty) {
      _nameError = 'Nama tidak boleh kosong';
    }

    if (_passwordController.text.isEmpty) {
      _passwordError = 'Password tidak boleh kosong';
    } else if (_passwordController.text.length < 6) {
      _passwordError = AppStrings.passwordTooShort;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      _confirmPasswordError = AppStrings.passwordsNotMatch;
    }

    return _emailError == null &&
        _nameError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  void _handleRegister(AuthProvider authProvider) async {
    if (!_validateForm()) {
      setState(() {});
      return;
    }

    await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (authProvider.error != null && !authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!)),
      );
    } else if (authProvider.isAuthenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OwnerMenuScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.registerSuccessful)),
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Name field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.fieldName,
                    hintText: AppStrings.fieldNameHint,
                    errorText: _nameError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Email field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppStrings.fieldEmail,
                    hintText: AppStrings.fieldEmailHint,
                    errorText: _emailError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.fieldPassword,
                    hintText: AppStrings.fieldPasswordHint,
                    errorText: _passwordError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Confirm password field
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.fieldConfirmPassword,
                    hintText: AppStrings.fieldConfirmPasswordHint,
                    errorText: _confirmPasswordError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _handleRegister(authProvider),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(AppStrings.actionRegister),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.haveAccount),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppStrings.loginTitle,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
