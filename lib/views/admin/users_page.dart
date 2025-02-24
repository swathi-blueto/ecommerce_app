import 'package:flutter/material.dart';
import 'package:ecommerce_app/services/user_service.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final fetchedUsers = await _userService.getUsers();
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load users: $e";
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(String userId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        await _userService.deleteUser(userId);
        fetchUsers();
      } catch (e) {
        setState(() {
          errorMessage = "Failed to delete user: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Management"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child:
                        Text(errorMessage, style: TextStyle(color: Colors.red)))
                : users.isEmpty
                    ? Center(
                        child: Text("No users found",
                            style: TextStyle(fontSize: 18)))
                    : ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.teal,
                                        child: Text(
                                          user['name'] != null
                                              ? user['name'][0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['full_name'] ?? 'Unknown',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(height: 4),
                                            Text(user['email'] ?? 'No Email',
                                                style: TextStyle(
                                                    color: Colors.grey[700])),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red, size: 28),
                                        onPressed: () => deleteUser(
                                            user['id']?.toString() ?? ''),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text("Details",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  _buildDetailRow(
                                      "Full Name", user['full_Name'] ?? 'N/A'),
                                  _buildDetailRow(
                                      "Gender", user['gender'] ?? 'N/A'),
                                  _buildDetailRow(
                                      "Phone", user['phone'] ?? 'N/A'),
                                  _buildDetailRow(
                                      "City", user['city'] ?? 'N/A'),
                                  _buildDetailRow(
                                      "State", user['state'] ?? 'N/A'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
