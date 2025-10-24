# BidaTask Backend

Node.js Express API server for the BidaTask crowdsourcing errand service.

## Tech Stack
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL / DynamoDB
- **Notifications**: AWS SNS
- **Payments**: PayMongo API
- **Hosting**: AWS EC2
- **Authentication**: JWT

## Folder Structure

### `/src/config`
Configuration files for:
- Database connections (PostgreSQL/DynamoDB)
- AWS services (SNS, S3, etc.)
- Payment gateway (PayMongo)
- Environment variables
- App settings

### `/src/controllers`
Request handlers that:
- Receive HTTP requests
- Validate input
- Call appropriate services
- Return HTTP responses

### `/src/models`
Database models and schemas:
- User model
- Task model
- Bid model
- Payment model
- Notification model

### `/src/routes`
API route definitions:
- Auth routes (`/api/auth`)
- User routes (`/api/users`)
- Task routes (`/api/tasks`)
- Bid routes (`/api/bids`)
- Payment routes (`/api/payments`)
- Notification routes (`/api/notifications`)

### `/src/services`
Business logic services:
- Authentication service
- Task management service
- Bidding service
- Payment processing service
- Notification service
- Email service

### `/src/middleware`
Custom middleware:
- Authentication middleware (JWT verification)
- Authorization middleware (role-based access)
- Validation middleware
- Error handling middleware
- Rate limiting
- Request logging

### `/src/utils`
Helper functions and utilities:
- Response formatters
- Date/time utilities
- String utilities
- File upload utilities
- Encryption/hashing utilities

### `/src/validators`
Request validation schemas:
- Input validation (using Joi, express-validator, etc.)
- Schema definitions for each endpoint

### `/tests`
Backend tests:
- Unit tests
- Integration tests
- API endpoint tests

## API Documentation
TBD - Will be added during implementation phase (consider using Swagger/OpenAPI).

## Setup Instructions
TBD - Will be added during implementation phase.
