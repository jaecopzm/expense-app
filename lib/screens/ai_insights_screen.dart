import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_insights_service.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/premium_provider.dart';

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    
    if (!premium.canAccessAIInsights()) {
      return _buildPremiumRequired(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<List<AIInsight>>(
        future: _generateInsights(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          return _buildInsightsList(snapshot.data!);
        },
      ),
    );
  }

  Future<List<AIInsight>> _generateInsights(BuildContext context) async {
    final expenseProvider = context.read<ExpenseProvider>();
    final incomeProvider = context.read<IncomeProvider>();
    await expenseProvider.fetchExpenses();
    await incomeProvider.fetchIncomes();
    return AIInsightsService().generateInsights(expenseProvider.expenses, incomeProvider.incomes);
  }

  Widget _buildInsightsList(List<AIInsight> insights) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final insight = insights[index];
        return _buildInsightCard(insight);
      },
    );
  }

  Widget _buildInsightCard(AIInsight insight) {
    Color color;
    Color bgColor;
    
    switch (insight.type) {
      case InsightType.success:
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case InsightType.warning:
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case InsightType.alert:
        color = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      case InsightType.tip:
        color = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case InsightType.info:
        color = Colors.grey;
        bgColor = Colors.grey.shade50;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(insight.icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (insight.actionable)
                  Icon(Icons.arrow_forward_ios, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight.description,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Insights Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add more expenses to get AI insights',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumRequired(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              const Text(
                'Premium Feature',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Get personalized AI insights about your spending patterns, savings opportunities, and financial health.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/subscription'),
                child: const Text('Upgrade to Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About AI Insights'),
        content: const Text(
          'AI Insights analyzes your spending patterns, income, and financial behavior to provide personalized recommendations. '
          'Insights are updated in real-time as you add new transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
