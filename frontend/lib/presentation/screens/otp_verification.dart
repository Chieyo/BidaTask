import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/otp_service.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({super.key});

  @override
  State<OtpVerification> createState() => _OtpVerification();
}

class _OtpVerification extends State<OtpVerification> {
  String? contactNumber;
  String? userId;
  bool _isLoading = false;
  final OtpService _otpService = OtpService();

  // Controllers for each OTP digit
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Focus nodes for each field
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get contact number and userId from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      contactNumber = args['contactNumber'] as String?;
      userId = args['userId'] as String?;
    }
  }

  String _maskContactNumber(String? number) {
    if (number == null || number.isEmpty) return '09*********';
    if (number.length <= 4) return number;
    return '${number.substring(0, 2)}${'*' * (number.length - 4)}${number.substring(number.length - 2)}';
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    // Trigger rebuild to update border colors
    setState(() {});

    if (value.length == 1 && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((controller) => controller.text).join();

    // Validate OTP length
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if contactNumber is available
    if (contactNumber == null || contactNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact number not found. Please sign up again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _otpService.verifyOtp(
        contactNumber: contactNumber!,
        otpCode: otp,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'OTP verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to onboarding after successful verification
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/onboarding1');
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'OTP verification failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    if (userId == null || contactNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing user information. Please sign up again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _otpService.resendOtp(
        userId: userId!,
        contactNumber: contactNumber!,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'OTP resent'),
            backgroundColor: result['success'] ? Colors.blue : Colors.red,
          ),
        );
        // Show OTP in dev mode for testing
        if (result['otp'] != null) {
          print('🔑 DEV MODE - OTP Code: ${result['otp']}');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOtpField(int index) {
    return AnimatedBuilder(
      animation: _focusNodes[index],
      builder: (context, child) {
        final isFocused = _focusNodes[index].hasFocus;
        final hasValue = _controllers[index].text.isNotEmpty;

        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: isFocused
                  ? const Color(0xff2563eb) // Active - blue
                  : hasValue
                  ? const Color(0xff10b981) // Filled - green
                  : const Color(0xffc5c6cc), // Inactive - gray
              width: isFocused ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isFocused
                ? const Color(0xfff0f7ff) // Light blue background when focused
                : Colors.white,
          ),
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24,
              color: hasValue
                  ? const Color(0xff1f2024)
                  : const Color(0xff9ca3af),
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const Text(
                  'Enter verification code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xff1f2024),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A 6-digit code was sent to\n${_maskContactNumber(contactNumber)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff71727a),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildOtpField(index),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  child: Text(
                    'Resend code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isLoading ? Colors.grey : const Color(0xff2563eb),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2563eb),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xfffefefe),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
