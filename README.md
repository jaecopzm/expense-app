# WizeBudge 💰

A modern, beautiful financial management app built with Flutter. Track your expenses and income, set financial goals, get AI-powered insights, and manage your money with style and security.

## ✨ Features

### 🎨 Modern UI/UX Design

- **Beautiful Gradients**: Eye-catching gradient cards and modern color schemes
- **Custom Fonts**: Google Fonts (Inter) for a polished, professional look
- **Smooth Animations**: Fluid transitions, slide-ins, and micro-interactions throughout
- **Dark Mode**: Full dark theme support with seamless switching
- **Material 3**: Latest Material Design guidelines
- **Splash Screen**: Beautiful animated splash screen with logo
- **Onboarding**: 4-page interactive onboarding for first-time users
- **Logo-Centric App Bar**: Clean, modern app bar with prominent logo

### 📊 Dashboard

- **Net Balance Card**: Display income vs expenses with beautiful gradients
- **Quick Stats**: Income, expenses, and balance at a glance
- **Recent Transactions**: Combined view of expenses and income
- **Smart Date Formatting**: Shows "Today", "Yesterday", or day names for recent items
- **Pull to Refresh**: Easy data refresh with swipe gesture
- **Empty States**: Friendly empty state designs with helpful guidance
- **Skeleton Loaders**: Smooth loading states with shimmer effects

### 💰 Income & Expense Management

#### Add Expense
- **Modern UI**: Beautiful gradient screens with enhanced forms
- **Quick Amount Buttons**: Tap to quickly enter common amounts
- **Visual Category Selection**: 12+ categories with icons
- **Smart Categories**: Food, Transport, Shopping, Bills, Entertainment, Health, Education, Salary, Freelance, Investment, Gift, Other
- **AI-Powered Suggestions**: Get smart category suggestions
- **Input Validation**: Smart form validation and error handling

#### Add Income
- **Income Tracking**: Track all your income sources
- **Multiple Income Types**: Salary, Freelance, Investment, Business, Gift, Other
- **Date Selection**: Choose custom dates for income entries
- **Notes**: Add descriptions for each income source

### 📈 Insights & Analytics

- **AI-Powered Insights**: Get intelligent spending analysis and recommendations
- **Pie Charts**: Visual breakdown of spending by category
- **Bar Charts**: Monthly trends and comparisons
- **Category Analysis**: Detailed breakdown with percentages and progress bars
- **Spending Patterns**: Identify trends and habits
- **Smart Predictions**: AI predicts future spending patterns
- **Export Reports**: Generate and share PDF reports
- **Color-Coded**: Each category has a unique, vibrant color

### ⚙️ Settings

- **Dark Mode Toggle**: Switch between light and dark themes instantly
- **Security Settings**: PIN and biometric authentication
- **Recurring Transactions**: Manage automatic transactions
- **Data Management**: Export, backup, and clear data options
- **Database Optimization**: Keep your app running smoothly
- **Stats Summary**: Quick overview of total tracked data
- **Modern Card Design**: Grouped settings with colored icons

### 💳 Expense Cards

- **Swipe to Delete**: Intuitive swipe gesture reveals delete action
- **Category Color Coding**: Each expense shows its category color
- **Rich Information**: Title, category badge, amount, and smart date
- **Expense Badge**: Visual "Expense" indicator for each transaction
- **Smooth Animations**: Slide animations when deleting

### 🔒 Security Features

- **PIN Protection**: Set up a 4-digit PIN to secure your data
- **Biometric Authentication**: Use fingerprint or face recognition
- **Auto-Lock**: Automatically lock app after inactivity
- **Forgot PIN**: Easy recovery option to reset authentication
- **Secure Storage**: All sensitive data encrypted locally

### 🎯 Financial Goals

- **Goal Setting**: Create and track financial goals
- **Progress Tracking**: Visual progress bars and percentages
- **Target Dates**: Set deadlines for your goals
- **Multiple Goals**: Manage unlimited financial goals
- **Smart Reminders**: Stay on track with your objectives

### 🔄 Recurring Transactions

- **Auto Transactions**: Set up recurring expenses and income
- **Flexible Frequency**: Daily, weekly, monthly, or yearly
- **Smart Notifications**: Get reminded before transactions
- **Easy Management**: View and edit all recurring items

### 🎯 Additional Features

- **Enhanced Navigation**: Beautiful bottom navigation with 5 tabs
- **Search Functionality**: Quick search for any transaction
- **Notifications**: Stay informed about your finances
- **Responsive Design**: Adapts to all screen sizes
- **Local Database**: SQLite for fast, offline data storage
- **State Management**: Provider pattern for reactive updates
- **Pull to Refresh**: Update data with a simple swipe

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator (for testing)

### Installation

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd wize_budge
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1 # State management
  sqflite: ^2.4.2 # Local database
  sqflite_common_ffi: ^2.3.2 # Desktop support
  path: ^1.9.1 # Path utilities
  fl_chart: ^1.1.1 # Beautiful charts
  intl: ^0.20.2 # Date formatting
  google_fonts: ^6.2.1 # Custom fonts
  shared_preferences: ^2.3.3 # Persistent settings
  flutter_slidable: ^4.0.3 # Swipe actions
  shimmer: ^3.0.0 # Loading animations
  hugeicons: ^1.1.1 # Icon library
  google_generative_ai: ^0.4.7 # AI insights
  pdf: ^3.10.8 # PDF generation
  path_provider: ^2.1.2 # File system access
  in_app_purchase: ^3.1.13 # Premium features
  share_plus: ^12.0.1 # Share functionality
  flutter_secure_storage: ^9.0.0 # Secure data storage
  crypto: ^3.0.3 # Encryption
  device_info_plus: ^12.2.0 # Device information
  local_auth: ^2.3.0 # Biometric authentication
  local_auth_android: ^1.0.41 # Android biometric
  local_auth_darwin: ^1.4.1 # iOS biometric
```

## 🏗️ Architecture

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── expense.dart                  # Expense data model
│   ├── income.dart                   # Income data model
│   └── recurring_transaction.dart    # Recurring transaction model
├── providers/
│   ├── expense_provider.dart         # Expense state management
│   ├── income_provider.dart          # Income state management
│   ├── theme_provider.dart           # Theme state management
│   ├── auth_provider.dart            # Authentication state
│   ├── financial_goals_provider.dart # Goals state management
│   ├── premium_provider.dart         # Premium features
│   └── recurring_transaction_provider.dart
├── screens/
│   ├── splash_screen.dart            # Splash screen
│   ├── onboarding_screen.dart        # First-time user experience
│   ├── enhanced_dashboard_screen.dart # Home screen
│   ├── enhanced_add_expense_screen.dart
│   ├── enhanced_add_income_screen.dart
│   ├── enhanced_insights_screen_new.dart
│   ├── enhanced_settings_screen.dart
│   ├── enhanced_financial_goals_screen.dart
│   ├── recurring_transactions_screen.dart
│   ├── subscription_screen.dart
│   └── auth/
│       ├── auth_wrapper.dart         # Authentication wrapper
│       ├── auth_lock_screen.dart     # PIN lock screen
│       └── auth_setup_screen.dart    # Initial setup
├── services/
│   ├── ai_service.dart               # AI-powered insights
│   ├── auth_service.dart             # Authentication service
│   ├── pdf_export_service.dart       # PDF generation
│   ├── secure_storage.dart           # Secure data storage
│   └── smart_category_service.dart   # Smart categorization
├── theme/
│   └── app_theme_enhanced.dart       # Enhanced theme system
├── widgets/
│   ├── enhanced_cards.dart           # Card components
│   ├── enhanced_expense_card.dart    # Expense card
│   ├── income_card.dart              # Income card
│   ├── animated_widgets.dart         # Animation helpers
│   ├── enhanced_inputs.dart          # Input components
│   ├── enhanced_navigation.dart      # Bottom navigation
│   └── skeleton_loader.dart          # Loading states
└── utils/
    ├── db_helper.dart                # Database helper
    ├── branding.dart                 # App branding
    └── widget_utils.dart             # Widget utilities
```

## 🎨 Design System

### Colors

- **Primary**: #6C63FF (Purple)
- **Secondary**: #4CAF50 (Green)
- **Category Colors**: Red, Cyan, Yellow, Pink, Purple, Mint, Blue, Gray

### Typography

- **Font Family**: Inter (Google Fonts)
- **Weights**: Regular (400), Medium (500), Semi-bold (600), Bold (700), Extra-bold (800)

### Spacing

- Base unit: 4px
- Common spacing: 8px, 12px, 16px, 20px, 24px, 32px

### Border Radius

- Small: 8px
- Medium: 12px, 16px
- Large: 20px, 24px

## ✅ Implemented Features

- [x] Beautiful modern UI with gradients and animations
- [x] Income and expense tracking
- [x] Financial goals tracking
- [x] AI-powered insights and recommendations
- [x] Recurring transactions
- [x] PDF report export
- [x] PIN and biometric authentication
- [x] Dark mode support
- [x] Splash screen and onboarding
- [x] Search and filtering
- [x] Data export and backup
- [x] Database optimization
- [x] Skeleton loading states
- [x] Pull to refresh
- [x] Swipe to delete

## 🔮 Future Enhancements

- [ ] Multiple currencies support
- [ ] Cloud backup and sync
- [ ] Budget alerts and notifications
- [ ] Receipt photo attachment
- [ ] Multi-language support
- [ ] Expense categories customization
- [ ] Charts and trends export
- [ ] Widget for home screen
- [ ] Wear OS support
- [ ] Social sharing features

## 📱 Screenshots

_Add screenshots of your app here_

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 JaeyCop

Built with ❤️ using Flutter

---

**Note**: This app stores data locally on your device. Make sure to back up your data regularly.
