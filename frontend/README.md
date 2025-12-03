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

### Environment Variables

1. Copy `frontend/.env.example` to `frontend/.env` and fill in the Supabase URL/Anon key plus any API endpoints and feature flags.
2. Copy `backend/.env.example` to `backend/.env` with your server, database, Supabase, AWS, PayMongo, and JWT secrets.
3. Never commit the filled `.env` files—keep them local or managed via your secret manager.

## Backend Integration Preparation

The chat data layer now targets Supabase (Postgres + Realtime). Provision these tables/columns to match the current repository expectations:

- **`tasks` table** (acts as chat root)
  - Columns: `id`, `title`, `description`, `participants` (text[] of user IDs), `requester_id`, `tasker_id`, `status`, `created_at`, `last_message_at`, `last_message` (jsonb snapshot with sender/content/type/status/timestamp), `is_typing` (optional flag), `typing_user_id`.
- **`messages` table**
  - Columns: `id` (uuid), `task_id`, `sender_id`, `sender_name`, `sender_avatar`, `content`, `type` (`text`, `image`, `system`), `status` (`sent`, `delivered`, `read`), `image_url`, `created_at` (timestamptz).
- **`task_typing_status` table**
  - Columns: `task_id`, `user_id`, `is_typing`, `updated_at` (used for typing indicators via Supabase Realtime streams).

Additionally, create a Supabase Storage bucket (default `chat-images`) for chat image uploads. Update the bucket name via `ChatRepositoryImpl(storageBucket: 'your-bucket')` if needed.
