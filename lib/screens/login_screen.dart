import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import '../widgets/celestial_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0F1A),
          title: const Text("Reset Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: resetEmailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter your registered email",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await _authService.sendPasswordResetEmail(email);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent! Check your inbox.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
                    }
                  }
                }
              },
              child: const Text("Send Link", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: -5)
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 0.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 1.0, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPremiumButton(BuildContext context, String text, VoidCallback onPressed, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.tertiary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  text.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 4.0,
                  ),
                ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds, color: Colors.white24);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CelestialBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Image.asset('assets/app-icon.png', fit: BoxFit.contain),
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.95, end: 1.05, duration: 4.seconds)
                  .then().shimmer(duration: 2.seconds),
                const SizedBox(height: 32),
                const Text(
                  "LUMINA AI",
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 8.0, fontSize: 26, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Login to your account",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, letterSpacing: 2.0, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                _buildPremiumTextField(
                  controller: _emailController,
                  hint: "Email Address",
                  icon: Icons.fingerprint,
                ),
                const SizedBox(height: 20),
                _buildPremiumTextField(
                  controller: _passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text("Forgot Password?", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 12),
                _buildPremiumButton(context, "LOGIN", _login, _isLoading),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                  },
                  child: const Text("First time here? Register", style: TextStyle(color: Colors.white60, letterSpacing: 1.0, fontSize: 12)),
                )
              ],
            ).animate().fade(duration: 1.seconds).slideY(begin: 0.1),
          ),
        ),
      ),
    );
  }
}
