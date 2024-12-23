import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../viewmodels/budget_view_model.dart';
import '../viewmodels/transaction_view_model.dart';

class BudgetDetailScreen extends StatefulWidget {
  final Budget budget;

  const BudgetDetailScreen({Key? key, required this.budget}) : super(key: key);

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final viewModel = context.read<BudgetViewModel>();
    await viewModel.loadCategoryTransactions(widget.budget.categoryId);
    await viewModel.updateBudgetProgress(widget.budget);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: FutureBuilder<String>(
          future: context.read<BudgetViewModel>().getCategoryName(widget.budget.categoryId),
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
      body: Consumer<BudgetViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildBudgetSummary(context),
              const Divider(),
              Expanded(
                child: _buildTransactionList(viewModel.categoryTransactions),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editBudget(context),
        backgroundColor: primaryColor,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildBudgetSummary(BuildContext context) {
    final double remaining = widget.budget.amount - widget.budget.spent;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryTile("Total Budget", widget.budget.amount, Colors.blue),
            const SizedBox(height: 8),
            _buildSummaryTile("Total Spent", widget.budget.spent, Colors.red),
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

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          "No transactions for this category",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isExpense = transaction['type_id'] == 2;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                transaction['icon_path'],
                width: 24,
                height: 24,
              ),
            ),
            title: Text(transaction['description']),
            subtitle: Text("${transaction['date']?.toString().split('T')[0] ?? 'N/A'} - ${transaction['time']}"),
            trailing: Text(
              "S/ ${transaction['amount'].toStringAsFixed(2)}",
              style: TextStyle(
                color: isExpense ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _editBudget(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _amountController = TextEditingController(text: widget.budget.amount.toStringAsFixed(2));

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
                          final updatedBudget = widget.budget.copyWith(amount: newAmount);
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
                context.read<BudgetViewModel>().deleteBudget(widget.budget.id!, widget.budget.userId);
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
