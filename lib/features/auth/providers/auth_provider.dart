import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';

part 'auth_provider.g.dart';

// ---------------------------------------------------------------------------
// AuthState
// ---------------------------------------------------------------------------

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.userId,
    this.userName,
    this.userEmail,
    this.hasBudget = false,
  });

  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final bool hasBudget;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isAuthenticated,
    String? userId,
    String? userName,
    String? userEmail,
    bool? hasBudget,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      hasBudget: hasBudget ?? this.hasBudget,
    );
  }
}

// ---------------------------------------------------------------------------
// AuthNotifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState();

  Dio get _dio => ref.read(dioClientProvider);

  // ── Check stored token on app start ──────────────────────────────────────

  Future<void> checkToken() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: AppConstants.accessTokenKey);
    if (token == null) return;

    try {
      final response = await _dio.get('/user/profile');
      if (response.statusCode == 200) {
        final user = response.data['data'] as Map<String, dynamic>;
        final hasBudget =
            (await storage.read(key: AppConstants.hasBudgetKey)) == 'true';
        state = AuthState(
          isAuthenticated: true,
          userId: user['id'] as String?,
          userName: user['name'] as String?,
          userEmail: user['email'] as String?,
          hasBudget: hasBudget,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _clearTokens();
      }
      // Any other error: stay on login, keep token for next attempt
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await _handleAuthSuccess(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    }
  }

  // ── Signup ────────────────────────────────────────────────────────────────

  Future<void> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _dio.post(
        '/auth/signup',
        data: {'name': name, 'email': email, 'password': password},
      );
      await _handleAuthSuccess(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> setHasBudget() async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: AppConstants.hasBudgetKey, value: 'true');
    state = state.copyWith(hasBudget: true);
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    final refreshToken = await storage.read(key: AppConstants.refreshTokenKey);

    try {
      await _dio.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } catch (_) {
      // Fire and forget — clear local state regardless
    }

    await _clearTokens();
    state = const AuthState();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    final storage = ref.read(secureStorageProvider);
    final user = data['user'] as Map<String, dynamic>;
    final hasBudget = user['hasBudget'] as bool? ?? false;

    await storage.write(
        key: AppConstants.accessTokenKey, value: data['accessToken'] as String);
    await storage.write(
        key: AppConstants.refreshTokenKey,
        value: data['refreshToken'] as String);
    await storage.write(
        key: AppConstants.hasBudgetKey, value: hasBudget.toString());

    state = AuthState(
      isAuthenticated: true,
      userId: user['id'] as String?,
      userName: user['name'] as String?,
      userEmail: user['email'] as String?,
      hasBudget: hasBudget,
    );
  }

  Future<void> _clearTokens() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: AppConstants.accessTokenKey);
    await storage.delete(key: AppConstants.refreshTokenKey);
    await storage.delete(key: AppConstants.hasBudgetKey);
  }

  String _extractError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) {
        return data['error'] as String;
      }
    } catch (_) {}
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your network.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check your connection.';
    }
    return 'Something went wrong. Try again.';
  }
}
