import 'package:flutter/material.dart';

class CodiaPage extends StatefulWidget {
  const CodiaPage({super.key});

  @override
  State<StatefulWidget> createState() => _CodiaPage();
}

class _CodiaPage extends State<CodiaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'graphics/onboarding-background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 325,
            top: 42,
            child: Text(
              'Skip',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xffadb2b9),
                fontFamily: 'GillSansMT',
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 54,
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xfffefefe),
                  fontFamily: 'Inter-Regular',
                ),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 21,
            top: 487,
            child: Text(
              'Your time, your terms.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                color: Color(0xff1b1e28),
                fontFamily: 'Geist-Bold',
              ),
              maxLines: 2,
            ),
          ),
          const Positioned(
            left: 40,
            right: 41,
            top: 561,
            child: Text(
              'Choose tasks that fit your schedule and earn with flexibility.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff7c838d),
                fontFamily: 'GillSansMT',
              ),
              maxLines: 2,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 84,
            child: Center(
              child: Image.asset(
                'graphics/page-control3.png',
                width: 82,
                height: 8,
              ),
            ),
          ),
          Positioned(
            left: 11,
            right: 10,
            top: 105,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                'graphics/onboarding3_graphic.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
