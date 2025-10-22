# Utils

Helper functions and utilities for the BidaTask backend.

## Purpose
Reusable utility functions used across the application:
- **Response Formatting**: Standardize API responses
- **Date/Time**: Date manipulation and formatting
- **String Operations**: String utilities
- **Encryption**: Hashing and encryption
- **File Operations**: File handling utilities
- **Validation**: Common validation functions

## Contents (To be added)
- `responseFormatter.js` - API response formatting
  - `successResponse()` - Format success responses
  - `errorResponse()` - Format error responses
  - `paginationResponse()` - Format paginated responses
- `dateUtils.js` - Date and time utilities
  - `formatDate()` - Format dates
  - `calculateDuration()` - Calculate time differences
  - `isExpired()` - Check if date is expired
- `stringUtils.js` - String manipulation
  - `slugify()` - Create URL-friendly slugs
  - `truncate()` - Truncate strings
  - `capitalize()` - Capitalize strings
- `cryptoUtils.js` - Encryption and hashing
  - `hashPassword()` - Hash passwords (bcrypt)
  - `comparePassword()` - Compare hashed passwords
  - `generateToken()` - Generate random tokens
  - `encrypt()` - Encrypt sensitive data
  - `decrypt()` - Decrypt data
- `fileUtils.js` - File operations
  - `uploadToS3()` - Upload files to AWS S3
  - `deleteFromS3()` - Delete files from S3
  - `validateFileType()` - Validate file types
  - `compressImage()` - Compress images
- `validationUtils.js` - Common validations
  - `isValidEmail()` - Validate email format
  - `isValidPhone()` - Validate phone numbers
  - `isValidURL()` - Validate URLs
- `errorUtils.js` - Error utilities
  - `AppError` - Custom error class
  - `catchAsync()` - Async error wrapper
- `paginationUtils.js` - Pagination helpers
  - `paginate()` - Calculate pagination
  - `buildPaginationMeta()` - Build pagination metadata

## Best Practices
- Keep functions pure when possible
- Write unit tests for utilities
- Document function parameters and return values
- Use TypeScript/JSDoc for type safety
