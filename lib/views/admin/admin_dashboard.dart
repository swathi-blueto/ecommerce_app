import 'package:ecommerce_app/views/admin/add_watch.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/views/auth/login/login_screen.dart';
import 'package:ecommerce_app/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _authService = AuthService();
  String adminName = "Admin";
  String adminEmail = "admin@gmail.com";

  @override
  void initState() {
    super.initState();
    fetchAdminName();
  }

  Future<void> fetchAdminName() async {
    var user = await _authService.getCurrentUser();
    if (user != null && user.email != null) {
      setState(() {
        adminName = user.email!.split('@')[0];
        adminEmail = user.email!;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CircleAvatar(
                  //   radius: 30,
                  //   backgroundImage: AssetImage("assets/admin_avatar.png"),
                  // ),
                  SizedBox(height: 10),
                  Text(
                    adminName, // Display the fetched admin name
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    adminEmail,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
                Icons.dashboard, "Dashboard", context, AdminDashboard()),
            _buildDrawerItem(
                Icons.shopping_cart, "Orders", context, OrdersPage()),
            _buildDrawerItem(
                Icons.category, "Products", context, ProductsPage()),
            _buildDrawerItem(Icons.person, "Users", context, UsersPage()),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout"),
              onTap: () async {
                await logout(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDashboardStats(),
              SizedBox(height: 20),
               _buildRecentOrders(),
             _buildRecentUsers(),
              InkWell(
                child: Text(
                  "Add Product",
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWatchPage(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      IconData icon, String title, BuildContext context, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destination));
      },
    );
  }
}

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Orders")),
        body: Center(child: Text("Orders Page")));
  }
}

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Products")),
        body: Center(child: Text("Products Page")));
  }
}

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Users")),
        body: Center(child: Text("Users Page")));
  }
}
Widget _buildRecentUsers() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "New Users",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 200, // Set a fixed height for the ListView
        child: ListView.builder(
          itemCount: 5, // Dummy data count
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text("User ${index + 1}"),
              subtitle: Text("user${index + 1}@email.com"),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildRecentOrders() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Recent Orders",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 200, // Set a fixed height for the ListView
        child: ListView.builder(
          itemCount: 5, // Dummy data count
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.blue),
              title: Text("Order #100${index + 1}"),
              subtitle: Text("Status: Pending"),
              trailing: Text("\$${(index + 1) * 20}"),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildDashboardStats() {
  return GridView.count(
    shrinkWrap: true,
    crossAxisCount: 2,
    padding: EdgeInsets.all(16),
    children: [
      _buildStatCard("Total Orders", "250", Icons.shopping_cart, Colors.blue),
      _buildStatCard("Total Products", "50", Icons.category, Colors.green),
      _buildStatCard("Total Users", "100", Icons.person, Colors.orange),
      _buildStatCard("Revenue", "\$12,500", Icons.monetization_on, Colors.red),
    ],
  );
}

Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  return Card(
    elevation: 3,
    child: Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 10),
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  fontSize: 18, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
