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

}
