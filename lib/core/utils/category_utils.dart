import 'package:flutter/material.dart';
import 'package:jaibee/data/models/category.dart';
import 'package:jaibee/l10n/s.dart';

String getLocalizedCategory(String name, S localizer) {
  final map = {
    'food': localizer.food,
    'transport': localizer.transport,
    'transportation': localizer.transport,
    'entertainment': localizer.entertainment,
    'coffee': localizer.coffee,
    'income': localizer.income,
    'shopping': localizer.shopping,
    'travel': localizer.travel,
    'education': localizer.education,
    'health': localizer.health,
    'bills': localizer.bills,
    'groceries': localizer.groceries,
    'beauty': localizer.beauty,
    'electronics': localizer.electronics,
    'books': localizer.books,
    'petcare': localizer.petCare,
    'gifts': localizer.gifts,
    'home': localizer.home,
    'savings': localizer.savings,
    'events': localizer.events,
    'fitness': localizer.fitness,
    'other': localizer.other,
  };
  return map[name.toLowerCase()] ?? name;
}

IconData getCategoryIcon(Category category) {
  const iconMap = {
    'shopping_cart': Icons.shopping_cart,
    'coffee': Icons.local_cafe,
    'local_hospital': Icons.local_hospital,
    'directions_car': Icons.directions_car,
    'restaurant': Icons.restaurant,
    'school': Icons.school,
    'movie': Icons.movie,
    'fitness_center': Icons.fitness_center,
    'flight': Icons.flight,
    'home': Icons.home,
    'credit_card': Icons.credit_card,
    'local_mall': Icons.local_mall,
    'spa': Icons.spa,
    'computer': Icons.computer,
    'book': Icons.book,
    'pets': Icons.pets,
    'cake': Icons.cake,
    'savings': Icons.savings,
    'event': Icons.event,
    'attach_money': Icons.attach_money,
  };
  return iconMap[category.icon] ?? Icons.category;
}
