import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
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
    final cs = Theme.of(context).colorScheme;

    // Navigate to budget setup on successful signup
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated) {
        context.go(AppConstants.routeBudgetSetup);
      }
    });

    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Back button
              IconButton(
                onPressed: () => context.go(AppConstants.routeLogin),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 16),

              Text('create account', style: tt.displaySmall),
              const SizedBox(height: 6),
              Text(
                'takes 30 seconds.',
                style: tt.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),

              const SizedBox(height: 40),

              // Full name
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'full name'),
              ),
              const SizedBox(height: 12),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'email'),
              ),
              const SizedBox(height: 12),

              // Password
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
              const SizedBox(height: 12),

              // Confirm password
              TextField(
                controller: _confirmController,
                obscureText: true,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration:
                    const InputDecoration(hintText: 'confirm password'),
              ),

              // Error message
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    auth.error!,
                    style: tt.labelSmall?.copyWith(color: cs.error),
                  ),
                ),

              const SizedBox(height: 32),

              // Create account button
              FilledButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        if (_passwordController.text !=
                            _confirmController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("passwords don't match")),
                          );
                          return;
                        }
                        ref.read(authNotifierProvider.notifier).signup(
                              _nameController.text.trim(),
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                child: auth.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Text('create account'),
              ),

              const SizedBox(height: 24),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'already have an account? ',
                    style:
                        tt.bodySmall?.copyWith(color: AppTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () => context.go(AppConstants.routeLogin),
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
