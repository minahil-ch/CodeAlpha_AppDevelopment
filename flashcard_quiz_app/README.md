# Flashcard Quiz App

A simple flashcard-based quiz application for studying purposes built with Flutter.

## Features

- **Flashcard Structure**: Each flashcard displays a question on the front and answer on the back
- **Navigation**: Users can navigate between flashcards using "Next" and "Previous" buttons
- **Flashcard Management**: Add, edit, and delete flashcards with immediate updates
- **Simple UI**: Clean and intuitive user interface designed for study purposes

## Requirements

- Flutter SDK (3.0 or higher)
- Dart (2.19 or higher)

## How to Run

1. Clone or download this repository
2. Navigate to the project directory:
   ```bash
   cd flashcard_quiz_app
   ```
3. Get the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
   
   Or run for a specific platform:
   - For mobile: `flutter run`
   - For web: `flutter run -d chrome`
   - For desktop: `flutter run -d windows` (or `macos`/`linux`)

## Functionality

- **Show Answer**: Click the "Show Answer" button to flip the card and reveal the answer
- **Navigation**: Use Previous/Next buttons to move between flashcards
- **Add Cards**: Click "Add" to create new flashcards
- **Edit Cards**: Click "Edit" to modify the current flashcard
- **Delete Cards**: Click "Delete" to remove the current flashcard

## Project Structure

- `lib/main.dart`: Main application file containing all functionality

## Technologies Used

- Flutter SDK
- Dart Programming Language
- Material Design Components