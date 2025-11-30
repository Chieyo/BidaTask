import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final result = await _authService.getProfile();
      if (result['success'] == true) {
        setState(() {
          _userData = result['user'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AnimatedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_userData == null) {
      return AnimatedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Text(
              'Failed to load profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final String fullName = _userData!['fullName'] ?? 'Unknown User';
    final String email = _userData!['email'] ?? 'No email';
    final String contactNumber = _userData!['contactNumber'] ?? 'No contact';
    final String age = _userData!['age']?.toString() ?? 'Not specified';
    final String trustTier = _userData!['trustTier']?.toString() ?? '1';
    final double rating = _userData!['rating']?.toDouble() ?? 0.0;
    final int completedTasks = _userData!['completedTasks'] ?? 0;
    final int postedTasks = _userData!['postedTasks'] ?? 0;

    return AnimatedBackground(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            width: 375,
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
            ),
            child: Stack(children: [
              Positioned(
                left: 0,
                width: 375,
                top: 0,
                height: 184,
                child: Container(
                  width: 375,
                  height: 184,
                  decoration: BoxDecoration(
                    color: const Color(0xff2563eb),
                  ),
                ),
              ),
              Positioned(
                left: 127,
                width: 122,
                top: 107,
                height: 127,
                child: UserAvatar(
                  initial: fullName,
                  size: 122,
                  fontSize: 48,
                ),
              ),
              Positioned(
                left: 53,
                top: 248,
                child: Text(
                  fullName,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 22,
                      color: const Color(0xff111827),
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 151,
                top: 279,
                child: Text(
                  '${rating.toStringAsFixed(1)} ',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 14,
                      color: const Color(0xff263238),
                      fontFamily: 'Satoshi-Black',
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 116,
                top: 312,
                child: Text(
                  'Completed: $completedTasks    Posted: $postedTasks',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 12,
                      color: const Color(0xff495057),
                      fontFamily: 'Satoshi-Medium',
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 334,
                width: 25,
                top: 42,
                height: 25,
                child: Image.asset(
                  'assets/images/3dots.png',
                  width: 25,
                  height: 25,
                ),
              ),
              Positioned(
                left: 25,
                width: 20,
                top: 45,
                height: 20,
                child: Image.asset(
                  'assets/images/back_button.png',
                  width: 20,
                  height: 20,
                ),
              ),
              Positioned(
                left: 77,
                width: 221,
                top: 41,
                height: 28,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      width: 221,
                      top: 0,
                      child: Text(
                        'My Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 22,
                            color: const Color(0xfffefefe),
                            fontFamily: 'Poppins-SemiBold',
                            fontWeight: FontWeight.normal),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 132,
                width: 14,
                top: 282,
                height: 13,
                child: Image.asset(
                  'assets/images/Star.png',
                  width: 14,
                  height: 13,
                ),
              ),
              Positioned(
                left: 189,
                top: 281,
                child: Text(
                  'Trust Tier $trustTier',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 11,
                      color: const Color(0xff414f58),
                      fontFamily: 'Satoshi-Medium',
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 181,
                width: 1,
                top: 284,
                height: 10,
                child: Image.asset(
                  'assets/images/line.png',
                  width: 1,
                  height: 10,
                ),
              ),
              Positioned(
                left: 24,
                width: 327,
                top: 355,
                height: 136,
                child: Container(
                  width: 327,
                  height: 136,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        width: 327,
                        top: 0,
                        height: 136,
                        child: Container(
                          width: 327,
                          height: 136,
                          decoration: BoxDecoration(
                            color: const Color(0xfff9fafb),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x3f000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 3),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 19,
                        top: 12,
                        child: Text(
                          'Personal Info',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 15,
                              color: const Color(0xff343a40),
                              fontFamily: 'Satoshi-Bold',
                              fontWeight: FontWeight.normal),
                          maxLines: 9999,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Positioned(
                        left: 19,
                        top: 39,
                        child: Text(
                          'Bio: ${_userData!['bio'] ?? 'No bio provided'}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: const Color(0xff495057),
                              fontFamily: 'Satoshi-Bold',
                              fontWeight: FontWeight.normal),
                          maxLines: 9999,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Positioned(
                        left: 19,
                        top: 60,
                        child: Text(
                          'Email: $email',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: const Color(0xff495057),
                              fontFamily: 'Satoshi-Bold',
                              fontWeight: FontWeight.normal),
                          maxLines: 9999,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Positioned(
                        left: 19,
                        top: 81,
                        child: Text(
                          'Contact Number: $contactNumber',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: const Color(0xff495057),
                              fontFamily: 'Satoshi-Bold',
                              fontWeight: FontWeight.normal),
                          maxLines: 9999,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Positioned(
                        left: 19,
                        top: 102,
                        child: Text(
                          'Age: $age',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: const Color(0xff495057),
                              fontFamily: 'Satoshi-Bold',
                              fontWeight: FontWeight.normal),
                          maxLines: 9999,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                width: 327,
                top: 512,
                height: 83,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      width: 327,
                      top: 0,
                      height: 83,
                      child: Container(
                        width: 327,
                        height: 83,
                        decoration: BoxDecoration(
                          color: const Color(0xfff9fafb),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x3f000000),
                                offset: Offset(0, 1),
                                blurRadius: 3),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 19,
                      top: 12,
                      child: Text(
                        'Primary Categories',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 15,
                            color: const Color(0xff343a40),
                            fontFamily: 'Satoshi-Bold',
                            fontWeight: FontWeight.normal),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Positioned(
                      left: 19,
                      width: 61,
                      top: 43,
                      height: 22,
                      child: Container(
                        width: 61,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              width: 61,
                              top: 0,
                              height: 22,
                              child: Container(
                                width: 61,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xffd1e7dd),
                                  border: Border.all(
                                      color: const Color(0xffa3cfbb),
                                      width: 0.30000001192092896),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 13,
                              top: 1,
                              child: Text(
                                'Chores',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 10,
                                    color: const Color(0xff14ae5c),
                                    fontWeight: FontWeight.normal),
                                maxLines: 9999,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 89,
                      width: 117,
                      top: 43,
                      height: 22,
                      child: Container(
                        width: 117,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              width: 117,
                              top: 0,
                              height: 22,
                              child: Container(
                                width: 117,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: const Color(0xffcfe2ff),
                                  border: Border.all(
                                      color: const Color(0xff9ec5fe),
                                      width: 0.30000001192092896),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12.027,
                              top: 1,
                              child: Text(
                                'General Assistance',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 10,
                                    color: const Color(0xff2563eb),
                                    fontWeight: FontWeight.normal),
                                maxLines: 9999,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 24,
                width: 327,
                top: 766,
                height: 170,
                child: Container(
                  width: 327,
                  height: 170,
                  decoration: BoxDecoration(
                    color: const Color(0xfff9fafb),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x3f000000),
                          offset: Offset(0, 1),
                          blurRadius: 3),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 43,
                top: 778,
                child: Text(
                  'Setting',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 15,
                      color: const Color(0xff343a40),
                      fontFamily: 'Satoshi-Bold',
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 25,
                width: 327,
                top: 616,
                height: 129,
                child: Container(
                  width: 327,
                  height: 129,
                  decoration: BoxDecoration(
                    color: const Color(0xfff9fafb),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x3f000000),
                          offset: Offset(0, 1),
                          blurRadius: 3),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 44,
                top: 628,
                child: Text(
                  'Wallet',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 15,
                      color: const Color(0xff343a40),
                      fontFamily: 'Satoshi-Bold',
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 319,
                width: 12,
                top: 529,
                height: 12,
                child: Image.asset(
                  'assets/images/edit.png',
                  width: 12,
                  height: 12,
                ),
              ),
              Positioned(
                left: 24,
                width: 327,
                top: 956,
                height: 46,
                child: Container(
                  width: 327,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xffef5350),
                          offset: Offset(0, 1),
                          blurRadius: 2),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        width: 327,
                        top: 0,
                        height: 46,
                        child: Container(
                          width: 327,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xfff8f9fa),
                            border: Border.all(
                                color: const Color(0xfff44336), width: 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _logout,
                        child: Positioned(
                          left: 138,
                          top: 15,
                          child: Text(
                            'Logout',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                fontSize: 16,
                                color: Color(0xffe53935),
                                fontFamily: 'Inter-Bold',
                                fontWeight: FontWeight.normal),
                            maxLines: 9999,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 43,
                top: 809,
                child: Text(
                  'Enable Auto Matching',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 12,
                      color: const Color(0xff495057),
                      fontFamily: 'Geist-Medium',
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 43,
                top: 898,
                child: Text(
                  'Enable Nearby Task Notification',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 12,
                      color: const Color(0xff495057),
                      fontFamily: 'Geist-Medium',
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 39,
                width: 296,
                top: 851,
                height: 37,
                child: Container(
                  width: 296,
                  height: 37,
                  decoration: BoxDecoration(
                    color: const Color(0xfff9fafb),
                    border:
                        Border.all(color: const Color(0xffe0e0e0), width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                left: 311,
                width: 12,
                top: 864,
                height: 12,
                child: Image.asset(
                  'assets/images/edit.png',
                  width: 12,
                  height: 12,
                ),
              ),
              Positioned(
                left: 43,
                top: 830,
                child: Text(
                  'Match Category:',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 12,
                      color: const Color(0xff495057),
                      fontFamily: 'Geist-Medium',
                      fontWeight: FontWeight.normal),
                  maxLines: 9999,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 303,
                width: 28,
                top: 808,
                height: 17,
                child: Image.asset(
                  'assets/images/Toggle.png',
                  width: 28,
                  height: 17,
                ),
              ),
              Positioned(
                left: 303,
                width: 28,
                top: 897,
                height: 17,
                child: Image.asset(
                  'assets/images/Toggle.png',
                  width: 28,
                  height: 17,
                ),
              ),
              Positioned(
                left: 49,
                width: 72,
                top: 859,
                height: 22,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      width: 72,
                      top: 0,
                      height: 22,
                      child: Container(
                        width: 72,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xffd1e7dd),
                          border: Border.all(
                              color: const Color(0xffa3cfbb),
                              width: 0.30000001192092896),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 9,
                      width: 42.311,
                      top: 1,
                      child: Text(
                        'Chores',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 10,
                            color: const Color(0xff14ae5c),
                            fontWeight: FontWeight.normal),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Positioned(
                      left: 54,
                      width: 7,
                      top: 8,
                      height: 7,
                      child: Image.asset(
                        'assets/images/chores_X.png',
                        width: 7,
                        height: 7,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 133,
                width: 131,
                top: 859,
                height: 22,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      width: 131,
                      top: 0,
                      height: 22,
                      child: Container(
                        width: 131,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xffcfe2ff),
                          border: Border.all(
                              color: const Color(0xff9ec5fe),
                              width: 0.30000001192092896),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12.027,
                      top: 1,
                      child: Text(
                        'General Assistance',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 10,
                            color: const Color(0xff2563eb),
                            fontWeight: FontWeight.normal),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Positioned(
                      left: 114,
                      width: 7,
                      top: 8,
                      height: 7,
                      child: Image.asset(
                        'assets/images/gen_X.png',
                        width: 7,
                        height: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
