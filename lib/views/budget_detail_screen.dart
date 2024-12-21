import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../viewmodels/budget_view_model.dart';
import '../viewmodels/transaction_view_model.dart';

class BudgetDetailScreen extends StatelessWidget {
  final Budget budget;

  const BudgetDetailScreen({Key? key, required this.budget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: FutureBuilder<String>(
          future: context.read<BudgetViewModel>().getCategoryName(budget.categoryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Text("Unknown Category");
            } else {
              return Text(
                "${snapshot.data} Budget",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBudgetSummary(context),
          const Divider(),
          _buildTransactionList(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editBudget(context),
        backgroundColor: primaryColor,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildBudgetSummary(BuildContext context) {
    final double remaining = budget.amount - budget.spent;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryTile("Total Budget", budget.amount, Colors.blue),
            const SizedBox(height: 8),
            _buildSummaryTile("Total Spent", budget.spent, Colors.red),
            const SizedBox(height: 8),
            _buildSummaryTile("Remaining", remaining, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String title, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "S/ ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    return Expanded(
      child: Consumer<TransactionViewModel>(
        builder: (context, transactionViewModel, _) {
          if (transactionViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = transactionViewModel.transactions
              .where((t) => t['budget_id'] == budget.id)
              .toList();

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                "No transactions associated with this budget",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.monetization_on,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(transaction['description'] ?? "No description"),
                  subtitle: Text("Amount: S/ ${transaction['amount'].toStringAsFixed(2)}"),
                  trailing: Text(transaction['date']),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editBudget(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _amountController = TextEditingController(text: budget.amount.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Budget",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an amount";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final newAmount = double.parse(_amountController.text);
                          final updatedBudget = budget.copyWith(amount: newAmount);
                          context.read<BudgetViewModel>().updateBudget(updatedBudget);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Budget"),
          content: const Text("Are you sure you want to delete this budget?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BudgetViewModel>().deleteBudget(budget.id!, budget.userId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
