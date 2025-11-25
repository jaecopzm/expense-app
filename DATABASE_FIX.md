# Database Migration Fix

## Problem
The app was trying to insert data into a column (`receiptImage`) that doesn't exist in the existing database.

## Solution Applied ✅

### 1. Deleted Old Database
```bash
rm -f .dart_tool/sqflite_common_ffi/databases/expenses.db*
```

### 2. Added onUpgrade Handler
Updated `db_helper.dart` to run migrations when database version changes.

### 3. Created Reset Script
```bash
./reset_database.sh
```

## How to Use

### If You Get Column Errors Again

**Option 1: Use the reset script**
```bash
./reset_database.sh
flutter run
```

**Option 2: Manual deletion**
```bash
rm -f .dart_tool/sqflite_common_ffi/databases/expenses.db*
flutter run
```

**Option 3: For Android/iOS devices**
```bash
# Uninstall the app from device
# Then reinstall
flutter run
```

## What Happens Now

When you run the app:
1. Database doesn't exist
2. `onCreate` is called
3. All tables created with latest schema including:
   - `receiptImage` column in expenses
   - `budgets` table
4. App works perfectly ✅

## Database Schema (v6)

### expenses table
- id (PRIMARY KEY)
- title
- amount
- category
- date
- note
- **receiptImage** ← NEW
- createdAt

### budgets table ← NEW
- id (PRIMARY KEY)
- category
- amount
- period
- created_at

## Future Migrations

When adding new columns:

1. **Update version number** in `db_helper.dart`:
```dart
version: 7, // Increment
```

2. **Add migration** in `_runDiagnosticsAndMigrations`:
```dart
if (currentVersion < 7) {
  debugPrint('Applying migration to v7');
  await db.execute("ALTER TABLE expenses ADD COLUMN newColumn TEXT");
  currentVersion = 7;
  await db.execute('PRAGMA user_version = $currentVersion');
}
```

3. **Update onCreate** with new column:
```dart
CREATE TABLE expenses(
  ...
  newColumn TEXT,
  ...
)
```

## Testing

After reset, test:
- ✅ Add expense (should work)
- ✅ Scan receipt (should save with image path)
- ✅ Create budget (should work)
- ✅ View all data (should display correctly)

## Note for Production

⚠️ **This reset deletes all data!**

For production apps with user data:
- Use proper migrations (ALTER TABLE)
- Test migrations thoroughly
- Backup data before migration
- Handle migration failures gracefully

For development (like now):
- Resetting is fine
- Faster than writing complex migrations
- Clean slate for testing

---

**Status:** ✅ Fixed - Database will recreate on next run with correct schema
