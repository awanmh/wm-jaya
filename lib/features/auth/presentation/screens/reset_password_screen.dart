// lib/features/auth/presentation/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/features/auth/presentation/providers/auth_provider.dart';
import 'package:wm_jaya/utils/helpers/input_validator.dart';
import 'package:wm_jaya/widgets/common/app_button.dart';
import 'package:wm_jaya/widgets/common/app_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.tertiary,
        title: const Text('Reset Password'),
        titleTextStyle: TextStyle(
          color : AppColors.tertiary,
          fontSize: 20,
          fontWeight: FontWeight.bold, 
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _usernameController,
                labelText: 'Username',
                validator: (value) => InputValidator.validateNotEmpty(value, 'Username'),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _newPasswordController,
                labelText: 'Password Baru',
                obscureText: true,
                validator: InputValidator.validatePassword,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _confirmPasswordController,
                labelText: 'Konfirmasi Password',
                obscureText: true,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Consumer<AuthProvider>(builder: (context, authProvider, _) {
                return AppButton(
                  text: 'Reset Password',
                  onPressed: _isLoading ? null : () => _handleResetPassword(authProvider),
                  isLoading: _isLoading,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Perform the async operation outside the UI thread
      await authProvider.resetPassword(
        username: _usernameController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil direset!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
