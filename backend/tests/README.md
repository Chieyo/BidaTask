# Tests

Test files for the BidaTask backend application.

## Purpose
Ensure code quality, reliability, and correctness through automated testing.

## Testing Framework
- **Jest**: Testing framework
- **Supertest**: HTTP assertion library
- **Sinon**: Mocking and stubbing

## Test Types
- **Unit Tests**: Test individual functions and modules
- **Integration Tests**: Test interactions between components
- **API Tests**: Test API endpoints end-to-end

## Contents (To be added)
- `unit/` - Unit tests
  - `services/` - Service layer tests
  - `utils/` - Utility function tests
  - `models/` - Model tests
- `integration/` - Integration tests
  - `api/` - API endpoint tests
  - `database/` - Database integration tests
- `fixtures/` - Test data and fixtures
- `helpers/` - Test helper functions

## Running Tests
```bash
# Run all tests
npm test

# Run specific test file
npm test -- tests/unit/services/authService.test.js

# Run with coverage
npm run test:coverage

# Run in watch mode
npm run test:watch
```
