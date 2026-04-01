abstract final class AppConstants {
  // ---------------------------------------------------------------------------
  // API
  // Production: Render deployment.
  // For local dev, swap to your machine's LAN IP: 'http://192.168.x.x:3001/api'
  // ---------------------------------------------------------------------------
  static const String apiBaseUrl = 'https://clutch-backend-hwu8.onrender.com/api';

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
