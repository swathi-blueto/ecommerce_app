import 'package:ecommerce_app/views/admin/add_watch.dart';
import 'package:ecommerce_app/views/admin/orders_page.dart';
import 'package:ecommerce_app/views/admin/product_list.dart';
import 'package:ecommerce_app/views/admin/users_page.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/views/auth/login/login_screen.dart';
import 'package:ecommerce_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _authService = AuthService();
  String adminName = "Admin";
  String adminEmail = "admin@gmail.com";
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> recentOrders = [];
  List<Map<String, dynamic>> recentUsers = [];
  int totalOrders = 0;
  int totalUsers = 0;

  @override
  void initState() {
    super.initState();
    fetchAdminName();
    fetchRecentOrders();
    fetchRecentUsers();
    fetchTotalOrders();
    fetchTotalUsers();
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

  Future<void> fetchRecentOrders() async {
    final response = await supabase
        .from('orders')
        .select('*')
        .order('created_at', ascending: false)
        .limit(5);

    setState(() {
      recentOrders = response;
    });
  }

  Future<void> fetchRecentUsers() async {
    final response = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', ascending: false)
        .limit(5);

    setState(() {
      recentUsers = response;
    });
  }

  Future<void> fetchTotalOrders() async {
    final response = await supabase.from('orders').select('*');
    print("total orders ${response.length}");

    setState(() {
      totalOrders = response.length;
    });
  }

  Future<void> fetchTotalUsers() async {
    final response = await supabase.from('profiles').select('*');

    setState(() {
      totalUsers = response.length;
    });
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
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    adminName,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    adminEmail,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, "Dashboard", context, AdminDashboard()),
            _buildDrawerItem(Icons.shopping_cart, "Orders", context, OrdersPage()),
            _buildDrawerItem(Icons.category, "Products", context, ProductList()),
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
              SizedBox(height: 20),
              _buildRecentUsers(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recent Orders",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: recentOrders.length,
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return ListTile(
                    leading: Icon(Icons.shopping_bag, color: Colors.blue),
                    title: Text("Order: ${order['product_name']}"),
                    subtitle: Text("Status: ${order['payment_status']}"),
                    trailing: Text("\₹${order['total_amount']}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsers() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New Users",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: recentUsers.length,
                itemBuilder: (context, index) {
                  final user = recentUsers[index];
                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['username'] ?? "Unknown"),
                    subtitle: Text(user['email'] ?? "No email"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 0.9,
      padding: EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard("Total Orders", totalOrders.toString(), Icons.shopping_cart, Colors.blue),
        _buildStatCard("Total Users", totalUsers.toString(), Icons.person, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
    );
  }
}