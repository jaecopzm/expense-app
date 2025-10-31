import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/income.dart';
import '../providers/income_provider.dart';
import '../theme/app_theme_enhanced.dart';
import '../widgets/enhanced_inputs.dart';
import '../widgets/animated_widgets.dart';

class EnhancedAddIncomeScreen extends StatefulWidget {
  const EnhancedAddIncomeScreen({super.key});

  @override
  State<EnhancedAddIncomeScreen> createState() =>
      _EnhancedAddIncomeScreenState();
}

class _EnhancedAddIncomeScreenState extends State<EnhancedAddIncomeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Salary';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Salary', 'icon': Icons.work_rounded},
    {'name': 'Freelance', 'icon': Icons.laptop_rounded},
    {'name': 'Investment', 'icon': Icons.trending_up_rounded},
    {'name': 'Business', 'icon': Icons.business_rounded},
    {'name': 'Gift', 'icon': Icons.card_giftcard_rounded},
    {'name': 'Bonus', 'icon': Icons.star_rounded},
    {'name': 'Rental', 'icon': Icons.home_rounded},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  final List<double> _quickAmounts = [500, 1000, 2000, 5000, 10000];

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

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final income = Income(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _category,
        date: DateTime.now(),
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      await Provider.of<IncomeProvider>(
        context,
        listen: false,
      ).addIncome(income);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Income added successfully!'),
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
                                  'Add Income',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                ),
                                const SizedBox(
                                  height: AppThemeEnhanced.spaceXs,
                                ),
                                Text(
                                  'Track your earnings',
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
                                  ).colorScheme.surfaceVariant,
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
                                hint: 'e.g., Monthly salary',
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
                                onTap: _saveIncome,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: AppThemeEnhanced.successGradient,
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
                                          'Add Income',
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
    );
  }
}
