import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stockie_app/theme/app_theme.dart';
import 'package:stockie_app/services/auth_service.dart';
import 'package:stockie_app/services/inventory_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final user = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (user != null) {
      await InventoryService().loadData(); // Load user-specific data
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to your Stockie account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.mail_outline, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 32),
                // OR Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 32),
                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: AppTheme.textDark,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.string(
                          '''<svg class="h-6 w-6" fill="none" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
<path d="M22.56 12.25C22.56 11.45 22.49 10.68 22.36 9.92H12V14.4H18.04C17.74 15.93 16.93 17.24 15.66 18.09V20.4H19.2C21.32 18.45 22.56 15.62 22.56 12.25Z" fill="#4285F4"></path>
<path d="M12 23C14.97 23 17.45 22.02 19.2 20.4L15.66 18.09C14.66 18.78 13.43 19.21 12 19.21C9.42 19.21 7.21 17.56 6.38 15.25H2.74V17.7C4.52 20.89 7.99 23 12 23Z" fill="#34A853"></path>
<path d="M6.38 15.25C6.15 14.56 6.04 13.83 6.04 13.09C6.04 12.35 6.15 11.62 6.38 10.93V8.5H2.74C1.93 10.03 1.48 11.53 1.48 13.09C1.48 14.65 1.93 16.15 2.74 17.7L6.38 15.25Z" fill="#FBBC05"></path>
<path d="M12 6.99C13.58 6.99 14.95 7.54 15.99 8.52L19.27 5.25C17.45 3.55 14.97 2.58 12 2.58C7.99 2.58 4.52 4.71 2.74 8.5L6.38 10.93C7.21 8.62 9.42 6.99 12 6.99Z" fill="#EA4335"></path>
</svg>''',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Login with Google',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
