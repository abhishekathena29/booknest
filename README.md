# BookNest - AI-Powered Book Recommendation App

A beautiful Flutter application for discovering books, getting AI-powered recommendations, and connecting with a community of readers.

## Features

### 🏠 Home Screen
- Personalized book recommendations based on reading preferences
- "Top Picks For You" with match percentages
- "Because You Loved" section for similar book recommendations
- Trending books in your community
- Genre-based exploration prompts
- Quick access to AI chatbot via floating action button

### 🔍 Explore Screen
- Search functionality for books, authors, and genres
- Browse by genre with visually appealing genre cards
- Filter options for refined searching

### 📚 My Library Screen
- Currently Reading section with progress tracking
- Want to Read list
- Finished books gallery
- Book ratings and reviews

### 👥 Community Hub Screen
- Discussion forums organized by genres
- Trending discussions in your favorite genres
- Create and participate in book discussions
- Spoiler warnings and theory crafting
- Like and comment on posts
- Filter by "All", "My Books", "Trending", and more

### 👤 Profile Screen
- User statistics (books read this year, favorite genre)
- Three main tabs: My Library, AI Preferences, Settings
- **My Library Tab**: View currently reading and want-to-read lists
- **AI Preferences Tab**: 
  - Manage favorite genres
  - Exclude specific tags
  - Recalibrate recommendations
- **Settings Tab**:
  - Account management
  - Notification preferences
  - Export reading history
  - Help & Support
  - Privacy Policy

### 💬 AI ChatBot (BookBot)
- Interactive AI assistant for book recommendations
- Ask questions about books
- Get personalized suggestions based on mood
- Voice input support
- Quick suggestion chips for common queries
- Beautiful book recommendation cards with details

### 📖 Book Detail Screen
- Comprehensive book information
- Ratings and reviews from the community
- Discussion threads specific to the book
- Add to shelf or mark as read
- Three tabs: Summary, Reviews, Discussions
- AI-powered recommendation explanation

### 🔐 Authentication
- **Login Screen**: Email/password or social login (Google, Apple)
- **Sign Up Screen**: Create account with email verification
- Forgot password functionality

### 🎨 Onboarding
- **Welcome Screen**: Beautiful introduction to app features
- **Genre Selection**: Choose favorite genres for personalized recommendations
- Progress indicators
- Skip option for quick access

## Design Features

### Theme
- **Light Mode**: Warm cream and orange tones for comfortable reading
- **Dark Mode**: Deep blue-green tones for nighttime reading
- Material Design 3
- Custom Google Fonts (Crimson Pro)

### Colors
- Primary (Light): `#D2691E` (Chocolate)
- Primary (Dark): `#2D7A7B` (Teal)
- Secondary (Light): `#2D7A7B` (Teal)
- Secondary (Dark): `#5BA9AA` (Light Teal)
- Background (Light): `#FFF8F0` (Cream)
- Background (Dark): `#1A2730` (Dark Blue)

### UI/UX
- Smooth animations and transitions
- Bottom navigation with 5 tabs
- Floating action buttons for quick actions
- Card-based layouts
- Gradient backgrounds
- Shadow effects for depth
- Responsive design

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── screens/
│   ├── main_navigation.dart           # Bottom navigation controller
│   ├── home_screen.dart               # Home feed with recommendations
│   ├── explore_screen.dart            # Search and genre browsing
│   ├── my_library_screen.dart         # Personal library management
│   ├── community_screen.dart          # Discussion forums
│   ├── profile_screen.dart            # User profile and settings
│   ├── book_detail_screen.dart        # Individual book details
│   ├── chatbot_screen.dart            # AI assistant interface
│   ├── auth/
│   │   ├── login_screen.dart          # Login interface
│   │   └── signup_screen.dart         # Registration interface
│   └── onboarding/
│       ├── welcome_screen.dart        # Welcome splash
│       └── genre_selection_screen.dart # Genre preference setup
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.1.0      # Custom fonts
  flutter_svg: ^2.0.9       # SVG support
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS development: Xcode (for macOS)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/booknest.git
cd booknest
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Platform-specific Setup

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Build with: `flutter build apk`

#### iOS
- Minimum iOS version: 12.0
- Build with: `flutter build ios`

#### Web
- Run with: `flutter run -d chrome`
- Build with: `flutter build web`

## App Flow

1. **First Launch** → Welcome Screen
2. **Sign Up** → Genre Selection → Home Screen
3. **Login** → Home Screen (with bottom navigation)
4. **Navigation Tabs**:
   - Home: Personalized recommendations
   - Explore: Search and browse
   - My Library: Your books
   - Community: Discussions
   - Profile: Settings and preferences

## Features to Implement (Future)

- [ ] Backend integration with book APIs
- [ ] Real AI chatbot integration
- [ ] User authentication with Firebase
- [ ] Real-time community features
- [ ] Push notifications
- [ ] Reading progress tracking
- [ ] Social sharing
- [ ] Bookmarks and notes
- [ ] Audio book integration
- [ ] Reading challenges and achievements

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Book data from Open Library API
- AI recommendations powered by OpenAI
- Design inspired by modern reading apps
- Icons from Material Design Icons

## Contact

For questions or feedback, please contact:
- Email: support@booknest.app
- Twitter: @booknestapp
- Website: https://booknest.app

---

Built with ❤️ using Flutter
