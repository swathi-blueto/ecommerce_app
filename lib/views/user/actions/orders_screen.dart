import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:ecommerce_app/services/order_service.dart';
import 'package:ecommerce_app/services/watch_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the AuthProvider to access the current user
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id; // Get the current user's ID

    // If the user is not authenticated, show a message
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Orders")),
        body: const Center(child: Text("User not authenticated")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: const Color.fromARGB(255, 62, 168, 230), // Change the app bar color
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: OrderService().getOrders(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders placed yet"));
          }

          List<Map<String, dynamic>> orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              int productId = order['product_id'];

              return FutureBuilder<Map<String, dynamic>>(
                future: WatchService().fetchProductDetails(productId), // Query the watches table to get product details
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (productSnapshot.hasError) {
                    return Center(child: Text("Error: ${productSnapshot.error}"));
                  }

                  if (!productSnapshot.hasData) {
                    return const Center(child: Text("Product details not found"));
                  }

                  var product = productSnapshot.data!;
                  String productName = product['name'];
                  String productImage = product['image_url'] ?? ''; // If image is null, leave it empty

                  // Safely handling price as double
                  double price = order['price'] is double
                      ? order['price']
                      : double.tryParse(order['price'].toString()) ?? 0.0;

                  // Safely handling quantity as int
                  int quantity = order['quantity'] is int
                      ? order['quantity']
                      : int.tryParse(order['quantity'].toString()) ?? 0;

                  // Convert price and quantity to string for displaying
                  String priceString = price.toStringAsFixed(2); // Format price to 2 decimal places
                  String quantityString = quantity.toString();

                  return Card(
                    elevation: 10,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      leading: productImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(productImage, width: 60, height: 60, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image_not_supported, size: 60), // Handle missing image
                      title: Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Price: ₹$priceString",
                        style: const TextStyle(fontSize: 16, color: Colors.teal),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Display the status of the order
                          Text(
                            order['payment_status'] == 'paid' ? "Paid" : "Failed",
                            style: TextStyle(
                              color: order['payment_status'] == 'paid' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Display the quantity
                          Text(
                            "Qty: $quantityString",
                            style: const TextStyle(fontSize: 14),
                          ), // Display quantity properly as string
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
