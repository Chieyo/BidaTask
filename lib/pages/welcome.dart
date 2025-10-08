import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<StatefulWidget> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SizedBox(
        width: 375,
        height: 812,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              width: 375,
              top: 0,
              height: 812,
              child: Container(
                width: 375,
                height: 812,
                decoration: BoxDecoration(color: const Color(0xfffefefe)),
              ),
            ),
            Positioned(
              left: -224,
              width: 736,
              top: -359,
              height: 1308,
              child: Image.asset(
                'graphics/splash_background.jpg',
                width: 736,
                height: 1308,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              width: 327,
              top: 389,
              height: 423,
              child: Image.asset(
                'graphics/triangle.png',
                width: 327,
                height: 423,
              ),
            ),
            Positioned(
              left: 38,
              width: 300,
              top: 228,
              height: 180,
              child: Image.asset(
                'graphics/bidatask_logo.PNG',
                width: 300,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 36,
              width: 303,
              top: 408,
              child: Text(
                'Helping you get more done, while you focus on what matter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 16,
                  color: const Color(0xff111827),
                  fontFamily: 'Satoshi-Bold',
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 24,
              width: 327,
              top: 584,
              height: 48,
              child: Container(
                width: 327,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xff006ffd),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 12,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 16,
                          color: const Color(0xffffffff),
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              width: 327,
              top: 647,
              height: 48,
              child: Container(
                width: 327,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xfff3f4f6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 12,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign up',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 16,
                          color: const Color(0xff2563eb),
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
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
