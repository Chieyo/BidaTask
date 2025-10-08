import 'package:flutter/material.dart';
import 'pages/splash.dart';
import 'pages/welcome.dart';
import 'pages/onboarding_1.dart' as onboarding1;
import 'pages/onboarding_2.dart' as onboarding2;
import 'pages/onboarding_3.dart' as onboarding3;
import 'pages/onboarding_4.dart' as onboarding4;
import 'pages/onboarding_5.dart' as onboarding5;
import 'pages/login.dart';
import 'pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BidaTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScreenTestMenu(),
    );
  }
}

class ScreenTestMenu extends StatelessWidget {
  const ScreenTestMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BidaTask - Screen Test Menu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tap any screen to test it:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildScreenButton(context, 'Splash Screen', const SplashPage()),
          _buildScreenButton(context, 'Welcome Screen', const WelcomePage()),
          const Divider(height: 30),
          const Text(
            'Onboarding Screens:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildScreenButton(context, 'Onboarding 1', const onboarding1.CodiaPage()),
          _buildScreenButton(context, 'Onboarding 2', const onboarding2.CodiaPage()),
          _buildScreenButton(context, 'Onboarding 3', const onboarding3.CodiaPage()),
          _buildScreenButton(context, 'Onboarding 4', const onboarding4.CodiaPage()),
          _buildScreenButton(context, 'Onboarding 5', const onboarding5.CodiaPage()),
          const Divider(height: 30),
          const Text(
            'Authentication Screens:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildScreenButton(context, 'Login Screen', const LoginPage()),
          _buildScreenButton(context, 'Signup Screen', const SignupPage()),
        ],
      ),
    );
  }

  Widget _buildScreenButton(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.blue.shade900,
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
