const otpService = require('../services/otpService');
const jwt = require('jsonwebtoken');

class OTPController {
  // Send OTP (called after signup)
  async sendOTP(req, res) {
    try {
      const { userId, contactNumber } = req.body;

      console.log('📤 Send OTP Request:');
      console.log('   User ID:', userId);
      console.log('   Contact Number:', contactNumber);

      if (!userId || !contactNumber) {
        return res.status(400).json({
          success: false,
          message: 'User ID and contact number are required',
        });
      }

      const result = await otpService.createOTP(userId, contactNumber);

      return res.status(200).json({
        success: true,
        message: 'OTP sent successfully',
        // Include OTP in dev mode for testing
        ...(process.env.NODE_ENV === 'development' && { otp: result.otpCode }),
      });
    } catch (error) {
      console.error('❌ Send OTP Error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to send OTP',
        error: error.message,
      });
    }
  }

  // Verify OTP
  async verifyOTP(req, res) {
    try {
      const { contactNumber, otpCode } = req.body;

      console.log('✅ Verify OTP Request:');
      console.log('   Contact Number:', contactNumber);
      console.log('   OTP Code:', otpCode);

      if (!contactNumber || !otpCode) {
        return res.status(400).json({
          success: false,
          message: 'Contact number and OTP code are required',
        });
      }

      const result = await otpService.verifyOTP(contactNumber, otpCode);

      if (!result.success) {
        return res.status(400).json(result);
      }

      return res.status(200).json(result);
    } catch (error) {
      console.error('❌ Verify OTP Error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to verify OTP',
        error: error.message,
      });
    }
  }

  // Resend OTP
  async resendOTP(req, res) {
    try {
      const { userId, contactNumber } = req.body;

      console.log('🔄 Resend OTP Request:');
      console.log('   User ID:', userId);
      console.log('   Contact Number:', contactNumber);

      if (!userId || !contactNumber) {
        return res.status(400).json({
          success: false,
          message: 'User ID and contact number are required',
        });
      }

      const result = await otpService.resendOTP(userId, contactNumber);

      return res.status(200).json({
        success: true,
        message: 'OTP resent successfully',
        // Include OTP in dev mode for testing
        ...(process.env.NODE_ENV === 'development' && { otp: result.otpCode }),
      });
    } catch (error) {
      console.error('❌ Resend OTP Error:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to resend OTP',
        error: error.message,
      });
    }
  }
}

module.exports = new OTPController();
