import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SupabaseService {
  final _storage = FlutterSecureStorage();
  late final SupabaseClient _supabase;

  SupabaseService() {
    _supabase = Supabase.instance.client;
  }

  SupabaseClient get client => _supabase;

  static Future<void> initialize() async {
    await dotenv.load(fileName: "lib/.env");
    await Supabase.initialize(
        url: dotenv.env["SUPABASE_URL"]!, 
        anonKey: dotenv.env["SUPABASE_KEY"]!
        );
  }
}
