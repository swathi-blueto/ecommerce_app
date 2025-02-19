import 'package:ecommerce_app/providers/action_provider.dart';
import 'package:ecommerce_app/views/admin/add_watch.dart';
import 'package:ecommerce_app/views/auth/login/login_screen.dart';
import 'package:ecommerce_app/views/user/actions/cart_screen.dart';
import 'package:ecommerce_app/views/user/actions/orders_screen.dart';
import 'package:ecommerce_app/views/user/actions/wishlist_screen.dart';
import 'package:ecommerce_app/views/user/home/bottom_nav_bar.dart';
import 'package:ecommerce_app/views/user/profile/profile_details.dart';
import 'package:ecommerce_app/views/user/profile/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/services/auth_service.dart';
import 'package:ecommerce_app/services/watch_service.dart';
import "package:ecommerce_app/views/user/watches/watches.dart";
import "package:provider/provider.dart";
import "package:ecommerce_app/providers/auth_provider.dart";



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final _authService = AuthService();
  final _watchService = WatchService();
  late Future<List<Map<String, dynamic>>> _watches;

  @override
  void initState() {
    super.initState();
    _watches = _watchService.fetchWatches();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 0) return;

    Widget nextScreen;
    switch (index) {
      case 1:
        if (Provider.of<AuthProvider>(context, listen: false).isProfileUpdated) {
          nextScreen = ProfileDetailsScreen();
        } else {
          nextScreen = ProfileScreen();
        }
        break;
      case 2:
        nextScreen=CartScreen();
      case 3:
        nextScreen=OrderScreen();
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
@override
Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
  final user = authProvider.user;

  return Scaffold(
    body: SafeArea(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 242, 207, 162),
                  radius: 25,
                  child: Image.asset(
                    "assets/images/user-logo.png",
                    width: 35,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 35, color: Colors.grey);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello",
                        style: TextStyle(
                            color: Color.fromARGB(255, 108, 107, 107))),
                    Text(
                        authProvider.userDetails?['full_name'] ??
                            user?.email ??
                            "Guest",
                        style: TextStyle(
                            color: Color.fromARGB(255, 12, 12, 12))),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WishlistScreen()),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.red),
                ),
                const SizedBox(width: 30),
                InkWell(
                  onTap: () => logout(context),
                  child: const Icon(Icons.logout, color: Colors.purpleAccent),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Watches(watches: _watches),
          ],
        ),
      ),
    ),
    bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex, onItemTapped: onItemTapped),
  );
}
}