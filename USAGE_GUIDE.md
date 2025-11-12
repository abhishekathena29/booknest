# BookNest - Usage Guide

## Running the Application

### Quick Start
```bash
# Navigate to the project directory
cd /Users/abhishek/Desktop/athena_pro/booknest

# Run on your preferred device
flutter run
```

### Platform-Specific Commands

**Android Emulator:**
```bash
flutter run -d android
```

**iOS Simulator:**
```bash
flutter run -d ios
```

**Web Browser:**
```bash
flutter run -d chrome
```

**Physical Device:**
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

## App Navigation Flow

### First Time Users

1. **Welcome Screen**
   - Introduction to BookNest features
   - Two options: "Create Your Profile" or "Log In"

2. **Sign Up**
   - Enter email and create password
   - Or use Google/Apple sign-in (UI ready)

3. **Genre Selection**
   - Choose at least 3 favorite genres
   - Search for specific genres
   - Skip option available
   - Progress bar shows completion

4. **Main App**
   - Lands on Home screen
   - Full access to all features

### Returning Users

1. **Welcome Screen** → **Log In**
2. Enter credentials or use social login
3. Direct access to **Home Screen**

## Features Overview

### 🏠 Home Tab (Default Landing)
- **Personalized recommendations** based on AI analysis
- **Match percentages** showing compatibility
- **Genre suggestions** with quick access buttons
- **Floating Chat Button** (bottom right) - Quick access to BookBot

**Actions:**
- Tap any book → View full details
- Tap "Explore Sci-Fi" → Navigate to genre-filtered explore
- Tap chat bubble → Open AI assistant

### 🔍 Explore Tab
- **Search bar** at top for books/authors/genres
- **Genre grid** with 15+ categories
- **Filter button** (top right)

**Actions:**
- Search for specific content
- Tap genre card → View books in that genre

### 📚 My Library Tab
- **Currently Reading** section with progress
- **Want to Read** list with bookmarks
- **Finished** gallery view

**Actions:**
- Tap book → View details
- Tap bookmark icon → Add/remove from Want to Read
- Rate finished books

### 👥 Community Tab
- **Filter tabs**: All, My Books, Trending, Alternative
- **Discussion cards** with book info, user, and content
- **Engagement stats** (likes, comments)
- **Floating Edit Button** (bottom right) - Create new discussion

**Actions:**
- Tap discussion → View full thread
- Tap filter chip → Filter content
- Tap + button → Create new post

### 👤 Profile Tab
- **User stats** at top (books read, favorite genre)
- **Three sub-tabs**: My Library, AI Preferences, Settings

**My Library Sub-Tab:**
- Currently Reading with ratings
- Want to Read list

**AI Preferences Sub-Tab:**
- Selected favorite genres (chips)
- Excluded tags
- "Recalibrate Recommendations" button

**Settings Sub-Tab:**
- Account Details
- Change Password
- Push Notifications (toggle)
- Export Reading History
- Help & Support
- Privacy Policy
- Log Out (red text at bottom)

## AI ChatBot (BookBot)

**Access:**
- Tap floating chat button on Home screen
- Or navigate through any "Ask BookBot" prompt

**Features:**
- Type messages or use voice input (mic icon)
- **Suggestion chips** for quick queries:
  - "Suggest a fantasy book"
  - "Tell me about 'Dune'"
  - "Best sci-fi books"
- **Book recommendation cards** with:
  - Book cover preview
  - Title and author
  - "See Details" button

**Sample Queries:**
- "Can you recommend a fantasy book for me?"
- "What should I read after The Midnight Library?"
- "Tell me about books like Dune"
- "I'm in the mood for a thriller"

## Book Detail Screen

**Access:**
- Tap any book card throughout the app

**Tabs:**
1. **Summary**: Book description and synopsis
2. **Reviews**: Community reviews with ratings
   - "Write a Review" button at bottom
3. **Discussions**: Book-specific discussion threads
   - Ending Theories & Spoilers
   - Character Analysis
   - Spoiler-Free Q&A

**Actions:**
- "Add to My Shelf" (outlined button)
- "Mark as Read" (filled button)
- Share button (top right)
- Floating chat button → Ask BookBot about this book

## Theme Switching

The app automatically follows your device's theme:
- **Light Mode**: Warm, cream-colored design
- **Dark Mode**: Deep blue-green tones

## Tips & Tricks

### Personalization
1. **Complete genre selection** during onboarding for best recommendations
2. **Update AI Preferences** regularly as your taste evolves
3. **Rate books** you've read to improve recommendations

### Discovery
1. **Check "Trending in Community"** for popular books
2. **Join discussions** to get peer recommendations
3. **Ask BookBot** for personalized suggestions

### Organization
1. **Use "Want to Read"** as a wishlist
2. **Currently Reading** shows active books
3. **Finished** section archives your reading history

### Community Engagement
1. **Search discussions** before creating new ones
2. **Use spoiler tags** in discussion titles
3. **Engage with posts** through likes and comments

## Troubleshooting

### Common Issues

**App won't start:**
```bash
flutter clean
flutter pub get
flutter run
```

**Hot reload not working:**
- Press `R` in terminal for hot restart
- Or stop and restart the app

**UI looks broken:**
- Ensure you're on Flutter 3.8.1 or higher
- Run `flutter doctor` to check setup

**Navigation issues:**
- Tap bottom nav icons to switch screens
- Use back arrow to return from detail screens

## Development Notes

### Current Status
- ✅ UI/UX fully implemented
- ✅ Navigation working
- ✅ All screens accessible
- ⚠️ Backend integration pending
- ⚠️ Real AI features pending
- ⚠️ Authentication pending

### Mock Data
Currently using hardcoded data for:
- Book recommendations
- User information
- Community discussions
- ChatBot responses

### Future Updates
- Firebase authentication integration
- Real book API integration
- AI chatbot with GPT integration
- Real-time community features
- Reading progress sync
- Push notifications

## Keyboard Shortcuts (Desktop)

- `Ctrl/Cmd + S`: Save changes
- `Ctrl/Cmd + R`: Hot reload
- `Ctrl/Cmd + Shift + R`: Hot restart

## Testing

Run tests with:
```bash
flutter test
```

Run specific test:
```bash
flutter test test/widget_test.dart
```

## Need Help?

- **In-App**: Profile → Settings → Help & Support
- **Email**: support@booknest.app
- **Documentation**: See README.md

---

Enjoy discovering your next favorite book! 📚✨

