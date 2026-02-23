import 'package:flutter/material.dart';
import 'core/supabase/supabase_config.dart';
import 'features/auth/presentation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const BOQSaasApp());
}

class BOQSaasApp extends StatelessWidget {
  const BOQSaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}