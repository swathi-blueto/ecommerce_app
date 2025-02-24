import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> addOrder({
  required String userId,
  required int productId,
  required String productName,
  required int quantity,
  required double price,
  required String paymentStatus,
  required String transactionId,
  required String paymentMethod,
}) async {
  final totalAmount = quantity * price;

  try {
    
    await supabase.from('orders').insert({
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'payment_method': paymentMethod,
      'order_status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });

    print("Order added successfully!");
  } catch (e) {
    print('Error adding order: $e');
    throw Exception("Failed to add order: $e");
  }
}


  // Fetch Orders for a User
 Future<List<Map<String, dynamic>>> getOrders(String userId) async {
  try {
    
    final List<dynamic> response = await supabase
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

   
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error fetching Orders: $e');
    return [];
  }
}

}