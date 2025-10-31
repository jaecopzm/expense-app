import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme_enhanced.dart';
import '../widgets/enhanced_inputs.dart';
import '../widgets/animated_widgets.dart';

class EnhancedEditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EnhancedEditExpenseScreen({super.key, required this.expense});

  @override
  State<EnhancedEditExpenseScreen> createState() =>
      _EnhancedEditExpenseScreenState();
}

class _EnhancedEditExpenseScreenState extends State<EnhancedEditExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _category;
  late DateTime _selectedDate;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Transport', 'icon': Icons.directions_car_rounded},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'Bills', 'icon': Icons.receipt_long_rounded},
    {'name': 'Entertainment', 'icon': Icons.movie_rounded},
    {'name': 'Health', 'icon': Icons.medical_services_rounded},
    {'name': 'Education', 'icon': Icons.school_rounded},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    _noteController = TextEditingController(text: widget.expense.note ?? '');
    _category = widget.expense.category;
    _selectedDate = widget.expense.date;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppThemeEnhanced.primaryLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final updatedExpense = widget.expense.copyWith(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _category,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).updateExpense(updatedExpense);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Expense updated successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppThemeEnhanced.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Expense'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeEnhanced.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).deleteExpense(widget.expense.id!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Expense deleted successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppThemeEnhanced.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppThemeEnhanced.getCategoryColor(_category);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppThemeEnhanced.radius2xl),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: AppThemeEnhanced.spaceMd,
                  ),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppThemeEnhanced.neutral300,
                    borderRadius: BorderRadius.circular(
                      AppThemeEnhanced.radiusXs,
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                    children: [
                      // Header with Category Color
                      SlideInAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          padding: const EdgeInsets.all(
                            AppThemeEnhanced.spaceLg,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppThemeEnhanced.getCategoryGradient(
                              _category,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppThemeEnhanced.radiusXl,
                            ),
                            boxShadow: AppThemeEnhanced.shadowMd,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  AppThemeEnhanced.spaceSm,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppThemeEnhanced.radiusMd,
                                  ),
                                ),
                                child: Icon(
                                  _getCategoryIcon(_category),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppThemeEnhanced.spaceMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Edit Expense',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(
                                      height: AppThemeEnhanced.spaceXs,
                                    ),
                                    Text(
                                      'Update your expense details',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  BounceAnimation(
                                    onTap: _deleteExpense,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppThemeEnhanced.spaceSm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          AppThemeEnhanced.radiusMd,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppThemeEnhanced.spaceSm,
                                  ),
                                  BounceAnimation(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppThemeEnhanced.spaceSm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          AppThemeEnhanced.radiusMd,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppThemeEnhanced.space2xl),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Input
                            SlideInAnimation(
                              delay: const Duration(milliseconds: 200),
                              child: EnhancedTextField(
                                label: 'Title',
                                hint: 'e.g., Grocery shopping',
                                prefixIcon: Icons.edit_outlined,
                                controller: _titleController,
                                validator: (v) => v?.isEmpty ?? true
                                    ? 'Please enter a title'
                                    : null,
                              ),
                            ),

                            const SizedBox(height: AppThemeEnhanced.spaceLg),

                            // Amount Input
                            SlideInAnimation(
                              delay: const Duration(milliseconds: 300),
                              child: EnhancedTextField(
                                label: 'Amount',
                                hint: '0.00',
                                prefixIcon: Icons.attach_money,
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (v) {
                                  if (v?.isEmpty ?? true)
                                    return 'Please enter an amount';
                                  if (double.tryParse(v!) == null)
                                    return 'Please enter a valid number';
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: AppThemeEnhanced.spaceLg),

                            // Date Selection
                            SlideInAnimation(
                              delay: const Duration(milliseconds: 400),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: AppThemeEnhanced.spaceSm,
                                  ),
                                  BounceAnimation(
                                    onTap: _selectDate,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppThemeEnhanced.spaceMd,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(
                                          AppThemeEnhanced.radiusLg,
                                        ),
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).dividerColor.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: categoryColor,
                                          ),
                                          const SizedBox(
                                            width: AppThemeEnhanced.spaceMd,
                                          ),
                                          Text(
                                            DateFormat(
                                              'EEEE, MMM dd, yyyy',
                                            ).format(_selectedDate),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppThemeEnhanced.spaceLg),

                            // Category Selection
                            SlideInAnimation(
                              delay: const Duration(milliseconds: 500),
                              child: EnhancedCategorySelector(
                                selectedCategory: _category,
                                onCategorySelected: (category) {
                                  setState(() => _category = category);
                                },
                                categories: _categories,
                              ),
                            ),

                            const SizedBox(height: AppThemeEnhanced.spaceLg),

                            // Note Input (Optional)
                            SlideInAnimation(
                              delay: const Duration(milliseconds: 600),
                              child: EnhancedTextField(
                                label: 'Note (Optional)',
                                hint: 'Add a note...',
                                prefixIcon: Icons.note_outlined,
                                controller: _noteController,
                                maxLines: 3,
                              ),
                            ),

                            const SizedBox(height: AppThemeEnhanced.space2xl),

                            // Action Buttons
                            SlideInAnimation(
                              delay: const Duration(milliseconds: 700),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: BounceAnimation(
                                      onTap: _deleteExpense,
                                      child: Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppThemeEnhanced.error
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            AppThemeEnhanced.radiusLg,
                                          ),
                                          border: Border.all(
                                            color: AppThemeEnhanced.error,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: AppThemeEnhanced.error,
                                              ),
                                              const SizedBox(
                                                width: AppThemeEnhanced.spaceSm,
                                              ),
                                              Text(
                                                'Delete',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: AppThemeEnhanced
                                                          .error,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppThemeEnhanced.spaceMd,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: BounceAnimation(
                                      onTap: _saveExpense,
                                      child: Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient:
                                              AppThemeEnhanced.getCategoryGradient(
                                                _category,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            AppThemeEnhanced.radiusLg,
                                          ),
                                          boxShadow: AppThemeEnhanced.shadowMd,
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.check_circle_outline,
                                                size: 24,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(
                                                width: AppThemeEnhanced.spaceSm,
                                              ),
                                              Text(
                                                'Update Expense',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
