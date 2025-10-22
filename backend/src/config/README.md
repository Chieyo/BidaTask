# Configuration

Configuration files for the BidaTask backend application.

## Purpose
Centralized configuration management for:
- **Database**: PostgreSQL and/or DynamoDB connection settings
- **AWS Services**: SNS, S3, EC2 configurations
- **Payment Gateway**: PayMongo API credentials and settings
- **Authentication**: JWT secret keys and token settings
- **Environment Variables**: Development, staging, and production configs
- **App Settings**: Port, CORS, rate limiting, etc.

## Contents (To be added)
- `database.js` - Database connection configuration
- `aws.js` - AWS services configuration
- `payment.js` - PayMongo payment gateway configuration
- `auth.js` - JWT and authentication settings
- `app.js` - General app configuration
- `logger.js` - Logging configuration

## Environment Variables
All sensitive information should be stored in `.env` files and never committed to version control.

Example `.env` structure:
```
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://...
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_SNS_TOPIC_ARN=...
PAYMONGO_SECRET_KEY=...
JWT_SECRET=...
```
