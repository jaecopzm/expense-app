# Custom Snackbar Usage Guide

## Overview
The custom snackbar features the WizeBudge logo and provides a branded, professional notification experience.

## Import
```dart
import '../utils/custom_snackbar.dart';
```

## Usage

### Success Message
```dart
CustomSnackbar.show(
  context,
  message: 'Expense saved successfully!',
  type: SnackbarType.success,
);
```
**Appearance:** Green background, check icon, WizeBudge logo

### Error Message
```dart
CustomSnackbar.show(
  context,
  message: 'Failed to scan receipt',
  type: SnackbarType.error,
);
```
**Appearance:** Red background, error icon, WizeBudge logo

### Warning Message
```dart
CustomSnackbar.show(
  context,
  message: 'Budget limit approaching',
  type: SnackbarType.warning,
);
```
**Appearance:** Orange background, warning icon, WizeBudge logo

### Info Message
```dart
CustomSnackbar.show(
  context,
  message: 'Syncing data...',
  type: SnackbarType.info,
);
```
**Appearance:** Blue background, info icon, WizeBudge logo

### Custom Duration
```dart
CustomSnackbar.show(
  context,
  message: 'Processing...',
  type: SnackbarType.info,
  duration: Duration(seconds: 5), // Default is 3 seconds
);
```

## Design Features

### Layout
```
┌─────────────────────────────────────────┐
│ [Logo] Message text here...      [Icon] │
└─────────────────────────────────────────┘
```

### Styling
- **Shape:** Rounded corners (12px radius)
- **Behavior:** Floating (not attached to bottom)
- **Margin:** 16px all sides
- **Elevation:** 6 (subtle shadow)
- **Logo:** 24px height, 60px width
- **Icon:** 20px, white color
- **Text:** 14px, medium weight, white

### Colors
- **Success:** `Colors.green.shade600`
- **Error:** `Colors.red.shade600`
- **Warning:** `Colors.orange.shade600`
- **Info:** `Colors.blue.shade600`

## Examples in App

### Receipt Scanner
```dart
// Success
CustomSnackbar.show(
  context,
  message: 'Expense saved successfully!',
  type: SnackbarType.success,
);

// Error
CustomSnackbar.show(
  context,
  message: 'Failed to scan receipt',
  type: SnackbarType.error,
);
```

### Budget Screen
```dart
// Success
CustomSnackbar.show(
  context,
  message: 'Budget created!',
  type: SnackbarType.success,
);

// Warning
CustomSnackbar.show(
  context,
  message: 'You\'ve spent 85% of your budget',
  type: SnackbarType.warning,
);
```

### AI Insights
```dart
// Info
CustomSnackbar.show(
  context,
  message: 'Analyzing your spending patterns...',
  type: SnackbarType.info,
);
```

## Best Practices

### Do's ✅
- Use success for completed actions
- Use error for failures
- Use warning for alerts/cautions
- Use info for neutral notifications
- Keep messages concise (< 50 characters)
- Use action verbs ("Saved", "Failed", "Updated")

### Don'ts ❌
- Don't use for long messages
- Don't stack multiple snackbars
- Don't use for critical errors (use dialog instead)
- Don't overuse (only for important feedback)

## Replacing Old Snackbars

### Before
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Expense saved')),
);
```

### After
```dart
CustomSnackbar.show(
  context,
  message: 'Expense saved successfully!',
  type: SnackbarType.success,
);
```

## Logo Fallback
If the logo fails to load, the snackbar automatically falls back to showing just the icon:
```dart
errorBuilder: (_, __, ___) => Icon(icon, color: Colors.white),
```

## Accessibility
- High contrast colors for readability
- Icon + text for multiple sensory cues
- Appropriate duration for reading
- Floating position doesn't block content

## Testing
```dart
// Test all types
void testSnackbars(BuildContext context) {
  CustomSnackbar.show(context, message: 'Success!', type: SnackbarType.success);
  
  Future.delayed(Duration(seconds: 4), () {
    CustomSnackbar.show(context, message: 'Error!', type: SnackbarType.error);
  });
  
  Future.delayed(Duration(seconds: 8), () {
    CustomSnackbar.show(context, message: 'Warning!', type: SnackbarType.warning);
  });
  
  Future.delayed(Duration(seconds: 12), () {
    CustomSnackbar.show(context, message: 'Info!', type: SnackbarType.info);
  });
}
```

## Customization

To modify the snackbar appearance, edit `lib/utils/custom_snackbar.dart`:

```dart
// Change logo size
Image.asset(
  'assets/images/wizebudge-logo.png',
  height: 30, // Increase size
  width: 75,
  // ...
)

// Change border radius
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(16), // More rounded
),

// Change margin
margin: const EdgeInsets.all(20), // More spacing
```

---

**The custom snackbar provides a professional, branded notification experience that reinforces the WizeBudge identity throughout the app!** 🎉
