import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Restore session if a valid token is already stored
    Future.microtask(
        () => ref.read(authNotifierProvider.notifier).checkToken());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Navigate when auth state changes
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated) {
        next.hasBudget
            ? context.go(AppConstants.routeShell)
            : context.go(AppConstants.routeBudgetSetup);
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
              const SizedBox(height: 80),

              // Wordmark
              Text(
                'clutch',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'spend smarter.',
                style: tt.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),

              const SizedBox(height: 48),

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
                obscureText: _obscure,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              // Error message
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    auth.error!,
                    style:
                        tt.labelSmall?.copyWith(color: cs.error),
                  ),
                ),

              const SizedBox(height: 8),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'forgot password?',
                    style: tt.labelSmall?.copyWith(
                      color: AppTheme.accent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Log in button
              FilledButton(
                onPressed: auth.isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).login(
                          _emailController.text.trim(),
                          _passwordController.text,
                        ),
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
                    : const Text('log in'),
              ),

              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: tt.bodySmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              // Create account
              OutlinedButton(
                onPressed: auth.isLoading
                    ? null
                    : () => context.go(AppConstants.routeSignup),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: Color(0xFF89938E), width: 1),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
                child: const Text('create account'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
