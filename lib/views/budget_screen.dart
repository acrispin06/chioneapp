import 'package:chioneapp/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/budget_view_model.dart';
import '../viewmodels/transaction_view_model.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetViewModel = context.read<BudgetViewModel>();
      budgetViewModel.fetchBudgets(1); // Pass the userId here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
        backgroundColor: Colors.green,
      ),
      body: Consumer2<BudgetViewModel, TransactionViewModel>(
        builder: (context, budgetViewModel, transactionViewModel, child) {
          if (budgetViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetViewModel.budgets.isEmpty) {
            return const Center(
              child: Text(
                "No budgets available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final budgets = budgetViewModel.budgets;

          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final Budget budget = budgets[index] as Budget;

              return FutureBuilder<String>(
                future: transactionViewModel.getCategoryName(budget.categoryId).then((value) => value as String),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Loading..."),
                    );
                  }

                  if (snapshot.hasError) {
                    return const ListTile(
                      title: Text("Error loading category"),
                    );
                  }

                  final categoryName = snapshot.data ?? "Unknown Category";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.attach_money, color: Colors.green),
                      ),
                      title: Text(categoryName),
                      subtitle: Text("Budget: S/ ${budget.amount.toStringAsFixed(2)}"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}