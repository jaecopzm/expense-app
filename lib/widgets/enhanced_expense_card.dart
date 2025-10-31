import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../theme/app_theme_enhanced.dart';
import '../widgets/animated_widgets.dart';
import '../screens/enhanced_edit_expense_screen.dart';

class EnhancedExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const EnhancedExpenseCard({
    super.key,
    required this.expense,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppThemeEnhanced.getCategoryColor(expense.category);

    return Slidable(
      key: ValueKey(expense.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    EnhancedEditExpenseScreen(expense: expense),
              );
            },
            backgroundColor: AppThemeEnhanced.info,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete?.call(),
            backgroundColor: AppThemeEnhanced.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
          ),
        ],
      ),
      child: BounceAnimation(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => EnhancedEditExpenseScreen(expense: expense),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppThemeEnhanced.spaceLg,
            vertical: AppThemeEnhanced.spaceXs,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
            border: Border.all(color: categoryColor.withOpacity(0.1), width: 1),
            boxShadow: AppThemeEnhanced.shadowSm,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
            child: Row(
              children: [
                // Category Icon with Gradient
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppThemeEnhanced.getCategoryGradient(
                      expense.category,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppThemeEnhanced.radiusMd,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppThemeEnhanced.spaceMd),

                // Expense Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppThemeEnhanced.spaceXs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppThemeEnhanced.spaceSm,
                              vertical: AppThemeEnhanced.spaceXs,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppThemeEnhanced.radiusXs,
                              ),
                            ),
                            child: Text(
                              expense.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppThemeEnhanced.spaceSm),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: AppThemeEnhanced.spaceXs),
                          Text(
                            _formatDate(expense.date),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                      if (expense.note != null) ...[
                        const SizedBox(height: AppThemeEnhanced.spaceXs),
                        Text(
                          expense.note!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppThemeEnhanced.spaceMd),

                // Amount and Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedCounter(
                      value: expense.amount,
                      prefix: '\$',
                      textStyle: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppThemeEnhanced.spaceXs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppThemeEnhanced.spaceSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeEnhanced.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppThemeEnhanced.radiusXs,
                        ),
                      ),
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppThemeEnhanced.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }
}
