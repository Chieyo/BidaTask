import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        height: 812,
        decoration: BoxDecoration(color: const Color(0xffffffff)),
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
                decoration: BoxDecoration(color: const Color(0xff2563eb)),
              ),
            ),
            Positioned(
              left: -252,
              width: 736,
              top: -447,
              height: 1308,
              child: Image.asset(
                'graphics/login-background.png',
                width: 736,
                height: 1308,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: -5,
              width: 270,
              top: 207,
              height: 345,
              child: Image.asset(
                'images/image2_1994102.png',
                width: 270,
                height: 345,
              ),
            ),
            Positioned(
              left: 0,
              width: 375,
              top: 259,
              height: 553,
              child: Container(
                width: 375,
                height: 553,
                decoration: BoxDecoration(
                  color: const Color(0xfffefefe),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3f000000),
                      offset: Offset(0, -3),
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              width: 375,
              top: 764,
              height: 48,
              child: Image.asset(
                'images/image3_1994104.png',
                width: 375,
                height: 48,
              ),
            ),
            Positioned(
              left: 0,
              width: 375,
              top: -1,
              height: 24,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    width: 375,
                    top: 0,
                    height: 24,
                    child: Container(
                      width: 375,
                      height: 24,
                      decoration: BoxDecoration(color: const Color(0xfff5f5f5)),
                    ),
                  ),
                  Positioned(
                    left: 291.042,
                    top: 6,
                    child: Image.asset('images/image_I19941052726.png'),
                  ),
                  Positioned(
                    left: 12.5,
                    top: 4,
                    child: Text(
                      '12:30',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        color: const Color(0xff170e2b),
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: 302,
              height: 378,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Text(
                      'Welcome!',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 32,
                        color: const Color(0xff000000),
                        fontFamily: 'Satoshi-Bold',
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 67,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 327,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xffc5c6cc,
                                                      ),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 16,
                                                          top: 12,
                                                          right: 16,
                                                          bottom: 12,
                                                        ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'Email Address',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  const Color(
                                                                    0xff8f9098,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: 327,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xffc5c6cc,
                                                      ),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 16,
                                                          top: 12,
                                                          right: 16,
                                                          bottom: 12,
                                                        ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'Password',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  const Color(
                                                                    0xff8f9098,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Image.asset(
                                                          'images/image_I19941111431324.png',
                                                          width: 16,
                                                          height: 16,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xff006ffd),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xffffffff),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Not a member? Register now',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xff006ffd),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    width: 327,
                    top: 362,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Or continue with',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 12,
                            color: const Color(0xff71727a),
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 9999,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 75,
              width: 225,
              top: 95,
              height: 135,
              child: Image.asset(
                'images/image4_1994119.png',
                width: 225,
                height: 135,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 193.5,
              width: 40,
              top: 696,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 8,
                  right: 16,
                  bottom: 8,
                ),
                child: Image.asset(
                  'images/image5_1994120.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            Positioned(
              left: 141.5,
              width: 40,
              top: 696,
              height: 40,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xfff3f4f6),
                  borderRadius: BorderRadius.circular(63),
                ),
              ),
            ),
            Positioned(
              left: 156,
              width: 12,
              top: 710,
              height: 12,
              child: Image.asset(
                'images/image6_1994122.png',
                width: 12,
                height: 12,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
