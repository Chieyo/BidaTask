# Controllers

Request handlers for the BidaTask backend API.

## Purpose
Controllers handle HTTP requests and responses:
- Receive and parse incoming requests
- Validate request data (basic validation)
- Call appropriate service layer functions
- Format and return HTTP responses
- Handle errors and edge cases

## Responsibilities
- **Thin layer**: Controllers should be thin and delegate business logic to services
- **HTTP concerns**: Focus on HTTP-specific logic (status codes, headers, etc.)
- **Request/Response**: Transform data between HTTP and service layer formats

## Contents (To be added)
- `authController.js` - Authentication endpoints (login, register, logout)
- `userController.js` - User management endpoints
- `taskController.js` - Task CRUD operations
- `bidController.js` - Bid management operations
- `paymentController.js` - Payment processing endpoints
- `notificationController.js` - Notification management

## Example Structure
Each controller typically contains:
- `create()` - POST endpoint handler
- `getAll()` - GET list endpoint handler
- `getById()` - GET single item endpoint handler
- `update()` - PUT/PATCH endpoint handler
- `delete()` - DELETE endpoint handler
