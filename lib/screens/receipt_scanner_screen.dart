import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/receipt_scanner_service.dart';
import '../providers/expense_provider.dart';
import '../providers/premium_provider.dart';
import '../models/expense.dart';
import '../utils/custom_snackbar.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final _scanner = ReceiptScannerService();
  final _picker = ImagePicker();
  bool _isProcessing = false;
  ParsedReceipt? _parsedReceipt;
  File? _imageFile;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _scanReceipt(ImageSource source) async {
    final premium = context.read<PremiumProvider>();
    if (!premium.canAccessReceiptScanning()) {
      _showPremiumRequired();
      return;
    }

    final image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _isProcessing = true;
      _imageFile = File(image.path);
    });

    try {
      final result = await _scanner.scanReceipt(image.path);
      setState(() {
        _parsedReceipt = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Failed to scan receipt',
          type: SnackbarType.error,
        );
      }
    }
  }

  void _showPremiumRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text('Receipt scanning is a premium feature. Upgrade to unlock AI-powered receipt scanning.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (_parsedReceipt == null) return;

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch,
      amount: _parsedReceipt!.amount,
      category: _parsedReceipt!.category,
      title: _parsedReceipt!.merchant,
      date: _parsedReceipt!.date,
      receiptImage: _imageFile?.path,
    );

    await context.read<ExpenseProvider>().addExpense(expense);
    
    if (mounted) {
      Navigator.pop(context);
      CustomSnackbar.show(
        context,
        message: 'Expense saved successfully!',
        type: SnackbarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        actions: [
          if (_parsedReceipt != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveExpense,
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : _parsedReceipt == null
              ? _buildScanOptions()
              : _buildReceiptPreview(),
    );
  }

  Widget _buildScanOptions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'Scan Your Receipt',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'AI will extract amount, date, and items',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: () => _scanReceipt(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _scanReceipt(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 24),
          _buildInfoCard('Merchant', _parsedReceipt!.merchant, Icons.store),
          _buildInfoCard('Amount', '\$${_parsedReceipt!.amount.toStringAsFixed(2)}', Icons.attach_money),
          _buildInfoCard('Date', '${_parsedReceipt!.date.month}/${_parsedReceipt!.date.day}/${_parsedReceipt!.date.year}', Icons.calendar_today),
          _buildInfoCard('Category', _parsedReceipt!.category, Icons.category),
          
          if (_parsedReceipt!.items.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._parsedReceipt!.items.map((item) => ListTile(
              dense: true,
              title: Text(item.name),
              trailing: Text('\$${item.price.toStringAsFixed(2)}'),
            )),
          ],
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saveExpense,
              child: const Text('Save Expense'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() {
                _parsedReceipt = null;
                _imageFile = null;
              }),
              child: const Text('Scan Another'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
