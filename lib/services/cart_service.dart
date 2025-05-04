class CartService {
  static Future<List<dynamic>> getCartItems(transactionData) async {
    // Simulate a network call to fetch cart items
    await Future.delayed(const Duration(seconds: 2));

    List<dynamic> items = transactionData['items'] ?? [];

    return items;
  }
}
