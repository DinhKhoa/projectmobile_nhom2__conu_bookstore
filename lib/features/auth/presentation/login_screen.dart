import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // Try real API first
      final result = await AuthService.login(username, password);

      if (result['success'] == true) {
        navigator.pushReplacementNamed('/main');
        return;
      } else {
        if (mounted) setState(() => _isLoading = false);
        _showErrorSnackBar(result['message'] ?? AppConstants.errorInvalidCredentials);
        return;
      }
    } catch (_) {
      // Fallback: if server unavailable, use default credentials
    }

    if (!mounted) return;

    // Fallback to hardcoded credentials when server is offline
    if (username == AppConstants.defaultUsername &&
        password == AppConstants.defaultPassword) {
      navigator.pushReplacementNamed('/main');
    } else {
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppConstants.errorInvalidCredentials),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(iconSize: 70, titleFontSize: 34, subtitleFontSize: 12),
                  const SizedBox(height: 32),
                  const Text(
                    AppConstants.loginTitle,
                    style: AppTextStyles.loginTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _buildUsernameField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        AppConstants.forgotPassword,
                        style: AppTextStyles.link,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        hintText: AppConstants.hintUsername,
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppConstants.errorEmptyUsername;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: AppConstants.hintPassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textHint,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppConstants.errorEmptyPassword;
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.buttonText,
                ),
              )
            : const Text(AppConstants.loginButton, style: AppTextStyles.button),
      ),
    );
  }
}
