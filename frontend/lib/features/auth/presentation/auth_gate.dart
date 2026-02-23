import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../data/auth_service.dart';
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _authService.authStateChanges.listen((event) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.currentSession != null) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}