#!/bin/bash

# Reset Database Script
# Use this when you need to recreate the database with new schema

echo "🗑️  Resetting database..."

# Delete SQLite database files
rm -f .dart_tool/sqflite_common_ffi/databases/expenses.db*

echo "✅ Database deleted!"
echo "📱 Run 'flutter run' to recreate with new schema"
