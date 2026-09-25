import 'package:flutter/material.dart';
import 'package:myexpence/core/theme/app_theme.dart';

class CategoryIconHelper {
  /// Converts category icon string identifier to Flutter [IconData].
  static IconData getIconData(String? iconName) {
    if (iconName == null) return Icons.receipt_long;

    switch (iconName.toLowerCase()) {
      case 'directions_car':
      case 'commute':
      case 'car':
      case 'transport':
      case 'fuel':
      case 'gas':
        return Icons.directions_car;
      case 'school':
      case 'education':
        return Icons.school;
      case 'home':
      case 'housing':
      case 'rent':
        return Icons.home;
      case 'bolt':
      case 'electric':
      case 'utility':
      case 'utilities':
        return Icons.bolt;
      case 'shopping_cart':
      case 'groceries':
      case 'grocery':
      case 'supermarket':
        return Icons.shopping_cart;
      case 'restaurant':
      case 'food':
      case 'dining':
      case 'fastfood':
        return Icons.restaurant;
      case 'medical_services':
      case 'health':
      case 'hospital':
      case 'doctor':
      case 'pharmacy':
        return Icons.medical_services;
      case 'shopping_bag':
      case 'shopping':
      case 'store':
        return Icons.shopping_bag;
      case 'movie':
      case 'entertainment':
      case 'cinema':
        return Icons.movie;
      case 'person':
      case 'personal':
        return Icons.person;
      case 'volunteer_activism':
      case 'charity':
      case 'donation':
        return Icons.volunteer_activism;
      case 'flight':
      case 'travel':
      case 'vacation':
        return Icons.flight;
      case 'pets':
      case 'pet':
        return Icons.pets;
      case 'fitness_center':
      case 'gym':
      case 'sports':
        return Icons.fitness_center;
      case 'account_balance':
      case 'bank':
      case 'finance':
        return Icons.account_balance;
      default:
        return Icons.receipt_long;
    }
  }

  /// Returns a vibrant theme color matching the category theme.
  static Color getCategoryColor(String? categoryIdOrIcon) {
    if (categoryIdOrIcon == null) return AppTheme.primaryColor;

    final key = categoryIdOrIcon.toLowerCase();
    if (key.contains('food') || key.contains('restaurant')) return Colors.orange[700]!;
    if (key.contains('grocer') || key.contains('supermarket') || key.contains('cart')) return Colors.green[700]!;
    if (key.contains('transport') || key.contains('car') || key.contains('fuel')) return Colors.blue[700]!;
    if (key.contains('health') || key.contains('medical') || key.contains('hospital')) return Colors.red[600]!;
    if (key.contains('utilit') || key.contains('bolt') || key.contains('electric')) return Colors.amber[800]!;
    if (key.contains('school') || key.contains('education')) return Colors.purple[600]!;
    if (key.contains('shopp') || key.contains('bag') || key.contains('store')) return Colors.pink[600]!;
    if (key.contains('home') || key.contains('hous')) return Colors.teal[700]!;
    if (key.contains('movie') || key.contains('entertain')) return Colors.indigo[600]!;

    return AppTheme.primaryColor;
  }

  /// Builds a visual Icon Avatar with background circle for expense lists.
  static Widget buildCategoryAvatar({
    required String? iconName,
    String? categoryId,
    double size = 42.0,
    double iconSize = 22.0,
  }) {
    final color = getCategoryColor(categoryId ?? iconName);
    final iconData = getIconData(iconName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Icon(
        iconData,
        color: color,
        size: iconSize,
      ),
    );
  }
}
