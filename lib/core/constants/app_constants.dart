abstract final class AppConstants {
  // ---------------------------------------------------------------------------
  // API
  // NOTE: 10.0.2.2 is the Android emulator loopback to the host machine.
  // For USB debugging on a physical device, change this to your machine's
  // local IP address (e.g. 'http://192.168.1.X:3001/api').
  // ---------------------------------------------------------------------------
  static const String apiBaseUrl = 'http://10.6.48.170:3001/api';

  // Secure storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String hasBudgetKey = 'has_budget';

  // Route paths
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeShell = '/shell';
  static const String routeHome = '/shell/home';
  static const String routeBudgetSetup = '/budget-setup';
  static const String routeAnalytics = '/analytics';
  static const String routeGoals = '/goals';
  static const String routePurchaseAdvisor = '/purchase-advisor';
  static const String routeChat = '/chat';
  static const String routeSettings = '/settings';
  static const String routeHealthScore = '/health-score';
}
