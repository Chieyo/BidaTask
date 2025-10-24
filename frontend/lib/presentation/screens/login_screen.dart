import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate top position as a percentage of screen height
    final topPosition =
        screenHeight * 0.32; // Approximately 259/812 of the screen height

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 51),
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
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xffc5c6cc),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff8f9098),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xffc5c6cc),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff8f9098),
                                ),
                              ),
                              Image.asset(
                                'assets/images/hidepassword.png',
                                width: 16,
                                height: 16,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.lock_outline,
                                    size: 16,
                                    color: Color(0xff8f9098),
                                  );
                                },
                              ),
                            ],
                          ),
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
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006ffd),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
                            onPressed: () {
                              // TODO: Navigate to register screen
                            },
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
          ],
        ),
      ),
    );
  }
}
