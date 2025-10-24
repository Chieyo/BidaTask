# Validators

Request validation schemas for the BidaTask backend.

## Purpose
Define validation rules for API requests:
- **Input Validation**: Validate request body, params, and query
- **Schema Definitions**: Define validation schemas
- **Error Messages**: Provide clear validation error messages
- **Data Sanitization**: Clean and normalize input data

## Validation Library
Consider using:
- Joi
- express-validator
- Yup
- Zod

## Contents (To be added)
- `authValidator.js` - Authentication validation schemas
- `userValidator.js` - User data validation schemas
- `taskValidator.js` - Task data validation schemas
- `bidValidator.js` - Bid data validation schemas
- `paymentValidator.js` - Payment data validation schemas

## Example Validations
- Email format
- Password strength
- Required fields
- String length limits
- Number ranges
- Date formats
- Enum values
