import 'package:flutter/material.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUpPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual login logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate network call

      // Navigate to home screen on success
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: const Color(0xffffffff),
        child: Stack(
          children: [
            // Background color container
            Container(
              width: screenWidth,
              height: screenHeight,
              color: const Color(0xff2563eb),
            ),
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/login-background.png',
                fit: BoxFit.cover,
              ),
            ),
            // Main content container
            Positioned(
              left: 0,
              right: 0,
              top: 280,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xfffefefe),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3f000000),
                      offset: Offset(0, -3),
                      blurRadius: 7,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff000000),
                            fontFamily: 'Satoshi-Bold',
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ready to get things done? Let’s go.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff1f2937),
                              fontFamily: 'Satoshi-Bold',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Email Field
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff2e3036),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xffc5c6cc),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xff8f9098),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password Field
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff2e3036),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xffc5c6cc),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color(0xff8f9098),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color(0xff8f9098),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff006ffd),
                              fontFamily: 'Satoshi-Bold',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff006ffd),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: const Color(0xffa0c4ff),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Not a member text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Not a member?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff71727a),
                              ),
                            ),
                            TextButton(
                              onPressed: _signUpPressed,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Register now',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff006ffd),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Divider
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: const Color(0xFFE5E7EB),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF71717A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Google Button
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Handle Google sign in
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xffe5e7eb)),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google-logo.png',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff1f2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
