import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/common/adaptive_widgets.dart';
import '../../../../core/platform/platform_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/utils/platform_messages.dart';
import '../providers/login_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/auth_loading_state.dart';
import '../../utils/auth_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(context.read<AuthProvider>());
    _viewModel.addListener(_handleViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleViewModelChange() {
    if (_viewModel.error != null && mounted) {
      PlatformMessages.showError(context, _viewModel.error!);
      _viewModel.clearError();
    }
  }

  Future<void> _handleLogin() async {
    if (context.isIOS || _formKey.currentState!.validate()) {
      final success = await _viewModel.login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _viewModel.signInWithGoogle();
    
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Login'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      title: 'Welcome Back',
                      subtitle: 'Sign in to continue',
                    ),
                    const SizedBox(height: 48),
                    ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        if (_viewModel.isLoading) {
                          return const AuthLoadingState(
                            message: 'Signing in...',
                          );
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthFormField(
                              controller: _emailController,
                              label: 'Email',
                              placeholder: 'Email',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidator.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            AuthFormField(
                              controller: _passwordController,
                              label: 'Password',
                              placeholder: 'Password',
                              prefixIcon: Icons.lock,
                              obscureText: _viewModel.obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: _handleLogin,
                              showToggleVisibility: true,
                              onToggleVisibility: _viewModel.togglePasswordVisibility,
                              validator: AuthValidator.validatePassword,
                            ),
                            const SizedBox(height: 24),
                            AdaptiveButton(
                              text: 'Login',
                              onPressed: _handleLogin,
                              isPrimary: true,
                            ),
                            const SizedBox(height: 16),
                            AdaptiveButton(
                              text: 'Create Account',
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/register');
                              },
                              isPrimary: false,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        return SocialLoginButton(
                          text: 'Sign in with Google',
                          icon: context.isIOS 
                              ? Icons.g_mobiledata 
                              : CupertinoIcons.person_crop_circle,
                          iconColor: Colors.blue,
                          onPressed: _handleGoogleSignIn,
                          isLoading: _viewModel.isLoading,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}