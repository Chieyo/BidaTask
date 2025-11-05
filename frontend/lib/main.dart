import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding1_screen.dart';
import 'presentation/screens/onboarding2_screen.dart';
import 'presentation/screens/onboarding3_screen.dart';
import 'presentation/screens/onboarding4_screen.dart';
import 'presentation/screens/onboarding5_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/otp_verification.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BidaTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff006ffd)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/otp-verification': (context) => const OtpVerification(),
        '/onboarding1': (context) => Onboarding1Screen(),
        '/onboarding2': (context) => Onboarding2Screen(),
        '/onboarding3': (context) => Onboarding3Screen(),
        '/onboarding4': (context) => Onboarding4Screen(),
        '/onboarding5': (context) => Onboarding5Screen(),
      },
    );
  }
}
