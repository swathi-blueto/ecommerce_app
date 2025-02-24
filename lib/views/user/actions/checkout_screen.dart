import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:ecommerce_app/services/order_service.dart';
import 'package:ecommerce_app/services/razor_service.dart';
import 'package:ecommerce_app/views/user/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> watch;

  const CheckoutScreen({super.key, required this.watch});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late RazorService razorService;
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    authService = AuthService();
    razorService = RazorService(
      onSuccess: (paymentId) async {
        final userId = authService.getCurrentUser()?.id;

        if (userId != null) {
          try {
            await OrderService().addOrder(
              userId: userId,
              productId: widget.watch['id'],
              productName: widget.watch['name'],
              quantity: 1,
              price: widget.watch['price'],
              paymentStatus: 'paid',
              transactionId: paymentId,
              paymentMethod: 'razorpay',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Payment Successful! Order Placed."),
                backgroundColor: Colors.green,
              ),
            );

            _showOrderConfirmationDialog();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to place order: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("User not authenticated"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      onFailure: (message) async {
        final userId = authService.getCurrentUser()?.id;

        if (userId != null) {
          try {
            await OrderService().addOrder(
              userId: userId,
              productId: widget.watch['id'],
              productName: widget.watch['name'],
              quantity: 1,
              price: widget.watch['price'],
              paymentStatus: 'failed',
              transactionId: '',
              paymentMethod: 'razorpay',
            );
          } catch (e) {
            print('Failed to add failed order: $e');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment Failed: $message"),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    print("Checkout Screen Details: ${widget.watch}");
  }

  @override
  void dispose() {
    razorService.dispose();
    super.dispose();
  }

  void _showOrderConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "🎉 Order Confirmed!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 10),
              const Text(
                "Your order has been successfully placed. You will be redirected to the home screen.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("OK", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userName = authProvider.userDetails?['full_name'] ?? "Guest";
    final userPhone = authProvider.userDetails?['phone_number'] ?? "1234567890";
    final userEmail = user?.email ?? "guest@example.com";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:MainAxisAlignment.center ,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.watch['image_url'] ?? '',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "🛍 Watch: ${widget.watch['name']}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "💰 Price: ₹${widget.watch['price']}",
                      style: const TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Text(
                      "👤 User: $userName",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "📧 Email: $userEmail",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "📞 Phone: $userPhone",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  razorService.startPayment(
                    name: widget.watch['name'],
                    amount: widget.watch['price'].round(),
                    contact: userPhone,
                    email: userEmail,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
