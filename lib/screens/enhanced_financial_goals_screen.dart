import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/financial_goals_provider.dart';
import '../providers/premium_provider.dart';
import '../theme/app_theme_enhanced.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/enhanced_inputs.dart';

class EnhancedFinancialGoalsScreen extends StatefulWidget {
  const EnhancedFinancialGoalsScreen({super.key});

  @override
  State<EnhancedFinancialGoalsScreen> createState() => _EnhancedFinancialGoalsScreenState();
}

class _EnhancedFinancialGoalsScreenState extends State<EnhancedFinancialGoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinancialGoalsProvider>(context, listen: false).loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<PremiumProvider, FinancialGoalsProvider>(
          builder: (context, premiumProvider, goalsProvider, _) {
            // Premium check removed for development
            final goals = goalsProvider.goals;

            return CustomScrollView(
              slivers: [
                // Enhanced Header
                SliverToBoxAdapter(
                  child: SlideInAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                      decoration: BoxDecoration(
                        gradient: AppThemeEnhanced.primaryGradient,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(AppThemeEnhanced.radius2xl),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppThemeEnhanced.spaceSm),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
                                ),
                                child: const Icon(
                                  Icons.flag,
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
                                      'Financial Goals 🎯',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${goals.length} active goals',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Goals List or Empty State
                goals.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: SlideInAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: Padding(
                              padding: const EdgeInsets.all(AppThemeEnhanced.space2xl),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppThemeEnhanced.space2xl),
                                    decoration: BoxDecoration(
                                      color: AppThemeEnhanced.primaryLight.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.flag_outlined,
                                      size: 80,
                                      color: AppThemeEnhanced.primaryLight.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: AppThemeEnhanced.spaceLg),
                                  Text(
                                    'No goals yet',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppThemeEnhanced.spaceSm),
                                  Text(
                                    'Set your first financial goal\nand start achieving your dreams',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return SlideInAnimation(
                                delay: Duration(milliseconds: 200 + (index * 100)),
                                child: _buildGoalCard(goals[index], goalsProvider),
                              );
                            },
                            childCount: goals.length,
                          ),
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, _) {
          // Premium check removed for development
          return SlideInAnimation(
            delay: const Duration(milliseconds: 300),
            child: FloatingActionButton.extended(
              onPressed: _showAddGoalDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Goal'),
              backgroundColor: AppThemeEnhanced.primaryLight,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalCard(FinancialGoal goal, FinancialGoalsProvider provider) {
    final progress = goal.currentAmount / goal.targetAmount;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isCompleted = progress >= 1.0;

    return BounceAnimation(
      onTap: () => _showGoalDetails(goal, provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppThemeEnhanced.spaceMd),
        padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXl),
          border: Border.all(
            color: isCompleted
                ? AppThemeEnhanced.success
                : Theme.of(context).dividerColor.withOpacity(0.2),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: AppThemeEnhanced.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppThemeEnhanced.spaceSm),
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? AppThemeEnhanced.successGradient
                        : AppThemeEnhanced.primaryGradient,
                    borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
                  ),
                  child: Icon(
                    goal.icon,
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
                        goal.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        goal.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppThemeEnhanced.spaceSm,
                      vertical: AppThemeEnhanced.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeEnhanced.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppThemeEnhanced.success,
                        ),
                        SizedBox(width: AppThemeEnhanced.spaceXs),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: AppThemeEnhanced.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppThemeEnhanced.spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    AnimatedCounter(
                      value: goal.currentAmount,
                      prefix: '\$',
                      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppThemeEnhanced.primaryLight,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '\$${goal.targetAmount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppThemeEnhanced.spaceMd),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusFull),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? AppThemeEnhanced.success : AppThemeEnhanced.primaryLight,
                ),
              ),
            ),
            const SizedBox(height: AppThemeEnhanced.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% Complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppThemeEnhanced.success : AppThemeEnhanced.primaryLight,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: AppThemeEnhanced.spaceXs),
                    Text(
                      daysLeft > 0 ? '$daysLeft days left' : 'Overdue',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: daysLeft > 0
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                            : AppThemeEnhanced.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    String selectedCategory = 'Savings';
    IconData selectedIcon = Icons.savings;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppThemeEnhanced.radius2xl),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppThemeEnhanced.spaceMd),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppThemeEnhanced.neutral300,
                        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXs),
                      ),
                    ),
                  ),
                  Text(
                    'New Financial Goal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceLg),
                  EnhancedTextField(
                    label: 'Goal Name',
                    hint: 'e.g., Emergency Fund',
                    prefixIcon: Icons.edit_outlined,
                    controller: nameController,
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceLg),
                  EnhancedTextField(
                    label: 'Target Amount',
                    hint: '0.00',
                    prefixIcon: Icons.attach_money,
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceLg),
                  Text(
                    'Target Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.spaceSm),
                  BounceAnimation(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppThemeEnhanced.spaceMd),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppThemeEnhanced.primaryLight,
                          ),
                          const SizedBox(width: AppThemeEnhanced.spaceMd),
                          Text(
                            DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppThemeEnhanced.space2xl),
                  Row(
                    children: [
                      Expanded(
                        child: BounceAnimation(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppThemeEnhanced.spaceMd),
                      Expanded(
                        flex: 2,
                        child: BounceAnimation(
                          onTap: () {
                            if (nameController.text.isNotEmpty &&
                                amountController.text.isNotEmpty) {
                              final goal = FinancialGoal(
                                id: DateTime.now().toString(),
                                name: nameController.text,
                                targetAmount: double.parse(amountController.text),
                                targetDate: selectedDate,
                                category: selectedCategory,
                                icon: selectedIcon,
                              );
                              Provider.of<FinancialGoalsProvider>(
                                context,
                                listen: false,
                              ).addGoal(goal);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Goal added successfully!'),
                                    ],
                                  ),
                                  backgroundColor: AppThemeEnhanced.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppThemeEnhanced.primaryGradient,
                              borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
                              boxShadow: AppThemeEnhanced.shadowMd,
                            ),
                            child: Center(
                              child: Text(
                                'Add Goal',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGoalDetails(FinancialGoal goal, FinancialGoalsProvider provider) {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppThemeEnhanced.radius2xl),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppThemeEnhanced.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: AppThemeEnhanced.spaceMd),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppThemeEnhanced.neutral300,
                  borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusXs),
                ),
              ),
              Text(
                goal.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppThemeEnhanced.spaceLg),
              EnhancedTextField(
                label: 'Add Progress',
                hint: '0.00',
                prefixIcon: Icons.add_circle_outline,
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: AppThemeEnhanced.spaceLg),
              Row(
                children: [
                  Expanded(
                    child: BounceAnimation(
                      onTap: () async {
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
                                Text('Delete Goal'),
                              ],
                            ),
                            content: const Text('Are you sure you want to delete this goal?'),
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
                        if (confirmed == true && context.mounted) {
                          provider.deleteGoal(goal.id);
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppThemeEnhanced.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
                          border: Border.all(color: AppThemeEnhanced.error),
                        ),
                        child: Center(
                          child: Text(
                            'Delete',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppThemeEnhanced.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppThemeEnhanced.spaceMd),
                  Expanded(
                    flex: 2,
                    child: BounceAnimation(
                      onTap: () {
                        if (amountController.text.isNotEmpty) {
                          final amount = double.parse(amountController.text);
                          provider.updateGoalProgress(goal.id, goal.currentAmount + amount);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Progress updated!'),
                                ],
                              ),
                              backgroundColor: AppThemeEnhanced.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusMd),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppThemeEnhanced.successGradient,
                          borderRadius: BorderRadius.circular(AppThemeEnhanced.radiusLg),
                          boxShadow: AppThemeEnhanced.shadowMd,
                        ),
                        child: Center(
                          child: Text(
                            'Update Progress',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}