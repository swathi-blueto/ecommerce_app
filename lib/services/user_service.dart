import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _supabase.from('profiles').select('*');
      print("Fetched users: $response"); // Debugging
      return response;
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('profiles').delete().match({'id': userId});
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}