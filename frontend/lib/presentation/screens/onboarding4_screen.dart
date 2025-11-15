import 'package:flutter/material.dart';
import 'onboarding5_screen.dart';

class Onboarding4Screen extends StatefulWidget {
  const Onboarding4Screen({super.key});

  @override
  State<Onboarding4Screen> createState() => _Onboarding4Screen();
}

class _Onboarding4Screen extends State<Onboarding4Screen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Background image that covers the entire screen
            SizedBox.expand(
              child: Image.asset(
                'assets/images/onboarding-background.png',
                fit: BoxFit.cover,
                width: screenSize.width,
                height: screenSize.height,
              ),
            ),
            // Skip button (right-aligned)
            Positioned(
              right: 20,
              top: 50,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: const Color(0xffadb2b9),
                  fontSize: 18,
                  fontFamily: 'Satoshi-Medium',
                ),
              ),
            ),
            // Main graphic (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 120,
              child: Center(
                child: Image.asset(
                  'assets/images/onboarding4_graphic.png',
                  width: 356,
                  height: 356,
                ),
              ),
            ),
            // Title (centered)
            Positioned(
              left: 20,
              right: 20,
              top: 510,
              child: Center(
                child: SizedBox(
                  width: 309,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        color: Color(0xff1b1e28),
                        fontFamily: 'Geist-Bold',
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      children: const <TextSpan>[
                        TextSpan(text: 'See tasks around you, '),
                        TextSpan(
                          text: 'instantly.',
                          style: TextStyle(color: Color(0xFFFACC15)),
                        ),
                      ],
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ),
            // Subtitle (centered)
            Positioned(
              left: 20,
              right: 20,
              top: 600,
              child: const Center(
                child: SizedBox(
                  width: 303,
                  child: Text(
                    'Our live map keeps you connected to nearby opportunities.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff7c838d),
                      fontFamily: 'Satoshi-Bold',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ),
            // Page indicator (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 756,
              child: Center(
                child: Image.asset(
                  'assets/images/page-control4.png',
                  width: 82,
                  height: 8,
                ),
              ),
            ),
            // Get Started button (centered with horizontal padding)
            Positioned(
              left: 20,
              right: 20,
              bottom: 60,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Onboarding5Screen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006ffd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
