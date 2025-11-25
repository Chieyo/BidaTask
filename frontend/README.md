# BidaTask Frontend

Flutter mobile application for the BidaTask crowdsourcing errand service.

## Tech Stack
- **Framework**: Flutter
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)
- **State Management**: TBD
- **API Integration**: REST API

## Folder Structure

### `/lib/core`
Core utilities, constants, themes, and shared resources used across the app.

### `/lib/data`
Data layer containing:
- Repositories (implementation)
- Data sources (remote API, local storage)
- DTOs (Data Transfer Objects)

### `/lib/domain`
Business logic layer containing:
- Entities (business models)
- Use cases (business operations)
- Repository interfaces

### `/lib/presentation`
UI layer containing:
- Screens/Pages
- Widgets (reusable UI components)
- State management (BLoC/Provider/Riverpod)
- View models

### `/lib/services`
External service integrations:
- API client
- Push notifications (AWS SNS)
- Payment gateway (PayMongo)
- Location services

### `/assets`
Static resources:
- Images
- Icons
- Fonts
- Localization files

### `/test`
Unit tests, widget tests, and integration tests.

## Setup Instructions
TBD - Will be added during implementation phase.

## Backend Integration Preparation

Even before wiring the latest Firebase SDKs, the chat data schema has been designed so the new UI and repository code can plug straight into the backend once ready:

- **Tasks collection (acts as chat root)**
  - Fields: `title`, `description`, `participants` (array of user IDs), `requesterId`, `taskerId`, `status`, `createdAt`, `lastMessageAt`, `lastMessage` (embedded snapshot with sender/content/type/status/timestamp), `typing`, `typingUserId`.
- **Messages subcollection** (`tasks/{taskId}/messages`)
  - Fields per message: `senderId`, `senderName`, `senderAvatar`, `content`, `type` (`text`, `image`, `system`), `timestamp`, `status` (`sent`, `delivered`, `read`), `imageUrl` (optional).

That structure matches the `ChatRepositoryImpl` expectations (chat list queries run against `tasks`, message streams watch each `messages` subcollection), so once Firebase dependencies are updated, no additional schema work is needed.
