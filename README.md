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

## Database Structure

The Supabase database has the following structure:

### Words Table
| Column | Type | Description |
|--------|------|-------------|
| id | integer | Primary key, auto-incrementing |
| user_id | UUID | Foreign key to auth.users table |
| word | text | The favorite word text |
| created_at | timestamptz | When the record was created |
| updated_at | timestamptz | When the record was last updated |
| is_active | boolean | When false, the record is considered deleted |
| deleted_at | timestamptz | When the record was soft-deleted (nullable) |

## Row Level Security

The Supabase database implements Row Level Security (RLS) to ensure data privacy and security:

### Words Table Policies

1. **View Own Data Only**: Users can only fetch their own words and only those that are active
   ```sql
   alter policy "Enable users to view their own data only"
   on "public"."words"
   to authenticated
   using (
     ((( SELECT auth.uid() AS uid) = user_id) AND (is_active = true))
   );
   ```
   This policy ensures that:
   - Users can only access words they created (where user_id matches their auth.uid)
   - Only words with is_active=true are visible (supporting soft deletion)

2. **Insert Own Data Only**: Only authenticated users can insert data, and the user_id must match their auth ID
   ```sql
   create policy "Enable users to insert their own data only"
   on "public"."words"
   for insert
   to authenticated
   with check (
     (auth.uid() = user_id)
   );
   ```
   This policy ensures that:
   - Only authenticated users can add new words
   - Users can only insert records with their own user_id

3. **Update Own Data Only**: Only authenticated users can update their own data
   ```sql
   create policy "Enable users to update their own data only"
   on "public"."words"
   for update
   to authenticated
   using (
     (auth.uid() = user_id)
   )
   with check (
     (auth.uid() = user_id)
   );
   ```
   This policy ensures that:
   - Only authenticated users can update words
   - Users can only update records they own (where user_id matches their auth.uid)

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
