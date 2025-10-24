import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _termsAccepted = false;

  void _loginPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              top: 120,
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
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 40,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff000000),
                          fontFamily: 'Satoshi-Bold',
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Create an account to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff1f2937),
                          fontFamily: 'Satoshi-Bold',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name Field
                      const Text(
                        'Full Name',
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
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Enter your full name',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff8f9098),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Enter your email',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff8f9098),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Contact Number Field
                      const Text(
                        'Contact Number',
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
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Enter your contact number',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff8f9098),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Age Field
                      const Text(
                        'Age',
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
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Enter your age',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff8f9098),
                                ),
                              ),
                            ],
                          ),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Enter your password',
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
                      const SizedBox(height: 12),

                      // Confirm Password Field
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
                                'Confirm your password',
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
                      // Terms and Conditions Checkbox
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: const Color(
                                    0xffc5c6cc,
                                  ),
                                ),
                                child: Checkbox(
                                  value: _termsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xff006ffd),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: const BorderSide(
                                    color: Color(0xffc5c6cc),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff6b7280),
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "I've read and agree to the ",
                                    ),
                                    TextSpan(
                                      text: 'Terms and Condition ',
                                      style: const TextStyle(
                                        color: Color(0xff006ffd),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Handle Terms tap
                                        },
                                    ),
                                    const TextSpan(text: 'and to the '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        color: Color(0xff006ffd),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Handle Privacy Policy tap
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle sign up
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006ffd),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff6b7280),
                            ),
                          ),
                          TextButton(
                            onPressed: _loginPressed,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff006ffd),
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}
