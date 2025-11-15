import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  void _loginPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _signUpPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Welcome Text
            Positioned(
              left: 0,
              right: 0,
              top: 450,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Text(
                  'Helping you get more done, while you focus on what matters',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 2, 49, 152),
                    fontFamily: 'Satoshi-Bold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Sign In Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 170,
              child: ElevatedButton(
                onPressed: _loginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006ffd),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Satoshi-Bold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Sign Up Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 100,
              child: ElevatedButton(
                onPressed: _signUpPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff3f4f6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff2563eb),
                    fontWeight: FontWeight.bold,
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
