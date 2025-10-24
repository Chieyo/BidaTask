# Models

Database models and schemas for the BidaTask backend.

## Purpose
Define the structure of data stored in the database:
- **Schema Definitions**: Define table/collection structures
- **Relationships**: Define associations between models
- **Validations**: Database-level validations
- **Methods**: Model-specific helper methods

## Database Options
- **PostgreSQL**: Using Sequelize or TypeORM
- **DynamoDB**: Using AWS SDK or Dynamoose

## Contents (To be added)
- `User.js` - User model (id, name, email, password, role, etc.)
- `Task.js` - Task model (id, title, description, location, budget, status, etc.)
- `Bid.js` - Bid model (id, taskId, userId, amount, message, status, etc.)
- `Payment.js` - Payment model (id, taskId, amount, status, paymentMethod, etc.)
- `Notification.js` - Notification model (id, userId, message, type, read, etc.)
- `Review.js` - Review/Rating model (id, taskId, userId, rating, comment, etc.)

## Key Relationships
- User has many Tasks (as creator)
- User has many Bids (as bidder)
- Task has many Bids
- Task has one Payment
- User has many Notifications
- Task has many Reviews
