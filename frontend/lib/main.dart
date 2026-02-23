import 'package:flutter/material.dart';
import 'package:frontend/core/supabase/supabase_config.dart';
import 'package:frontend/features/auth/presentation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  runApp(const BOQSaasApp());
}

class BOQSaasApp extends StatelessWidget {
  const BOQSaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOQ SaaS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthGate(),
    );
  }
}
