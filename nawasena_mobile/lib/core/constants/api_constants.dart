class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://10.91.30.217:8000/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  // Users
  static const String me = '/users/me';
  static String portfolio(String id) => '/users/$id/portfolio';
  static String userDetail(String id) => '/users/$id';

  // Uploads
  static const String uploads = '/uploads';

  // Foundations
  static const String foundations = '/foundations';
  static const String foundationsNearby = '/foundations/nearby';
  static String foundationDetail(String id) => '/foundations/$id';
  static String foundationInventories(String id) => '/foundations/$id/inventories';
  static String foundationWorkshops(String id) => '/foundations/$id/workshops';

  // Inventories
  static const String inventories = '/inventories';
  static String inventoryDetail(String id) => '/inventories/$id';

  // Donations
  static const String donations = '/donations';
  static const String myDonations = '/donations/me';
  static String donationDetail(String id) => '/donations/$id';
  static String donationUpdateStatus(String id) => '/donations/$id/status';
  static String donationQr(String id) => '/donations/$id/qr';

  // Workshops
  static const String workshops = '/workshops';
  static String workshopDetail(String id) => '/workshops/$id';
  static String workshopRegister(String id) => '/workshops/$id/register';
  static String workshopUnregister(String id) => '/workshops/$id/register';
  static String workshopCheckin(String id) => '/workshops/$id/checkin';
}