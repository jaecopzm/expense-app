import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/income.dart';
import '../providers/income_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Salary';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Salary', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'Freelance', 'icon': Icons.work_rounded},
    {'name': 'Business', 'icon': Icons.business_rounded},
    {'name': 'Investment', 'icon': Icons.trending_up_rounded},
    {'name': 'Gift', 'icon': Icons.card_giftcard_rounded},
    {'name': 'Bonus', 'icon': Icons.stars_rounded},
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
      
      await Provider.of<IncomeProvider>(context, listen: false).addIncome(income);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Income added successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Income',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Track your earnings',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Title',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: 'e.g., Monthly salary',
                                prefixIcon: const Icon(Icons.edit_outlined),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              ),
                              validator: (v) => v?.isEmpty ?? true ? 'Please enter a title' : null,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            Text(
                              'Amount',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                hintText: '0.00',
                                prefixIcon: const Icon(Icons.attach_money),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Please enter an amount';
                                if (double.tryParse(v!) == null) return 'Please enter a valid number';
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Wrap(
                              spacing: 8,
                              children: _quickAmounts.map((amount) {
                                return FilterChip(
                                  label: Text('\$$amount'),
                                  onSelected: (_) => _setQuickAmount(amount),
                                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                  selectedColor: Colors.green.withOpacity(0.2),
                                  checkmarkColor: Colors.green,
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _categories.map((cat) {
                                final isSelected = _category == cat['name'];
                                final categoryColor = Colors.green;
                                
                                return GestureDetector(
                                  onTap: () => setState(() => _category = cat['name']),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? categoryColor.withOpacity(0.15)
                                          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? categoryColor : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          cat['icon'],
                                          color: isSelected ? categoryColor : Theme.of(context).iconTheme.color,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          cat['name'],
                                          style: TextStyle(
                                            color: isSelected ? categoryColor : null,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            Text(
                              'Note (Optional)',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                hintText: 'Add a note...',
                                prefixIcon: const Icon(Icons.note_outlined),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              ),
                              maxLines: 3,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _saveIncome,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add Income',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
