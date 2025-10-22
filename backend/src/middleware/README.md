# Middleware

Custom middleware functions for the BidaTask backend.

## Purpose
Middleware functions that process requests before they reach controllers:
- **Authentication**: Verify user identity
- **Authorization**: Check user permissions
- **Validation**: Validate request data
- **Error Handling**: Catch and format errors
- **Logging**: Log requests and responses
- **Rate Limiting**: Prevent abuse

## Contents (To be added)
- `authMiddleware.js` - Authentication middleware
  - `verifyToken()` - Verify JWT token
  - `requireAuth()` - Require authentication
  - `optionalAuth()` - Optional authentication
- `authorizationMiddleware.js` - Authorization middleware
  - `requireRole()` - Check user role
  - `requireOwnership()` - Check resource ownership
- `validationMiddleware.js` - Request validation
  - `validateRequest()` - Validate request body/params/query
  - `sanitizeInput()` - Sanitize user input
- `errorMiddleware.js` - Error handling
  - `errorHandler()` - Global error handler
  - `notFoundHandler()` - 404 handler
  - `asyncHandler()` - Async error wrapper
- `rateLimitMiddleware.js` - Rate limiting
  - `apiLimiter()` - General API rate limiter
  - `authLimiter()` - Auth endpoint rate limiter
- `loggingMiddleware.js` - Request logging
  - `requestLogger()` - Log incoming requests
  - `responseLogger()` - Log outgoing responses
- `corsMiddleware.js` - CORS configuration
  - `corsOptions()` - CORS settings
- `uploadMiddleware.js` - File upload handling
  - `uploadImage()` - Handle image uploads
  - `uploadDocument()` - Handle document uploads

## Middleware Order
Middleware execution order is important:
1. CORS
2. Body parsing
3. Logging
4. Rate limiting
5. Authentication
6. Authorization
7. Validation
8. Route handlers
9. Error handling
