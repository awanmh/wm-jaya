// lib/features/auth/screens/login_screen.dart 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/di/injector.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/constants/app_strings.dart';
import 'package:wm_jaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:wm_jaya/utils/helpers/input_validator.dart';
import 'package:wm_jaya/widgets/common/app_button.dart';
import 'package:wm_jaya/widgets/common/app_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAppHeader(),
                  const SizedBox(height: 40),
                  _buildLoginCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.3, 0.7],
        colors: [
          AppColors.primary,
          AppColors.background,
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.background,
            letterSpacing: 1.5,
            shadows: const [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.appTagline,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.background.withAlpha((0.9 * 255).toInt()),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildUsernameField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 10),
                _buildForgotPasswordButton(), // ✅ Tombol "Lupa Password?"
                const SizedBox(height: 20),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return AppTextField(
      controller: _usernameController,
      labelText: AppStrings.usernameHint,
      prefixIcon: const Icon(Icons.person_outline),
      validator: InputValidator.validateUsername,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username],
    );
  }

  Widget _buildPasswordField() {
    return AppTextField(
      controller: _passwordController,
      labelText: AppStrings.passwordHint,
      prefixIcon: const Icon(Icons.lock_outline),
      obscureText: true,
      validator: InputValidator.validatePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      autofillHints: const [AutofillHints.password],
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/reset-password'),
        child: const Text(
          "Lupa Password?",
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return AppButton(
          text: AppStrings.loginButton,
          onPressed: _isLoading ? null : _handleLogin,
          type: ButtonType.elevated,
          isLoading: _isLoading,
          disabled: _isLoading,
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = getIt<AuthProvider>();

      // Perform login asynchronously
      final loginFuture = authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      loginFuture.then((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      }).catchError((e) {
        if (mounted) _showErrorSnackBar(e.toString());
      }).whenComplete(() {
        if (mounted) setState(() => _isLoading = false);
      });

    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _mapErrorMessage(message),
          style: const TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _mapErrorMessage(String error) {
    if (error.contains('User tidak ditemukan')) {
      return AppStrings.errorUserNotFound;
    } else if (error.contains('Password salah')) {
      return AppStrings.errorWrongPassword;
    }
    return AppStrings.errorGeneral;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
