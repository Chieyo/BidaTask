const supabase = require('../config/supabase');
const jwt = require('jsonwebtoken');
const otpService = require('./otpService');

class AuthService {
  /**
   * Sign up a new user
   * @param {string} email - User's email
   * @param {string} password - User's password
   * @param {object} userData - Additional user data
   * @returns {object} User data and session
   */
  async signUp(email, password, userData = {}) {
    try {
      console.log('🔐 Creating auth user via admin API...');
      console.log('   Email:', email);
      console.log('   Password length:', password.length);
      console.log('   User data:', JSON.stringify(userData, null, 2));

      const { data: createdUser, error: createError } = await supabase.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: {
          full_name: userData.fullName || '',
          contact_number: userData.contactNumber || '',
          age: userData.age || ''
        }
      });

      if (createError) {
        console.error('❌ Supabase Admin Create User Error:');
        console.error('   Message:', createError.message);
        console.error('   Hint:', createError.hint);
        throw new Error(createError.message);
      }

      if (!createdUser?.user) {
        throw new Error('User creation failed - no user data returned');
      }

      console.log('✅ Auth user created successfully');
      console.log('   User ID:', createdUser.user.id);

      console.log('🔑 Generating session for new user...');
      const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (signInError) {
        console.error('❌ Supabase Sign-in Error:');
        console.error('   Message:', signInError.message);
        console.error('   Hint:', signInError.hint);
        throw new Error(`Sign in after sign up failed: ${signInError.message}`);
      }

      if (!signInData?.user || !signInData.session) {
        throw new Error('Sign in after sign up failed - missing session data');
      }

      // User profile is automatically created by Supabase trigger (handle_new_user)
      console.log('✅ User profile will be created automatically by database trigger');

      // Send OTP for phone verification
      if (userData.contactNumber) {
        try {
          await otpService.createOTP(signInData.user.id, userData.contactNumber);
          console.log('✅ OTP sent to user');
        } catch (otpError) {
          console.error('⚠️ Warning: Failed to send OTP, but signup succeeded');
          console.error('   Error:', otpError.message);
        }
      }

      // Generate JWT token
      const token = this.generateToken(signInData.user);

      return {
        user: {
          id: signInData.user.id,
          email: signInData.user.email,
          fullName: signInData.user.user_metadata?.full_name || '',
          contactNumber: signInData.user.user_metadata?.contact_number || '',
          age: signInData.user.user_metadata?.age || '',
          createdAt: signInData.user.created_at
        },
        token,
        session: signInData.session
      };
    } catch (error) {
      throw new Error(`Sign up failed: ${error.message}`);
    }
  }

  /**
   * Sign in an existing user
   * @param {string} email - User's email
   * @param {string} password - User's password
   * @returns {object} User data and session
   */
  async signIn(email, password) {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) {
        throw new Error(error.message);
      }

      // Ensure user exists in our profiles table
      const { data: profile, error: profileError } = await supabase
        .from('users')
        .select('id, email, full_name, contact_number, avatar_url, age, created_at, updated_at')
        .eq('id', data.user.id)
        .single();

      if (profileError) {
        console.error('❌ Login profile lookup error:', profileError.message);
        throw new Error('Unable to verify user profile. Please try again.');
      }

      if (!profile) {
        throw new Error('Account profile not found. Please complete sign up.');
      }

      // Generate JWT token
      const token = this.generateToken(data.user);

      return {
        user: {
          id: profile.id,
          email: profile.email,
          fullName: profile.full_name,
          contactNumber: profile.contact_number,
          avatarUrl: profile.avatar_url,
          age: profile.age,
          createdAt: profile.created_at,
          updatedAt: profile.updated_at
        },
        token
      };
    } catch (error) {
      throw new Error(`Sign in failed: ${error.message}`);
    }
  }

  /**
   * Sign out a user
   * @param {string} accessToken - User's access token
   * @returns {boolean} Success status
   */
  async signOut(accessToken) {
    try {
      const { error } = await supabase.auth.admin.signOut(accessToken);
      
      if (error) {
        throw new Error(error.message);
      }

      return true;
    } catch (error) {
      throw new Error(`Sign out failed: ${error.message}`);
    }
  }

  /**
   * Get user by ID
   * @param {string} userId - User's ID
   * @returns {object} User data
   */
  async getUserById(userId) {
    try {
      const { data, error } = await supabase.auth.admin.getUserById(userId);

      if (error) {
        throw new Error(error.message);
      }

      return {
        id: data.user.id,
        email: data.user.email,
        fullName: data.user.user_metadata.full_name,
        phone: data.user.user_metadata.phone,
        contactNumber: data.user.user_metadata.contact_number,
        age: data.user.user_metadata.age,
        createdAt: data.user.created_at
      };
    } catch (error) {
      throw new Error(`Get user failed: ${error.message}`);
    }
  }

  /**
   * Update user profile
   * @param {string} userId - User's ID
   * @param {object} updateData - Data to update
   * @returns {object} Updated user data
   */
  async updateUser(userId, updateData) {
    try {
      const { data, error } = await supabase.auth.admin.updateUserById(userId, {
        user_metadata: updateData
      });

      if (error) {
        throw new Error(error.message);
      }

      return {
        id: data.user.id,
        email: data.user.email,
        fullName: data.user.user_metadata.full_name,
        phone: data.user.user_metadata.phone,
        contactNumber: data.user.user_metadata.contact_number,
        age: data.user.user_metadata.age,
        createdAt: data.user.created_at
      };
    } catch (error) {
      throw new Error(`Update user failed: ${error.message}`);
    }
  }

  /**
   * Generate JWT token
   * @param {object} user - User object
   * @returns {string} JWT token
   */
  generateToken(user) {
    return jwt.sign(
      {
        userId: user.id,
        email: user.email
      },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_EXPIRES_IN || '7d'
      }
    );
  }

  /**
   * Verify JWT token
   * @param {string} token - JWT token
   * @returns {object} Decoded token
   */
  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      throw new Error('Invalid token');
    }
  }
}

module.exports = new AuthService();
