import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../services/template_service.dart';
import '../theme/app_theme_enhanced.dart';
import '../widgets/enhanced_inputs.dart';
import '../widgets/animated_widgets.dart';
import '../utils/custom_snackbar.dart';

class EnhancedAddExpenseScreen extends StatefulWidget {
  final ExpenseTemplate? template;
  
  const EnhancedAddExpenseScreen({super.key, this.template});

  @override
  State<EnhancedAddExpenseScreen> createState() =>
      _EnhancedAddExpenseScreenState();
}

class _EnhancedAddExpenseScreenState extends State<EnhancedAddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Food';
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

  final List<double> _quickAmounts = [10, 25, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
    
    // Initialize with template data if provided
    if (widget.template != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _titleController.text = widget.template!.title;
          _amountController.text = widget.template!.amount.toString();
          _category = widget.template!.category;
          if (widget.template!.notes != null) {
            _noteController.text = widget.template!.notes!;
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _setQuickAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _category,
        date: DateTime.now(),
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).addExpense(expense);

      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: 'Expense added successfully!',
          type: SnackbarType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      // Header
                      SlideInAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Expense',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                ),
                                const SizedBox(
                                  height: AppThemeEnhanced.spaceXs,
                                ),
                                Text(
                                  'Track your spending',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                ),
                              ],
                            ),
                            BounceAnimation(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppThemeEnhanced.spaceSm,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    AppThemeEnhanced.radiusMd,
                                  ),
                                ),
                                child: const Icon(Icons.close),
                              ),
                            ),
                          ],
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
                                  if (v?.isEmpty ?? true) {
                                    return 'Please enter an amount';
                                  }
                                  if (double.tryParse(v!) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: AppThemeEnhanced.spaceLg),

                            // Quick Amount Buttons
                            SlideInAnimation(
                              delay: const Duration(milliseconds: 400),
                              child: EnhancedQuickAmountSelector(
                                amounts: _quickAmounts,
                                onAmountSelected: _setQuickAmount,
                                selectedAmount: _amountController.text,
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

                            // Save Button
                            SlideInAnimation(
                              delay: const Duration(milliseconds: 700),
                              child: BounceAnimation(
                                onTap: _saveExpense,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: AppThemeEnhanced.primaryGradient,
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
                                          'Add Expense',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
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
          );
        },
      ),
    ),
    );
  }
}
