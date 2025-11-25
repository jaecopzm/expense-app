import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ParsedReceipt> scanReceipt(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    return _parseReceiptText(recognizedText.text);
  }

  ParsedReceipt _parseReceiptText(String text) {
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    String? merchant;
    double? amount;
    DateTime? date;
    String category = 'Shopping';
    List<ReceiptItem> items = [];

    // Extract merchant (usually first few lines)
    if (lines.isNotEmpty) {
      merchant = lines.first;
    }

    // Extract date
    final datePattern = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})');
    for (var line in lines) {
      final match = datePattern.firstMatch(line);
      if (match != null) {
        date = _parseDate(match.group(0)!);
        break;
      }
    }

    // Extract total amount
    final amountPatterns = [
      RegExp(r'total[:\s]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'amount[:\s]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'\$(\d+\.\d{2})\s*$'),
    ];

    for (var pattern in amountPatterns) {
      for (var line in lines.reversed) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          amount = double.tryParse(match.group(1)!);
          if (amount != null && amount > 0) break;
        }
      }
      if (amount != null) break;
    }

    // Extract line items
    final itemPattern = RegExp(r'(.+?)\s+\$?(\d+\.?\d*)');
    for (var line in lines) {
      final match = itemPattern.firstMatch(line);
      if (match != null) {
        final itemName = match.group(1)?.trim();
        final itemPrice = double.tryParse(match.group(2)!);
        if (itemName != null && itemPrice != null && itemPrice > 0 && itemPrice < (amount ?? 999999)) {
          items.add(ReceiptItem(name: itemName, price: itemPrice));
        }
      }
    }

    // Smart category detection
    category = _detectCategory(merchant ?? '', items);

    return ParsedReceipt(
      merchant: merchant ?? 'Unknown Merchant',
      amount: amount ?? 0.0,
      date: date ?? DateTime.now(),
      category: category,
      items: items,
      rawText: text,
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split(RegExp(r'[/-]'));
      if (parts.length == 3) {
        int year = int.parse(parts[2]);
        if (year < 100) year += 2000;
        return DateTime(year, int.parse(parts[0]), int.parse(parts[1]));
      }
    } catch (e) {
      // Ignore parse errors
    }
    return DateTime.now();
  }

  String _detectCategory(String merchant, List<ReceiptItem> items) {
    final text = '$merchant ${items.map((e) => e.name).join(' ')}'.toLowerCase();
    
    if (text.contains('restaurant') || text.contains('cafe') || text.contains('food')) return 'Food';
    if (text.contains('gas') || text.contains('fuel') || text.contains('shell') || text.contains('exxon')) return 'Transportation';
    if (text.contains('grocery') || text.contains('market') || text.contains('walmart')) return 'Groceries';
    if (text.contains('pharmacy') || text.contains('hospital') || text.contains('clinic')) return 'Healthcare';
    if (text.contains('hotel') || text.contains('airline') || text.contains('travel')) return 'Travel';
    
    return 'Shopping';
  }

  void dispose() {
    _textRecognizer.close();
  }
}

class ParsedReceipt {
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;
  final List<ReceiptItem> items;
  final String rawText;

  ParsedReceipt({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    required this.items,
    required this.rawText,
  });
}

class ReceiptItem {
  final String name;
  final double price;

  ReceiptItem({required this.name, required this.price});
}
