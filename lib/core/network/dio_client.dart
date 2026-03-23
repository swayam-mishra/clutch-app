import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_constants.dart';

part 'dio_client.g.dart';

// ---------------------------------------------------------------------------
// Secure storage — singleton
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

// ---------------------------------------------------------------------------
// Auth interceptor — injects Bearer token + handles refresh on 401
// ---------------------------------------------------------------------------
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._dio);

  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Refresh endpoint uses the refresh token in the body — no Bearer header
    if (options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only attempt refresh on 401, once, and not on the refresh endpoint itself
    if (err.response?.statusCode != 401 ||
        _isRefreshing ||
        (err.requestOptions.path.contains('/auth/refresh'))) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken =
          await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        handler.next(err);
        return;
      }

      // Get a new access token
      final refreshRes = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = refreshRes.data['data'] as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String?;

      await _storage.write(
          key: AppConstants.accessTokenKey, value: newAccessToken);
      if (newRefreshToken != null) {
        await _storage.write(
            key: AppConstants.refreshTokenKey, value: newRefreshToken);
      }
      // Retry the original request with the new token
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryRes = await _dio.fetch(retryOptions);
      handler.resolve(retryRes);
    } catch (_) {
      // Refresh failed — clear tokens so the app redirects to login
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.hasBudgetKey);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}

// ---------------------------------------------------------------------------
// Dio provider — 30s timeout, auth + refresh interceptor attached
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final storage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(_AuthInterceptor(storage, dio));

  return dio;
}
