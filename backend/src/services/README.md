# Services

Business logic services for the BidaTask backend.

## Purpose
Contains the core business logic of the application:
- **Business Rules**: Implement business logic and rules
- **Data Processing**: Process and transform data
- **External Integrations**: Interact with external APIs and services
- **Reusability**: Provide reusable functions for controllers

## Responsibilities
- **Complex Operations**: Handle complex business operations
- **Transaction Management**: Manage database transactions
- **Service Orchestration**: Coordinate multiple operations
- **Error Handling**: Handle business-level errors

## Contents (To be added)
- `authService.js` - Authentication and authorization logic
  - User registration
  - Login/logout
  - Token generation and validation
  - Password reset
- `userService.js` - User management logic
  - User CRUD operations
  - Profile updates
  - User search and filtering
- `taskService.js` - Task management logic
  - Task creation and validation
  - Task search and filtering
  - Task status management
  - Task assignment
- `bidService.js` - Bidding logic
  - Bid creation and validation
  - Bid acceptance/rejection
  - Bid notifications
- `paymentService.js` - Payment processing logic
  - PayMongo integration
  - Payment creation
  - Payment verification
  - Refund processing
- `notificationService.js` - Notification logic
  - AWS SNS integration
  - Push notification sending
  - In-app notification management
  - Email notifications
- `emailService.js` - Email sending logic
  - Email templates
  - Transactional emails
  - Email queue management

## Service Layer Benefits
- Separation of concerns
- Testability
- Reusability across controllers
- Easier maintenance
