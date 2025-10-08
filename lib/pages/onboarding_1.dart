import 'package:flutter/material.dart';

class CodiaPage extends StatefulWidget {
  const CodiaPage({super.key});

  @override
  State<StatefulWidget> createState() => _CodiaPage();
}

class _CodiaPage extends State<CodiaPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            width: 375,
            top: 0,
            height: 812,
            child: Image.asset(
              'graphics/onboarding-background.png',
              width: 375,
              height: 812,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 325,
            top: 42,
            child: Text(
              'Skip',
              textAlign: TextAlign.center,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 18,
                color: const Color(0xffadb2b9),
                fontFamily: 'GillSansMT',
                fontWeight: FontWeight.normal,
              ),
              maxLines: 9999,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            left: 20,
            width: 335,
            top: 702,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff2563eb),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 16,
                          color: Color(0xfffefefe),
                          fontFamily: 'Inter-Regular',
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 33,
            width: 309,
            top: 470,
            child: Text(
              'Life\'s too busy for endless errands.',
              textAlign: TextAlign.center,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 30,
                color: const Color(0xff1b1e28),
                fontFamily: 'Geist-Bold',
                fontWeight: FontWeight.normal,
              ),
              maxLines: 9999,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            left: 36,
            width: 303,
            top: 561.296,
            child: Text(
              'With BidaTask, get help or lend a hand—right when you need it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 16,
                color: const Color(0xff7c838d),
                fontFamily: 'GillSansMT',
                fontWeight: FontWeight.normal,
              ),
              maxLines: 9999,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            left: 147,
            width: 82,
            top: 656,
            height: 8,
            child: Image.asset(
              'graphics/page-control1.png',
              width: 82,
              height: 8,
            ),
          ),
          Positioned(
            left: 10,
            width: 356,
            top: 95,
            height: 356,
            child: Image.asset(
              'graphics/onboarding1_graphic.png',
              width: 356,
              height: 356,
            ),
          ),
        ],
      ),
    );
  }
}
