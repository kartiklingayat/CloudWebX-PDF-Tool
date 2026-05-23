import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloudwebx_pdftool/services/auth/firebase_auth_service.dart';
import 'package:cloudwebx_pdftool/models/auth/auth_models.dart';
import 'package:cloudwebx_pdftool/widgets/common/premium_widgets.dart';
import 'package:cloudwebx_pdftool/core/utils/logger.dart';

/// Forgot Password Screen - Production Ready
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.watch(firebaseAuthServiceProvider);
      final response = await authService.sendPasswordResetEmail(
        ForgotPasswordRequest(email: _emailController.text.trim()),
      );

      if (!mounted) return;

      if (response.success) {
        AppLogger.info('Password reset email sent');
        setState(() => _emailSent = true);
        showPremiumSnackbar(
          context,
          message: response.message ?? 'Check your email for reset link',
          isError: false,
        );
      } else {
        AppLogger.error('Failed to send reset email: ${response.error}');
        showPremiumSnackbar(
          context,
          message: response.message ?? 'Failed to send reset email',
          isError: true,
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error', e);
      if (mounted) {
        showPremiumSnackbar(
          context,
          message: 'An unexpected error occurred',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _emailSent
                ? _buildEmailSentView(isDark)
                : _buildEmailInputView(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInputView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email to receive password reset instructions',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.mail_outline,
                size: 40,
                color: Color(0xFF6C5CE7),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Email Input
          PremiumTextField(
            label: 'Email Address',
            hint: 'your@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Email is required';
              }
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          // Send Button
          PremiumButton(
            label: 'Send Reset Link',
            onPressed: _isLoading ? () {} : _handleSendReset,
            isLoading: _isLoading,
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 32),
          // Back to Login
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        // Success Icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 50,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent a password reset link to:',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6C5CE7),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Click the link in the email to reset your password. The link will expire in 1 hour.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 60),
        // Back to Login Button
        PremiumButton(
          label: 'Back to Login',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          icon: Icons.login,
        ),
      ],
    );
  }
}
