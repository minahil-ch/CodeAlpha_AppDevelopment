# Fitness Tracker App

A comprehensive cross-platform fitness tracking application built with Flutter that helps users monitor their daily activities, set goals, and visualize their progress.

## Features

### 🏃‍♂️ Core Functionality
- **Activity Tracking**: Log various exercises like running, cycling, walking, swimming, yoga, and more
- **Goal Setting**: Set daily targets for steps, calories burned, and active minutes
- **Progress Visualization**: View charts and statistics showing your fitness journey
- **History Management**: Browse past activities with filtering options
- **Smart Calculations**: Automatic calorie estimation based on exercise type and duration

### 📱 Screens Included

1. **Dashboard Screen** (`dashboard_screen.dart`)
   - Today's summary statistics (steps, calories, minutes, workouts)
   - Progress indicators for daily goals
   - Weekly steps chart visualization
   - Quick action buttons

2. **Add Activity Screen** (`add_activity_screen.dart`)
   - Form to log new activities
   - Exercise type selection with icons
   - Duration and calorie input with automatic calculation
   - Date/time pickers
   - Notes field for additional information

3. **History Screen** (`history_screen.dart`)
   - List view of all logged activities
   - Filtering by date ranges (Today, This Week, This Month, Custom)
   - Swipe to delete functionality
   - Edit existing activities

4. **Profile Screen** (`profile_screen.dart`)
   - User profile display
   - Current goal visualization with progress bars
   - Goal editing capabilities
   - Default goal reset option

### 🛠️ Technical Architecture

#### Data Models
- **Activity Model**: Stores exercise data (type, duration, calories, date, distance, notes)
- **Goal Model**: Manages daily targets (steps, calories, active minutes)

#### Database Layer
- **SQLite Integration**: Uses `sqflite` for local data persistence
- **Database Helper**: Comprehensive CRUD operations for activities and goals
- **Statistics Methods**: Built-in calculations for daily/weekly summaries

#### State Management
- **Provider Pattern**: Clean separation of business logic and UI
- **Activity Provider**: Manages activity data and operations
- **Goal Provider**: Handles goal setting and progress tracking

#### UI Components
- **Modern Design**: Clean, health-focused interface with green/blue color scheme
- **Responsive Layout**: Works on both phones and tablets
- **Interactive Charts**: Uses `fl_chart` for data visualization
- **Form Validation**: Robust input validation and error handling

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Android Studio or VS Code with Flutter extensions
- For mobile testing: Android emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fitness_tracker_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android/iOS
   flutter run
   
   # For web (limited functionality due to sqflite limitations)
   flutter run -d chrome
   
   # For desktop
   flutter run -d windows  # Requires Visual Studio tools
   ```

### Platform Notes

⚠️ **Important**: Due to SQLite limitations, this app works best on mobile platforms:
- ✅ **Android**: Full functionality with SQLite database
- ✅ **iOS**: Full functionality with SQLite database  
- ⚠️ **Web**: Limited functionality (requires sqflite_common_ffi setup)
- ⚠️ **Desktop**: Requires additional Visual Studio tools on Windows

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── activity.dart        # Activity data model
│   ├── goal.dart           # Goal data model
│   └── exercise_types.dart # Exercise type definitions and utilities
├── helpers/
│   └── database_helper.dart # SQLite database operations
├── providers/
│   ├── activity_provider.dart # Activity state management
│   └── goal_provider.dart    # Goal state management
├── screens/
│   ├── dashboard_screen.dart # Main dashboard
│   ├── add_activity_screen.dart # Add/edit activities
│   ├── history_screen.dart   # Activity history
│   └── profile_screen.dart   # User profile and goals
```

## Key Features Explained

### Activity Logging
Users can log various types of exercises with:
- Predefined exercise categories with appropriate icons
- Duration tracking in minutes
- Calorie calculation (manual or automatic)
- Distance tracking (optional)
- Date/time selection
- Personal notes

### Goal Management
Set and track three types of daily goals:
- **Step Goals**: Target number of steps per day
- **Calorie Goals**: Target calories to burn per day  
- **Active Minute Goals**: Target minutes of activity per day

### Data Visualization
- Progress bars showing completion percentage
- Weekly bar charts displaying step counts
- Real-time statistics updates
- Remaining amounts to reach daily targets

### Smart Features
- **Automatic Calculations**: Estimate calories based on exercise type and duration
- **Data Filtering**: View activities by date ranges
- **Swipe Actions**: Delete activities with swipe gestures
- **Pull-to-Refresh**: Update data with refresh gesture

## Dependencies Used

```yaml
# Database
sqflite: ^2.3.3
path: ^1.9.0

# State Management  
provider: ^6.1.2

# Charts & Visualization
fl_chart: ^0.68.0

# Sensors (for future enhancement)
pedometer: ^4.0.3

# Local Storage
shared_preferences: ^2.3.2

# Utilities
intl: ^0.19.0
```

## Future Enhancements

### Planned Features
- [ ] Step counting integration using device sensors
- [ ] Cloud synchronization with Firebase
- [ ] Social features and challenges
- [ ] Advanced analytics and insights
- [ ] Workout templates and routines
- [ ] Integration with wearable devices
- [ ] Push notifications for goal reminders

### Potential Improvements
- [ ] Dark mode support
- [ ] Customizable themes
- [ ] Export data functionality
- [ ] Voice input for logging activities
- [ ] Barcode scanning for gym equipment

## Troubleshooting

### Common Issues

1. **Database Initialization Errors**
   - Ensure you're running on a supported platform (mobile recommended)
   - Check that all dependencies are properly installed

2. **Chart Rendering Issues**
   - Verify `fl_chart` dependency is correctly imported
   - Check data formatting for chart components

3. **Provider State Issues**
   - Make sure providers are properly initialized in `main.dart`
   - Verify `MultiProvider` setup is correct

### Development Tips

- Use `flutter pub run build_runner watch` for code generation if needed
- Enable Flutter DevTools for debugging: `flutter pub global activate devtools`
- Run tests with: `flutter test`

## Contributing

Feel free to fork this repository and submit pull requests for improvements. Areas that could use enhancement include:

- Additional exercise types
- Improved UI/UX designs
- Performance optimizations
- Additional chart types
- Accessibility improvements

## License

This project is open source and available under the [MIT License](LICENSE).

---

Built with ❤️ using Flutter