import 'package:flutter/material.dart';
import '../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMagicLink() async {
    setState(() => _isLoading = true);

    await _authService.sendMagicLink(
      _emailController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Magic link sent! Check your email."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "BOQ SaaS Login",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendMagicLink,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Send Magic Link"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}