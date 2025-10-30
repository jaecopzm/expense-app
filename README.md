# SpendWise 💰

A modern, beautiful expense tracking app built with Flutter. Track your spending with style and gain insights into your financial habits.

## ✨ Features

### 🎨 Modern UI/UX Design
- **Beautiful Gradients**: Eye-catching gradient cards and modern color schemes
- **Custom Fonts**: Google Fonts (Inter) for a polished, professional look
- **Smooth Animations**: Fluid transitions and micro-interactions throughout the app
- **Dark Mode**: Full dark theme support with seamless switching
- **Material 3**: Latest Material Design guidelines

### 📊 Dashboard
- **Gradient Balance Card**: Display total monthly spending with beautiful gradients
- **Quick Stats**: Weekly spending and category count at a glance
- **Smart Date Formatting**: Shows "Today", "Yesterday", or day names for recent expenses
- **Pull to Refresh**: Easy data refresh with swipe gesture
- **Empty States**: Friendly empty state designs with helpful guidance

### ➕ Add Expense (Bottom Sheet)
- **Modal Bottom Sheet**: Modern slide-up interface for adding expenses
- **Quick Amount Buttons**: Tap to quickly enter common amounts ($10, $25, $50, $100, $200)
- **Visual Category Selection**: Color-coded category chips with icons
- **8 Categories**: Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other
- **Input Validation**: Smart form validation and error handling
- **Success Feedback**: Snackbar confirmation after adding expenses

### 📈 Insights
- **Pie Chart**: Visual breakdown of spending by category using fl_chart
- **Category Analysis**: Detailed breakdown with percentages and progress bars
- **Smart Stats Card**: Total, average, and expense count displayed beautifully
- **Color-Coded Categories**: Each category has a unique, vibrant color
- **Sorted by Spending**: Categories ordered by amount spent

### ⚙️ Settings
- **Dark Mode Toggle**: Switch between light and dark themes with smooth animations
- **Clear All Data**: Delete all expenses with confirmation dialog
- **Export Data**: Placeholder for future CSV export feature
- **Stats Summary**: Quick overview of total tracked expenses
- **Modern List Design**: Grouped settings with colored icons

### 💳 Expense Cards
- **Swipe to Delete**: Intuitive swipe gesture reveals delete action
- **Category Color Coding**: Each expense shows its category color
- **Rich Information**: Title, category badge, amount, and smart date
- **Expense Badge**: Visual "Expense" indicator for each transaction
- **Smooth Animations**: Slide animations when deleting

### 🎯 Additional Features
- **Floating Action Button**: Prominent "Add Expense" button with animation
- **3-Tab Navigation**: Streamlined navigation (Home, Insights, Settings)
- **Responsive Design**: Adapts to different screen sizes
- **Local Database**: SQLite for fast, offline data storage
- **State Management**: Provider pattern for reactive updates

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
   cd spend_wise
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
  provider: ^6.1.5+1        # State management
  sqflite: ^2.4.2           # Local database
  path: ^1.9.1              # Path utilities
  fl_chart: ^0.69.0         # Beautiful charts
  intl: ^0.19.0             # Date formatting
  google_fonts: ^6.2.1      # Custom fonts
  shared_preferences: ^2.3.3 # Persistent settings
  flutter_slidable: ^3.1.1  # Swipe actions
  shimmer: ^3.0.0           # Loading animations
```

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── expense.dart         # Expense data model
├── providers/
│   ├── expense_provider.dart # Expense state management
│   └── theme_provider.dart   # Theme state management
├── screens/
│   ├── dashboard_screen.dart # Home screen
│   ├── add_expense_screen.dart # Add expense modal
│   ├── insights_screen.dart  # Analytics screen
│   └── settings_screen.dart  # Settings screen
├── theme/
│   └── app_theme.dart       # Theme configuration
├── widgets/
│   └── expense_card.dart    # Expense list item
└── utils/
    └── db_helper.dart       # Database helper
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

## 🔮 Future Enhancements

- [ ] Budget setting and tracking
- [ ] Recurring expenses
- [ ] Multiple currencies
- [ ] Export to CSV/PDF
- [ ] Expense categories customization
- [ ] Monthly/yearly reports
- [ ] Expense search and filtering
- [ ] Expense editing
- [ ] Biometric authentication
- [ ] Cloud backup and sync
- [ ] Receipt photo attachment
- [ ] Multi-language support

## 📱 Screenshots

*Add screenshots of your app here*

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 JaeyCop

Built with ❤️ using Flutter

---

**Note**: This app stores data locally on your device. Make sure to back up your data regularly.
