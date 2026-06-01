class ApiConstants {
  // Base URL pointing to the local PHP Native backend
  static const String baseUrl = 'http://localhost/backend%20abadiplatform';

  // Toggle mock data (true = pakai mock, false = pakai API nyata)
  static const bool useMock = false;

  // Endpoints pointing to individual PHP files
  static const String login = '/login.php';
  static const String logout = '/logout.php'; // Not strictly implemented on DB but supported

  static const String products = '/get_products.php';
  static const String addProduct = '/add_product.php';
  static const String updateStock = '/update_stock.php';

  static const String transactions = '/get_transactions.php';
  static const String createTransaction = '/create_transaction.php';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
