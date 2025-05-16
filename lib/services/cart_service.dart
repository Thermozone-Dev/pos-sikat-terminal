class CartService {
  static Future<List<dynamic>> getCartItems(transactionData) async {
    // Simulate a network call to fetch cart items
    List<dynamic> items = transactionData['items'] ?? [];

    return items;
  }
}
