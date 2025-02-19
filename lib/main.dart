import 'package:ecommerce_app/app.dart';
import 'package:ecommerce_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main ()async {
  WidgetsFlutterBinding.ensureInitialized();
  
 await dotenv.load(fileName: "lib/.env"); 
  await SupabaseService.initialize();
  print("Im executing");
  
  runApp(MyApp());
}

