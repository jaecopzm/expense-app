import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/recurring_transaction.dart';
import '../providers/recurring_transaction_provider.dart';

class AddRecurringTransactionScreen extends StatefulWidget {
  const AddRecurringTransactionScreen({super.key});

  @override
  State<AddRecurringTransactionScreen> createState() => _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState extends State<AddRecurringTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  String _category = 'Food';
  RecurrenceType _recurrence = RecurrenceType.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Transport', 'icon': Icons.directions_car_rounded},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'Bills', 'icon': Icons.receipt_long_rounded},
    {'name': 'Entertainment', 'icon': Icons.movie_rounded},
    {'name': 'Health', 'icon': Icons.medical_services_rounded},
    {'name': 'Education', 'icon': Icons.school_rounded},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'Freelance', 'icon': Icons.work_rounded},
    {'name': 'Business', 'icon': Icons.business_rounded},
    {'name': 'Investment', 'icon': Icons.trending_up_rounded},
    {'name': 'Gift', 'icon': Icons.card_giftcard_rounded},
    {'name': 'Bonus', 'icon': Icons.stars_rounded},
    {'name': 'Rental', 'icon': Icons.home_rounded},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentCategories =>
      _type == TransactionType.expense ? _expenseCategories : _incomeCategories;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveRecurringTransaction() async {
    if (_formKey.currentState!.validate()) {
      final transaction = RecurringTransaction(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _category,
        type: _type,
        recurrence: _recurrence,
        startDate: _startDate,
        endDate: _endDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
      
      await Provider.of<RecurringTransactionProvider>(context, listen: false)
          .addRecurringTransaction(transaction);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Recurring transaction added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recurring Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Transaction Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  _category = _currentCategories[0]['name'];
                });
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Title',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., Monthly rent',
                prefixIcon: Icon(Icons.edit_outlined),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
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

            const SizedBox(height: 24),

            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _currentCategories.map((cat) {
                final isSelected = _category == cat['name'];
                final categoryColor = _type == TransactionType.income ? Colors.green : Colors.red;
                
                return GestureDetector(
                  onTap: () => setState(() => _category = cat['name']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? categoryColor.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
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
                          color: isSelected ? categoryColor : Colors.grey,
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
              'Recurrence',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RecurrenceType>(
              initialValue: _recurrence,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.loop),
                border: OutlineInputBorder(),
              ),
              items: RecurrenceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _recurrence = value);
                }
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Start Date',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
              trailing: const Icon(Icons.edit),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () => _selectDate(context, true),
            ),

            const SizedBox(height: 16),

            Text(
              'End Date (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(_endDate == null 
                  ? 'No end date' 
                  : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
              trailing: _endDate == null 
                  ? const Icon(Icons.add)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () => _selectDate(context, false),
            ),

            const SizedBox(height: 24),

            Text(
              'Note (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
                prefixIcon: Icon(Icons.note_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _saveRecurringTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == TransactionType.income ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Recurring Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
