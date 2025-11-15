const supabase = require('../config/supabase');

class OTPService {
  // Generate 6-digit OTP
  generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Convert Philippine phone number to E.164 format
  formatPhoneNumberE164(phoneNumber) {
    // Remove all non-numeric characters
    let cleaned = phoneNumber.replace(/\D/g, '');
    
    // If starts with 0, replace with +63
    if (cleaned.startsWith('0')) {
      cleaned = '+63' + cleaned.substring(1);
    }
    // If starts with 63, add +
    else if (cleaned.startsWith('63')) {
      cleaned = '+' + cleaned;
    }
    // If doesn't start with + or 63, assume it needs +63
    else if (!cleaned.startsWith('+')) {
      cleaned = '+63' + cleaned;
    }
    
    console.log('📞 Phone number converted:', phoneNumber, '→', cleaned);
    return cleaned;
  }

  // Send OTP via Supabase (uses Twilio configured in Supabase)
  async createOTP(userId, contactNumber) {
    try {
      console.log('📝 Sending OTP via Supabase/Twilio for user:', userId);
      console.log('   Contact Number:', contactNumber);

      // Convert to E.164 format
      const e164Phone = this.formatPhoneNumberE164(contactNumber);

      // Use Supabase's built-in phone OTP
      const { data, error } = await supabase.auth.signInWithOtp({
        phone: e164Phone,
      });

      if (error) {
        console.error('❌ Error sending OTP via Supabase:', error);
        throw new Error(`Failed to send OTP: ${error.message}`);
      }

      console.log('✅ OTP sent successfully via Twilio');
      console.log('📱 SMS sent to:', contactNumber);

      return {
        success: true,
        message: 'OTP sent via SMS',
      };
    } catch (error) {
      console.error('❌ OTP Service Error:', error);
      throw error;
    }
  }

  // Verify OTP via Supabase
  async verifyOTP(contactNumber, otpCode) {
    try {
      console.log('🔍 Verifying OTP via Supabase');
      console.log('   Contact Number:', contactNumber);
      console.log('   Provided OTP:', otpCode);

      // Convert to E.164 format
      const e164Phone = this.formatPhoneNumberE164(contactNumber);

      // Use Supabase's built-in phone OTP verification
      const { data, error } = await supabase.auth.verifyOtp({
        phone: e164Phone,
        token: otpCode,
        type: 'sms',
      });

      if (error) {
        console.log('❌ OTP verification failed:', error.message);
        return {
          success: false,
          message: error.message || 'Invalid OTP code. Please try again.',
        };
      }

      console.log('✅ OTP verified successfully via Supabase');

      return {
        success: true,
        message: 'Phone number verified successfully!',
        user: data.user,
      };
    } catch (error) {
      console.error('❌ OTP Verification Error:', error);
      throw error;
    }
  }

  // Resend OTP (creates a new one)
  async resendOTP(userId, contactNumber) {
    console.log('🔄 Resending OTP for user:', userId);
    return await this.createOTP(userId, contactNumber);
  }
}

module.exports = new OTPService();
