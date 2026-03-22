import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

final _obscurePasswordProvider = StateProvider<bool>((ref) => true);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final obscure = ref.watch(_obscurePasswordProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top spacing
              const SizedBox(height: 80),

              // 2. App name — wordmark keeps explicit font call
              Text(
                'clutch',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                  height: 1,
                ),
              ),

              // 3. Tagline
              const SizedBox(height: 8),
              Text(
                'spend smarter.',
                style: tt.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),

              // 4. Spacing
              const SizedBox(height: 48),

              // 5. Email field
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'email',
                ),
              ),

              // 6. Spacing
              const SizedBox(height: 12),

              // 7. Password field
              TextField(
                obscureText: obscure,
                cursorColor: AppTheme.textSecondary,
                style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => ref
                        .read(_obscurePasswordProvider.notifier)
                        .state = !obscure,
                  ),
                ),
              ),

              // 8. Spacing
              const SizedBox(height: 8),

              // 9. Forgot password
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

              // 10. Spacing
              const SizedBox(height: 32),

              // 11. Login button — M3 FilledButton, primary action
              FilledButton(
                onPressed: () {},
                child: const Text('log in'),
              ),

              // 12. Spacing
              const SizedBox(height: 20),

              // 13. Divider row
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: tt.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              // 14. Spacing
              const SizedBox(height: 20),

              // 15. Create account button — M3 OutlinedButton, secondary action
              OutlinedButton(
                onPressed: () => context.go(AppConstants.routeSignup),
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

              // 16. Bottom spacing
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
