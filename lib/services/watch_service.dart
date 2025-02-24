import 'package:supabase_flutter/supabase_flutter.dart';

class WatchService {
  final _supabaseClient = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchWatches() async {
    try {
      final response = await _supabaseClient.from('watches').select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch watches: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchWatchDetails(String watchId) async {
    try {
      final response = await _supabaseClient
          .from('watches')
          .select('*')
          .eq('id', watchId)
          .single();

      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching watch: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchProductDetails(int productId) async {
  try {
    final response = await _supabaseClient
        .from('watches')
        .select('*')
        .eq('id', productId)
        .single();

  
    return response as Map<String, dynamic>;
  } catch (e) {
    print('Error fetching product: $e');
    
    return {};
  }
}

Future<Map<String, dynamic>?> addWatch(Map<String, dynamic> watchData) async {
    try {
      final response = await _supabaseClient.from('watches').insert(watchData).select().single();
      return response;
    } catch (e) {
      print("Error adding watch: $e");
      return null;
    }
  }

  // Update a watch
  Future<bool> updateWatch(int id, Map<String, dynamic> updatedData) async {
    try {
      await _supabaseClient.from('watches').update(updatedData).match({'id': id});
      return true;
    } catch (e) {
      print("Error updating watch: $e");
      return false;
    }
  }

  // Delete a watch
  Future<bool> deleteWatch(int id) async {
    try {
      await _supabaseClient.from('watches').delete().match({'id': id});
      return true;
    } catch (e) {
      print("Error deleting watch: $e");
      return false;
    }
  }

}
