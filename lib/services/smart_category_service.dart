import 'package:flutter/material.dart';

class SmartCategory {
  final String name;
  final List<String> keywords;
  final IconData icon;
  final Color color;

  const SmartCategory({
    required this.name,
    required this.keywords,
    required this.icon,
    required this.color,
  });
}

class SmartCategoryService {
  static final List<SmartCategory> _categories = [
    SmartCategory(
      name: 'Groceries',
      keywords: [
        'grocery',
        'food',
        'supermarket',
        'market',
        'fruit',
        'vegetable',
      ],
      icon: Icons.shopping_basket,
      color: Colors.green,
    ),
    SmartCategory(
      name: 'Transportation',
      keywords: [
        'gas',
        'fuel',
        'uber',
        'taxi',
        'bus',
        'train',
        'metro',
        'transport',
      ],
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    SmartCategory(
      name: 'Entertainment',
      keywords: [
        'movie',
        'cinema',
        'theater',
        'concert',
        'game',
        'netflix',
        'spotify',
      ],
      icon: Icons.movie,
      color: Colors.purple,
    ),
    SmartCategory(
      name: 'Dining',
      keywords: ['restaurant', 'cafe', 'coffee', 'lunch', 'dinner', 'food'],
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    SmartCategory(
      name: 'Shopping',
      keywords: ['mall', 'clothes', 'shoes', 'apparel', 'store', 'shop'],
      icon: Icons.shopping_bag,
      color: Colors.red,
    ),
    SmartCategory(
      name: 'Bills',
      keywords: [
        'electricity',
        'water',
        'internet',
        'phone',
        'utility',
        'bill',
      ],
      icon: Icons.receipt,
      color: Colors.brown,
    ),
  ];

  String suggestCategory(String description) {
    description = description.toLowerCase();

    for (var category in _categories) {
      for (var keyword in category.keywords) {
        if (description.contains(keyword.toLowerCase())) {
          return category.name;
        }
      }
    }

    return 'Other'; // Default category
  }

  SmartCategory? getCategoryDetails(String categoryName) {
    try {
      return _categories.firstWhere((cat) => cat.name == categoryName);
    } catch (e) {
      return null;
    }
  }

  List<SmartCategory> getAllCategories() {
    return List.from(_categories);
  }
}
