# Changelog

All notable changes to WizeBudge will be documented in this file.

## [0.2.0] - 2024-11-01

### 🎨 UI/UX Enhancements

#### Splash Screen & Onboarding
- ✨ Added beautiful animated splash screen with logo and brand colors
- ✨ Implemented 4-page interactive onboarding for first-time users
- ✨ Added SharedPreferences to track first-time user status
- ✨ Smooth transitions between splash, onboarding, and main app

#### Dashboard Redesign
- ✨ Redesigned app bar with prominent logo (no text, clean design)
- ✨ Logo displayed in white container with shadow effects
- ✨ Fixed app bar height (80px) to prevent overflow issues
- ✨ Larger, wider logo (120x45px) for better visibility
- ✨ Improved action button icons (notifications & search)

#### Authentication UI Overhaul
- ✨ Complete redesign of PIN lock screen with modern gradient background
- ✨ Frosted glass PIN display container
- ✨ Improved numeric keypad with better spacing and shadows
- ✨ Backspace icon instead of text symbol
- ✨ Added "Forgot PIN?" button with reset functionality
- ✨ Biometric button with label and improved styling
- ✨ Redesigned all auth setup screens (Welcome, PIN Setup, Biometric, Complete)
- ✨ Gradient backgrounds for each setup page
- ✨ White circular containers for icons with shadows
- ✨ Inverse button style (white buttons with colored text)

### 🔧 Bug Fixes

#### Authentication Fixes
- 🐛 Fixed animation disposal error in auth lock screen
- 🐛 Added proper mounted checks before state updates
- 🐛 Wrapped animation controller calls in try-catch blocks
- 🐛 Fixed navigation timing to prevent disposed controller access

#### Layout Fixes
- 🐛 Fixed overflow issues in auth lock screen (added SingleChildScrollView)
- 🐛 Fixed overflow issues in all auth setup screens
- 🐛 Fixed overflow issues in onboarding screen (reduced icon size and spacing)
- 🐛 Fixed app bar overflow on dashboard when scrolling
- 🐛 Added ConstrainedBox to maintain centered layout while allowing scroll

### 🔒 Security Features

- ✨ Added "Forgot PIN?" functionality for easy recovery
- ✨ Reset dialog with clear warnings about data safety
- ✨ Improved biometric authentication flow
- ✨ Better error handling for failed authentication attempts

### 📱 User Experience

- ✨ Responsive layouts that work on all screen sizes
- ✨ Smooth animations throughout the app
- ✨ Better visual feedback on interactions
- ✨ Improved touch targets for better accessibility
- ✨ Consistent design language across all screens

### 📝 Documentation

- 📚 Updated README.md with all new features
- 📚 Added comprehensive feature list
- 📚 Updated architecture section
- 📚 Updated dependencies list
- 📚 Added implemented features checklist
- 📚 Improved getting started guide

### 🔄 Configuration

- ⚙️ Updated GitHub Actions workflow (Flutter CI)
- ⚙️ Maintained compatibility with Flutter 3.35.7
- ⚙️ All dependencies up to date

## [0.1.0] - 2024-10-31

### Initial Release

- 🎉 Basic expense and income tracking
- 📊 Charts and analytics
- 🎯 Financial goals
- 🤖 AI-powered insights
- 🔄 Recurring transactions
- 📄 PDF export
- 🔐 PIN and biometric authentication
- 🌓 Dark mode support
- 💾 Local SQLite database

---

**Note**: This project follows [Semantic Versioning](https://semver.org/).
