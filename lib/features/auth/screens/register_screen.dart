import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/adaptive_widgets.dart';
import '../../../core/platform/platform_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/platform_messages.dart';

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
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Validation error messages for iOS
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateiOSFields() {
    bool isValid = true;
    
    // Validate username
    if (_usernameController.text.isEmpty) {
      setState(() => _usernameError = 'Please enter a username');
      isValid = false;
    } else if (_usernameController.text.length < 3) {
      setState(() => _usernameError = 'Username must be at least 3 characters');
      isValid = false;
    } else if (_usernameController.text.length > 50) {
      setState(() => _usernameError = 'Username must be less than 50 characters');
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(_usernameController.text)) {
      setState(() => _usernameError = 'Username can only contain letters, numbers, and underscores');
      isValid = false;
    } else {
      setState(() => _usernameError = null);
    }
    
    // Validate email
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      isValid = false;
    } else if (!emailRegex.hasMatch(_emailController.text)) {
      setState(() => _emailError = 'Please enter a valid email address');
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }
    
    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Please enter a password');
      isValid = false;
    } else if (_passwordController.text.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters');
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }
    
    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      isValid = false;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    } else {
      setState(() => _confirmPasswordError = null);
    }
    
    return isValid;
  }

  Future<void> _handleRegister() async {
    // For iOS, manually validate
    if (context.isIOS) {
      if (!_validateiOSFields()) return;
    } else {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _usernameController.text, // Using username as display name for now
      );
      
      // Navigate to home screen on successful registration
      if (mounted && authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithGoogle();
      
      // Navigate to home screen on successful login
      if (mounted && authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    // Parse backend validation errors
    String displayMessage = message;
    
    // Handle common backend validation messages
    if (message.contains('email already exists') || message.contains('Email already exists')) {
      displayMessage = 'This email is already registered. Please use a different email or login.';
    } else if (message.contains('username already exists') || message.contains('Username already exists')) {
      displayMessage = 'This username is already taken. Please choose a different username.';
    } else if (message.contains('password') && message.contains('short')) {
      displayMessage = 'Password must be at least 8 characters long.';
    } else if (message.contains('Bad Request Exception')) {
      displayMessage = 'Please check your input and try again. Make sure your password is at least 8 characters.';
    }
    
    PlatformMessages.showError(context, displayMessage);
  }

  Widget _buildIOSField({
    required TextEditingController controller,
    required String placeholder,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
      onChanged: onChanged,
      autocorrect: false,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      suffix: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: const Text('Create Account'),
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
                    const Icon(
                      Icons.track_changes,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to start tracking your habits',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    if (context.isIOS) ...[
                      _buildIOSField(
                        controller: _usernameController,
                        placeholder: 'Username',
                        onChanged: (value) {
                          if (_usernameError != null) {
                            _validateiOSFields();
                          }
                        },
                      ),
                      if (_usernameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 16),
                          child: Text(
                            _usernameError!,
                            style: const TextStyle(
                              color: CupertinoColors.destructiveRed,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ]
                    else
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          if (value.length > 50) {
                            return 'Username must be less than 50 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                            return 'Username can only contain letters, numbers, and underscores';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    if (context.isIOS) ...[
                      _buildIOSField(
                        controller: _emailController,
                        placeholder: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (_emailError != null) {
                            _validateiOSFields();
                          }
                        },
                      ),
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 16),
                          child: Text(
                            _emailError!,
                            style: const TextStyle(
                              color: CupertinoColors.destructiveRed,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ]
                    else
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // More comprehensive email validation
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    if (context.isIOS) ...[
                      _buildIOSField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        obscureText: _obscurePassword,
                        onChanged: (value) {
                          if (_passwordError != null) {
                            _validateiOSFields();
                          }
                        },
                        suffix: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                          child: Icon(
                            _obscurePassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 16),
                          child: Text(
                            _passwordError!,
                            style: const TextStyle(
                              color: CupertinoColors.destructiveRed,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ]
                    else
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          // Check for password strength
                          bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
                          bool hasLowercase = value.contains(RegExp(r'[a-z]'));
                          bool hasNumbers = value.contains(RegExp(r'[0-9]'));
                          
                          if (!hasUppercase || !hasLowercase || !hasNumbers) {
                            return 'Password must contain uppercase, lowercase, and numbers';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    if (context.isIOS) ...[
                      _buildIOSField(
                        controller: _confirmPasswordController,
                        placeholder: 'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: _handleRegister,
                        onChanged: (value) {
                          if (_confirmPasswordError != null) {
                            _validateiOSFields();
                          }
                        },
                        suffix: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() =>
                                _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                          child: Icon(
                            _obscureConfirmPassword
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                      if (_confirmPasswordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 16),
                          child: Text(
                            _confirmPasswordError!,
                            style: const TextStyle(
                              color: CupertinoColors.destructiveRed,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ]
                    else
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() =>
                                  _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleRegister(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else
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
                    if (context.isIOS)
                      CupertinoButton(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.person_crop_circle,
                                size: 24,
                                color: CupertinoColors.systemBlue,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Sign up with Google',
                                style: TextStyle(
                                  color: CupertinoColors.label,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.g_mobiledata,
                              size: 24,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign up with Google',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
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