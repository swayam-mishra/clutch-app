import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top spacing
              const SizedBox(height: 60),

              // 2. Back button
              IconButton(
                onPressed: () => context.go(AppConstants.routeLogin),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              // 3. Spacing
              const SizedBox(height: 16),

              // 4. Title
              Text(
                'create account',
                style: tt.displaySmall,
              ),

              // 5. Subtitle
              const SizedBox(height: 6),
              Text(
                'takes 30 seconds.',
                style: tt.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),

              // 6. Spacing
              const SizedBox(height: 40),

              // 7. Full name field
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'full name',
                ),
              ),

              // 8. Spacing
              const SizedBox(height: 12),

              // 9. Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'email',
                ),
              ),

              // 10. Spacing
              const SizedBox(height: 12),

              // 11. Password field with visibility toggle
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              // 12. Spacing
              const SizedBox(height: 12),

              // 13. Confirm password field
              TextField(
                controller: _confirmController,
                obscureText: true,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'confirm password',
                ),
              ),

              // 14. Spacing
              const SizedBox(height: 32),

              // 15. Create account button — M3 FilledButton, primary action
              FilledButton(
                onPressed: () => print('signup tapped'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                child: const Text('create account'),
              ),

              // 16. Spacing
              const SizedBox(height: 24),

              // 17. Already have account row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'already have an account? ',
                    style: tt.bodySmall?.copyWith(color: AppTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppConstants.routeLogin),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(
                      'log in',
                      style: tt.bodySmall?.copyWith(color: AppTheme.accent),
                    ),
                  ),
                ],
              ),

              // 18. Bottom spacing
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
