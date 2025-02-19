import 'package:flutter/material.dart';

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
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Handle error state
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle empty data state
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No watches available'));
          }

          final watches = snapshot.data!;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two columns in each row
              crossAxisSpacing: 5, // Spacing between columns
              mainAxisSpacing: 5, // Spacing between rows
              childAspectRatio: 0.6, // Adjusted aspect ratio for taller cards
            ),
            itemCount: watches.length,
            itemBuilder: (context, index) {
              final watch = watches[index];
              return Card(
                elevation: 8,
                shadowColor: Colors.blue.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 0.5, color: Colors.blue),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    ClipRRect(
                      child: Image.network(
                        watch['image_url'] ?? '',
                        width: double.infinity, // Make the image fill the card width
                        height: 200, // Set a fixed height for the image
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Buttons section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Edit button
                          ElevatedButton(
                            onPressed: () {
                              // Handle edit action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          // Delete button
                          ElevatedButton(
                            onPressed: () {
                              // Handle delete action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
