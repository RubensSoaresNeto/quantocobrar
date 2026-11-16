import 'package:flutter/material.dart';

import '../models/budget.dart';
import '../services/local_storage.dart';
import '../utils/formatters.dart';
import 'budget_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Budget>> _history;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _history = LocalStorage().loadHistory();

  Future<void> _delete(int index) async {
    await LocalStorage().deleteBudget(index);
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Histórico')),
    body: FutureBuilder<List<Budget>>(
      future: _history,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final budgets = snapshot.data!;
        if (budgets.isEmpty) {
          return const Center(child: Text('Nenhum orçamento salvo ainda.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: budgets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final budget = budgets[index];
            return Card(
              child: ListTile(
                title: Text(
                  budget.clientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  budget.serviceDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt_long_outlined),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatCurrency(budget.suggestedPrice)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(index),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BudgetResultScreen(
                      budget: budget,
                      saveToHistory: false,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
