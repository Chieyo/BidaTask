import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
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
                decoration: BoxDecoration(color: const Color(0xfffefefe)),
              ),
            ),
            Positioned(
              left: -252,
              width: 736,
              top: -447,
              height: 1308,
              child: Image.asset(
                'images/image1_1994125.png',
                width: 736,
                height: 1308,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 75,
              width: 225,
              top: 95,
              height: 135,
              child: Image.asset(
                'images/image2_1994126.png',
                width: 225,
                height: 135,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 0,
              width: 375,
              top: 144,
              height: 668,
              child: Container(
                width: 375,
                height: 668,
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
                'images/image3_1994128.png',
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
                    child: Image.asset('images/image_I19941292726.png'),
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
              top: 654,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign Up',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 16,
                                    color: const Color(0xffffffff),
                                    fontFamily: 'Inter-Bold',
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 327,
                    child: Text(
                      'Already have an account? Sign in here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 12,
                        color: const Color(0xff006ffd),
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
              left: 0,
              width: 375,
              top: 162,
              height: 475,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 328,
                          child: Text(
                            'Sign up',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 24,
                              color: const Color(0xff1f2024),
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 9999,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 328,
                          child: Text(
                            'Create an account to get started ',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: const Color(0xff71727a),
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 9999,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 327,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        'Name',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 12,
                                          color: const Color(0xff2e3036),
                                          fontWeight: FontWeight.normal,
                                        ),
                                        maxLines: 9999,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffc5c6cc),
                                          width: 1.5,
                                        ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        width: double.infinity,
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
                                                            Text(
                                                              'Name',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontSize: 14,
                                                                color:
                                                                    const Color(
                                                                      0xff8f9098,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                              maxLines: 9999,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        'Email Address',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 12,
                                          color: const Color(0xff2e3036),
                                          fontWeight: FontWeight.normal,
                                        ),
                                        maxLines: 9999,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffc5c6cc),
                                          width: 1,
                                        ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        width: double.infinity,
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
                                                            Text(
                                                              'name@email.com',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontSize: 14,
                                                                color:
                                                                    const Color(
                                                                      0xff8f9098,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                              maxLines: 9999,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        'Password',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 12,
                                          color: const Color(0xff2e3036),
                                          fontWeight: FontWeight.normal,
                                        ),
                                        maxLines: 9999,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffc5c6cc),
                                          width: 1,
                                        ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        width: double.infinity,
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
                                                            Text(
                                                              'Create a passaword',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontSize: 14,
                                                                color:
                                                                    const Color(
                                                                      0xff8f9098,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                              maxLines: 9999,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Image.asset(
                                              'images/image_I19941401431324.png',
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
                        SizedBox(
                          width: 327,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffc5c6cc),
                                          width: 1,
                                        ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        width: double.infinity,
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
                                                            Text(
                                                              'Confirm password',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                fontSize: 14,
                                                                color:
                                                                    const Color(
                                                                      0xff8f9098,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                              maxLines: 9999,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Image.asset(
                                              'images/image_I19941411431324.png',
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
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xffc5c6cc),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    child: Text(
                                      'I\'ve read and agree with the Terms and Conditions and the Privacy Policy.',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontSize: 12,
                                        color: const Color(0xff71727a),
                                        fontWeight: FontWeight.normal,
                                      ),
                                      maxLines: 9999,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
