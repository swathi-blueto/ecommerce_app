import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Signup method
  Future<String?> signUp(String email, String password, String role) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {"role": role},
      );

      if (response.user != null) {
        final existingProfile = await _supabase
            .from('profiles')
            .select()
            .eq('user_id', response.user!.id)
            .maybeSingle();

        if (existingProfile == null) {
          await _supabase.from('profiles').insert({
            'user_id': response.user!.id,
            'email': email,
            'full_name': '', 
            'phone_number': '',
            'gender': '',
            'state': '',
            'city': '',
            'profile_image': '',
          });
        }
      }

      print(response);
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // Login method
  Future<String?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('user_id', user.id)
            .single();

        return profile['role'] ?? "user"; 
      }
    } on AuthException catch (e) {
      return e.message;
    }
    return null;
  }

  // Logout method
  Future<String?> logout() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String gender,
    required String state,
    required String city,
    String? imageUrl,
  }) async {
    try {
      print("Updating profile for user ID: $userId");

       
      final existingProfile = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      print("Existing profile: $existingProfile");

      if (existingProfile != null) {
        
        await _supabase.from('profiles').update({
          'full_name': fullName,
          'phone_number': phoneNumber,
          'gender': gender,
          'state': state,
          'city': city,
          if (imageUrl != null) 'profile_image': imageUrl,
        }).eq('user_id', userId); 
      } else {
        
        await _supabase.from('profiles').insert({
          'user_id': userId,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'gender': gender,
          'state': state,
          'city': city,
          if (imageUrl != null) 'profile_image': imageUrl,
        });
      }

      print("Profile updated successfully");
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
          .from("profile-pictures")
          .upload(filePath, imageFile, fileOptions: FileOptions(upsert: true));

      final imageUrl =
          _supabase.storage.from("profile-pictures").getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      print("Error uploading profile image: $e");
      return null;
    }
  }
}
