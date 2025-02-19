import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/action_provider.dart';
import "package:ecommerce_app/views/user/watches/watch_description.dart";

class Watches extends StatelessWidget {
  const Watches({
    super.key,
    required Future<List<Map<String, dynamic>>> watches,
  }) : _watches = watches;

  final Future<List<Map<String, dynamic>>> _watches;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>( 
        future: _watches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No watches available'));
          }

          final watches = snapshot.data!;
          final actionProvider = Provider.of<ActionProvider>(context);
          final cartProvider = Provider.of<CartProvider>(context, listen: false);

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.45,
            ),
            itemCount: watches.length,
            itemBuilder: (context, index) {
              final watch = watches[index];
              bool isWishlisted = actionProvider.isInWishlist(watch);

              return GestureDetector(
                onTap: () {
                  // Navigate to WatchDetails screen and pass the selected watch details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WatchDetailsScreen(watch: watch),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.2),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image section with Wishlist icon
                          Stack(
                            children: [
                              ClipRRect(
                                child: Image.network(
                                  watch['image_url'] ?? '',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    if (isWishlisted) {
                                      actionProvider.removeFromWishlist(watch);
                                    } else {
                                      actionProvider.addToWishlist(watch);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 234, 232, 232),
                                    ),
                                    child: Icon(
                                      isWishlisted
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isWishlisted
                                          ? Colors.red
                                          : Colors.grey[700],
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  watch['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  watch['category'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      Icons.star,
                                      color: index < (watch['rating'] ?? 0.0)
                                          ? Colors.orangeAccent
                                          : Colors.grey[300],
                                      size: 16,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '\₹${watch['price']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cartProvider.addToCart(watch);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${watch['name']} added to cart!'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      elevation: 2,
                                      shadowColor: Colors.blue.withOpacity(0.2),
                                    ),
                                    child: const Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
