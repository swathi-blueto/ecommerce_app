import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final List<dynamic> response = await supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching Orders: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final response = await supabase
          .from('profiles') 
          .select('full_name, email')
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      print('Error fetching User Details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProductDetails(int productId) async {
    try {
      final response = await supabase
          .from('watches') 
          .select('name, image_url')
          .eq('id', productId)
          .single();

      return response;
    } catch (e) {
      print('Error fetching Product Details: $e');
      return null;
    }
  }
}

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    List<Map<String, dynamic>> orders = await _orderService.getAllOrders();

    for (var order in orders) {
      
      final userDetails = await _orderService.getUserDetails(order['user_id']);
      if (userDetails != null) {
        order['user_name'] = userDetails['full_name'];
        order['user_email'] = userDetails['email'];
      } else {
        order['user_name'] = 'Unknown';
        order['user_email'] = 'Not Available';
      }

      
      final productDetails = await _orderService.getProductDetails(order['product_id']);
      if (productDetails != null) {
        order['product_name'] = productDetails['name'];
        order['product_image'] = productDetails['image_url'];
      } else {
        order['product_name'] = 'Unknown Product';
        order['product_image'] = null;
      }
    }

    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders", style: TextStyle(fontWeight: FontWeight.bold))),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text("No Orders Available"))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           
                            Text(
                              "Customer: ${order['user_name']}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Email: ${order['user_email']}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Divider(),

                            
                            Row(
                              children: [
                                order['product_image'] != null
                                    ? Image.network(
                                        order['product_image'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(Icons.image, size: 80, color: Colors.grey),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "🛍 ${order['product_name']}",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),

                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("📦 Quantity: ${order['quantity']}", style: TextStyle(fontSize: 14)),
                                Text("💰 Price: \$${order['price']}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text("💵 Total Amount: \$${order['total_amount']}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),

                           
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Payment: ${order['payment_status']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: order['payment_status'] == "paid" ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  order['order_status'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: order['order_status'] == "pending" ? Colors.orange : Colors.green,
                                  ),
                                ),
                              ],
                            ),

                            // Transaction ID
                            // SizedBox(height: 5),
                            // Text(
                            //   "🔗 Transaction ID: ${order['transaction_id']}",
                            //   style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
