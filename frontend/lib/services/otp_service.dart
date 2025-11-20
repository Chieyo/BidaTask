import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  static const String baseUrl = 'http://192.168.1.46:3000/api/otp'; //jm - change this to your computer's IP address, akin kasi to lol

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String contactNumber,
    required String otpCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contactNumber': contactNumber,
          'otpCode': otpCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String userId,
    required String contactNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'contactNumber': contactNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP resent successfully',
          // Include OTP in dev mode for testing
          if (data['otp'] != null) 'otp': data['otp'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
