const authService = require('../services/authService');
const { validationResult } = require('express-validator');

class AuthController {
  /**
   * Sign up a new user
   */
  async signUp(req, res) {
    try {
      console.log('\n📥 SIGNUP REQUEST RECEIVED');
      console.log('====================================');
      console.log('Request Body:', JSON.stringify(req.body, null, 2));
      console.log('====================================\n');

      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('❌ Validation Failed:');
        errors.array().forEach(err => {
          console.log(`   - ${err.path}: ${err.msg}`);
        });
        console.log('\n');
        return res.status(400).json({
          status: 'error',
          message: 'Validation failed',
          errors: errors.array()
        });
      }

      const { email, password, fullName, contactNumber, age } = req.body;

      console.log('✅ Validation Passed - Processing signup...');
      console.log(`   Email: ${email}`);
      console.log(`   Full Name: ${fullName}`);
      console.log(`   Contact: ${contactNumber}`);
      console.log(`   Age: ${age}\n`);

      const result = await authService.signUp(email, password, {
        fullName,
        contactNumber,
        age
      });

      console.log('✅ USER CREATED SUCCESSFULLY');
      console.log(`   User ID: ${result.user.id}`);
      console.log(`   Email: ${result.user.email}\n`);

      res.status(201).json({
        status: 'success',
        message: 'User created successfully',
        data: result
      });
    } catch (error) {
      console.log('❌ SIGNUP ERROR:', error.message);
      console.log('\n');
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }

  /**
   * Sign in an existing user
   */
  async signIn(req, res) {
    try {
      console.log('\n🔑 SIGNIN REQUEST RECEIVED');
      console.log('====================================');
      console.log(`Email: ${req.body.email}`);
      console.log('====================================\n');

      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        console.log('❌ Validation Failed\n');
        return res.status(400).json({
          status: 'error',
          message: 'Validation failed',
          errors: errors.array()
        });
      }

      const { email, password } = req.body;

      const result = await authService.signIn(email, password);

      console.log('✅ SIGNIN SUCCESSFUL');
      console.log(`   User: ${result.user.email}\n`);

      res.status(200).json({
        status: 'success',
        message: 'Sign in successful',
        data: result
      });
    } catch (error) {
      console.log('❌ SIGNIN ERROR:', error.message);
      console.log('\n');
      res.status(401).json({
        status: 'error',
        message: error.message
      });
    }
  }

  /**
   * Sign out a user
   */
  async signOut(req, res) {
    try {
      const token = req.headers.authorization?.replace('Bearer ', '');
      
      if (!token) {
        return res.status(401).json({
          status: 'error',
          message: 'No token provided'
        });
      }

      await authService.signOut(token);

      res.status(200).json({
        status: 'success',
        message: 'Sign out successful'
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }

  /**
   * Get current user profile
   */
  async getProfile(req, res) {
    try {
      const userId = req.user.userId;
      const user = await authService.getUserById(userId);

      res.status(200).json({
        status: 'success',
        data: { user }
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }

  /**
   * Update user profile
   */
  async updateProfile(req, res) {
    try {
      // Check for validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          status: 'error',
          message: 'Validation failed',
          errors: errors.array()
        });
      }

      const userId = req.user.userId;
      const updateData = req.body;

      const user = await authService.updateUser(userId, updateData);

      res.status(200).json({
        status: 'success',
        message: 'Profile updated successfully',
        data: { user }
      });
    } catch (error) {
      res.status(400).json({
        status: 'error',
        message: error.message
      });
    }
  }
}

module.exports = new AuthController();
