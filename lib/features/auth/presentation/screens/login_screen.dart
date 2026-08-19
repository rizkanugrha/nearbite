import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../../../restaurants/presentation/screens/owner_menu_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _emailError = null;
    _passwordError = null;

    if (_emailController.text.isEmpty) {
      _emailError = 'Email tidak boleh kosong';
    } else if (!_emailController.text.contains('@')) {
      _emailError = AppStrings.invalidEmail;
    }

    if (_passwordController.text.isEmpty) {
      _passwordError = 'Password tidak boleh kosong';
    } else if (_passwordController.text.length < 6) {
      _passwordError = AppStrings.passwordTooShort;
    }

    return _emailError == null && _passwordError == null;
  }

  void _handleLogin(AuthProvider authProvider) async {
    if (!_validateForm()) {
      setState(() {});
      return;
    }

    await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!)),
      );
    } else if (authProvider.isAuthenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OwnerMenuScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.loginTitle),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Welcome text
                Text(
                  AppStrings.loginToManageRestaurant,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),

                // Email field
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
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
                  focusNode: _passwordFocus,
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
                const SizedBox(height: 32),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _handleLogin(authProvider),
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
                          : const Text(AppStrings.actionLogin),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.dontHaveAccount),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppStrings.registerTitle,
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
