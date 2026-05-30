class ApiConstants {
  static const String baseUrl = 'https://nawasena-backend.test/api'; 
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  static const String me = '/users/me';
  static String portfolio(String id) => '/users/$id/portfolio';

  static const String foundations = '/foundations';
  static String foundationDetail(String id) => '/foundations/$id';

  static const String inventories = '/inventories'; // ?urgent_level=high

  static const String donations = '/donations';
  static String donationQr(String id) => '/donations/$id/qr';
  static String donationStatus(String id) => '/donations/$id/status';
}