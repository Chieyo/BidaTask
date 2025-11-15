const { body } = require('express-validator');

const signUpValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._\-])/)
    .withMessage('Password must contain at least one lowercase, one uppercase, one number, and one special character (@$!%*?&._-)'),
  
  body('fullName')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Full name must be between 2 and 50 characters'),
  
  body('contactNumber')
    .notEmpty()
    .withMessage('Contact number is required')
    .isString()
    .trim()
    .matches(/^(\+63|0)9\d{9}$/)
    .withMessage('Please provide a valid Philippines phone number (e.g., 09171234567 or +639171234567)'),
  
  body('age')
    .notEmpty()
    .withMessage('Age is required')
    .isInt({ min: 13, max: 120 })
    .withMessage('Age must be between 13 and 120')
];

const signInValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required')
    .bail()
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._\-])/)
    .withMessage('Password must contain at least one lowercase, one uppercase, one number, and one special character (@$!%*?&._-)')
];

const updateProfileValidation = [
  body('fullName')
    .optional()
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Full name must be between 2 and 50 characters'),
  
  body('contactNumber')
    .optional()
    .isString()
    .trim()
    .matches(/^(\+63|0)9\d{9}$/)
    .withMessage('Please provide a valid Philippines phone number (e.g., 09171234567 or +639171234567)')
];

module.exports = {
  signUpValidation,
  signInValidation,
  updateProfileValidation
};
