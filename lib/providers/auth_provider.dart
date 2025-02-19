import 'package:ecommerce_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _user;
  String? _role;

  User? get user => _user;
  String? get role => _role;

  Map<String, dynamic>? _userDetails;
  String? _userProfileImage;

  Map<String, dynamic>? get userDetails => _userDetails;
  String? get userProfileImage => _userProfileImage;

  bool isProfileUpdated = false; // Add this property

  AuthProvider() {
    _loadUserSession();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        _user = session?.user;
        _loadUserSession();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _role = null;
        _userDetails = null;
        _userProfileImage = null;
        isProfileUpdated = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserSession() async {
    _user = _authService.getCurrentUser();
    if (_user != null) {
      await _fetchUserRole();
      await fetchUserProfile(_user!.id);
    }
    notifyListeners();
  }

  // Fetch role from Supabase users table
  Future<void> _fetchUserRole() async {
    if (_user != null) {
      final userMetadata = _user!.userMetadata;
      _role = userMetadata?["role"] ?? "user"; 
      notifyListeners();
    }
  }

  // Fetch user profile details
  Future<void> fetchUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();

      _userDetails = response;
      _userProfileImage = response['profile_image'];

      
      if (_userDetails != null && _userDetails!.isNotEmpty) {
        isProfileUpdated = true;
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching user profile: $e");
      isProfileUpdated = false;
    }
  }

  // SignUp Function
  Future<String?> register(String email, String password, String role) async {
    try {
      String? error = await _authService.signUp(email, password, role);
      if (error == null) {
        _user = _authService.getCurrentUser();
        _role = role; 
        notifyListeners();
      }
      return error;
    } catch (e) {
      return e.toString();
    }
  }

  // Login Function
  Future<String?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user; 
        await _fetchUserRole(); 
        await fetchUserProfile(_user!.id); 
        notifyListeners();
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Logout Function
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _role = null;
    _userDetails = null;
    _userProfileImage = null;
    isProfileUpdated = false;
    notifyListeners(); 
  }

  // Check Authentication
  bool isAuthenticated() {
    return _user != null;
  }

  // Update user profile

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String state,
    required String city,
    String? imageUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _authService.updateUserProfile(
        userId: user.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        gender: gender,
        state: state,
        city: city,
        imageUrl: imageUrl,
      );

    
      _userDetails = {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'gender': gender,
        'state': state,
        'city': city,
      };
      _userProfileImage = imageUrl;

      isProfileUpdated = true; 
      notifyListeners(); // Refresh the UI
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final filePath = "profile_images/${user.id}.jpg";

      await _supabase.storage
          .from("profile_pictures")
          .upload(filePath, imageFile, fileOptions: FileOptions(upsert: true));

      final imageUrl =
          _supabase.storage.from("profile_pictures").getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      print("Error uploading profile image: $e");
      return null;
    }
  }
}
