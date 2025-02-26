# Supabase Login Example

A flutter application demonstrating authentication with supabase.

One can log in/sign up, add favorite words and have them saved to supabase

## Features
- User authentication with Supabase
- Email/password login and registration
- Error handling with Sentry integration
- Use of Supabase's database

## Tech Stack

- **Flutter 3.24.5+** - UI framework
- **Supabase** - Backend as a Service for authentication and database
- **Riverpod** - State management
- **Auto Route** - Navigation
- **Freezed** - Code generation for immutable classes
- **Sentry** - Error tracking and performance monitoring
- **Flutter Dotenv** - Environment variable management

## Getting Started

### Prerequisites

- Flutter SDK 3.24.5 or higher
- Dart SDK 3.5.4 or higher
- A Supabase account and project

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/supabase_login_example.git
   cd supabase_login_example
   ```

2. Create a `.env` file in the root directory with your Supabase credentials:
   ```
   PROJECT_URL=your_supabase_project_url
   API_KEY=your_supabase_api_key
   SENTRY_DSN=your_sentry_dsn
   ```

3. Install flutter_gen
    ```
    dart pub global activate flutter_gen
    ```

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Run the code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

The project follows a feature-based architecture:

- `lib/`
  - `helpers/` - Utility functions and helper classes
  - `models/` - Data models and DTOs
  - `providers/` - Riverpod providers and state management
  - `repositories/` - Data access layer
  - `ui/` - UI components and screens
  - `gen/` - Generated code (assets, routes)

## CI/CD

The project includes GitHub Actions workflows for:
- Building Android App Bundle
- Running static analysis
