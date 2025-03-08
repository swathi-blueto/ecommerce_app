import 'package:flutter/material.dart';
import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Fetch user profile details if not already loaded
    if (authProvider.userDetails == null && authProvider.user?.id != null) {
      authProvider.fetchUserProfile(authProvider.user!.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
        elevation: 4,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
            
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[100],
                  backgroundImage: authProvider.userProfileImage != null
                      ? NetworkImage(authProvider.userProfileImage!)
                      : AssetImage("assets/images/user-logo.png") as ImageProvider,
                ),
              ),
              SizedBox(height: 30),

             
              Card(
                elevation: 5,
                shadowColor: Colors.blue.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileField("Full Name", authProvider.userDetails?['full_name']),
                      Divider(),
                      _buildProfileField("Phone Number", authProvider.userDetails?['phone_number']),
                      Divider(),
                      _buildProfileField("Gender", authProvider.userDetails?['gender']),
                      Divider(),
                      _buildProfileField("State", authProvider.userDetails?['state']),
                      Divider(),
                      _buildProfileField("City", authProvider.userDetails?['city']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 5),
          Text(
            value ?? 'Not Available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}