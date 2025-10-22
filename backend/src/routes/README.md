# Routes

API route definitions for the BidaTask backend.

## Purpose
Define all API endpoints and map them to controllers:
- **Route Definitions**: Map HTTP methods and paths to controller functions
- **Middleware Application**: Apply authentication, validation, etc.
- **Route Organization**: Group related endpoints together
- **API Versioning**: Support multiple API versions if needed

## Contents (To be added)
- `index.js` - Main router that combines all route modules
- `authRoutes.js` - Authentication routes
  - `POST /api/auth/register`
  - `POST /api/auth/login`
  - `POST /api/auth/logout`
  - `POST /api/auth/refresh-token`
  - `POST /api/auth/forgot-password`
  - `POST /api/auth/reset-password`
- `userRoutes.js` - User management routes
  - `GET /api/users/:id`
  - `PUT /api/users/:id`
  - `DELETE /api/users/:id`
  - `GET /api/users/:id/tasks`
  - `GET /api/users/:id/bids`
- `taskRoutes.js` - Task management routes
  - `POST /api/tasks`
  - `GET /api/tasks`
  - `GET /api/tasks/:id`
  - `PUT /api/tasks/:id`
  - `DELETE /api/tasks/:id`
  - `GET /api/tasks/:id/bids`
- `bidRoutes.js` - Bid management routes
  - `POST /api/bids`
  - `GET /api/bids/:id`
  - `PUT /api/bids/:id`
  - `DELETE /api/bids/:id`
  - `POST /api/bids/:id/accept`
  - `POST /api/bids/:id/reject`
- `paymentRoutes.js` - Payment routes
  - `POST /api/payments`
  - `GET /api/payments/:id`
  - `POST /api/payments/:id/confirm`
  - `POST /api/payments/webhook` (PayMongo webhook)
- `notificationRoutes.js` - Notification routes
  - `GET /api/notifications`
  - `GET /api/notifications/:id`
  - `PUT /api/notifications/:id/read`
  - `DELETE /api/notifications/:id`

## Route Protection
- Public routes: login, register
- Protected routes: require JWT authentication
- Role-based routes: require specific user roles
