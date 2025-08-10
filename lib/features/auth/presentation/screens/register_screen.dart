import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/common/adaptive_widgets.dart';
import '../../../../core/platform/platform_service.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/utils/platform_messages.dart';
import '../providers/register_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/auth_loading_state.dart';
import '../../utils/auth_validator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel(context.read<AuthProvider>());
    _viewModel.addListener(_handleViewModelChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleViewModelChange() {
    if (_viewModel.error != null && mounted) {
      PlatformMessages.showError(context, _viewModel.error!);
      _viewModel.clearError();
    }
  }

  Future<void> _handleRegister() async {
    bool isValid = true;
    
    if (context.isIOS) {
      isValid = _viewModel.validateFields(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    } else {
      isValid = _formKey.currentState!.validate();
    }
    
    if (isValid) {
      final success = await _viewModel.register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
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
      title: const Text('Register'),
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
                      title: 'Create Account',
                      subtitle: 'Sign up to get started',
                    ),
                    const SizedBox(height: 48),
                    ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        if (_viewModel.isLoading) {
                          return const AuthLoadingState(
                            message: 'Creating your account...',
                          );
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthFormField(
                              controller: _usernameController,
                              label: 'Username',
                              placeholder: 'Username',
                              prefixIcon: Icons.person,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidator.validateUsername,
                              errorText: context.isIOS ? _viewModel.usernameError : null,
                              onChanged: context.isIOS 
                                  ? (_) => setState(() {}) 
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AuthFormField(
                              controller: _emailController,
                              label: 'Email',
                              placeholder: 'Email',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidator.validateEmail,
                              errorText: context.isIOS ? _viewModel.emailError : null,
                              onChanged: context.isIOS 
                                  ? (_) => setState(() {}) 
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AuthFormField(
                              controller: _passwordController,
                              label: 'Password',
                              placeholder: 'Password',
                              prefixIcon: Icons.lock,
                              obscureText: _viewModel.obscurePassword,
                              textInputAction: TextInputAction.next,
                              showToggleVisibility: true,
                              onToggleVisibility: _viewModel.togglePasswordVisibility,
                              validator: AuthValidator.validatePassword,
                              errorText: context.isIOS ? _viewModel.passwordError : null,
                              onChanged: context.isIOS 
                                  ? (_) => setState(() {}) 
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            AuthFormField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              placeholder: 'Confirm Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _viewModel.obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: _handleRegister,
                              showToggleVisibility: true,
                              onToggleVisibility: _viewModel.toggleConfirmPasswordVisibility,
                              validator: (value) => AuthValidator.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                              errorText: context.isIOS ? _viewModel.confirmPasswordError : null,
                              onChanged: context.isIOS 
                                  ? (_) => setState(() {}) 
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            AdaptiveButton(
                              text: 'Create Account',
                              onPressed: _handleRegister,
                              isPrimary: true,
                            ),
                            const SizedBox(height: 16),
                            AdaptiveButton(
                              text: 'Already have an account? Login',
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
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
                          text: 'Sign up with Google',
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