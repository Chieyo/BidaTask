# Tests

Test files for the BidaTask frontend application.

## Purpose
Contains all test files to ensure code quality and reliability:
- **Unit Tests**: Test individual functions and classes
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test complete user flows

## Structure (To be added)
- `unit/` - Unit tests
  - `domain/` - Domain layer tests
  - `data/` - Data layer tests
  - `services/` - Service tests
- `widget/` - Widget tests
  - `screens/` - Screen widget tests
  - `widgets/` - Component widget tests
- `integration/` - Integration tests
  - `flows/` - End-to-end user flow tests

## Testing Framework
- Flutter Test (built-in)
- Mockito for mocking
- Integration test package for E2E tests

## Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/domain/entities/user_test.dart

# Run with coverage
flutter test --coverage
```
