import 'package:ecommerce_app/providers/action_provider.dart';
import 'package:ecommerce_app/providers/auth_provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';

import 'package:ecommerce_app/views/auth/login/login_screen.dart';
import 'package:ecommerce_app/views/user/home/home_screen.dart';
import 'package:ecommerce_app/views/admin/admin_dashboard.dart'; // Import Admin Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context)=>CartProvider()),
        ChangeNotifierProvider(create: (context)=>ActionProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated()) {
            String role = authProvider.role ?? "user";

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "E-commerce App",
              theme: ThemeData(primarySwatch: Colors.cyan),
              home: role == "admin" ? AdminDashboard() : HomeScreen(),
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "E-commerce App",
              theme: ThemeData(primarySwatch: Colors.cyan),
              home: LoginScreen(),
            );
          }
        },
      ),
    );
  }
}