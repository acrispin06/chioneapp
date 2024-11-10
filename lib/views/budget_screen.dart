import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';
import '../viewmodels/budget_view_model.dart';

class BudgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final budgetViewModel = Provider.of<BudgetViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text("Budgets", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Acción al presionar el botón de notificación
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance and Expense Section
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Total Balance",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        "S/ ${transactionViewModel.totalBalance.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Balance", style: TextStyle(fontSize: 14)),
                            Text(
                              "S/ ${transactionViewModel.totalBalance.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Expense", style: TextStyle(fontSize: 14)),
                            Text(
                              "- S/ ${transactionViewModel.totalExpense.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: transactionViewModel.totalExpense / transactionViewModel.goal,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "S/ ${transactionViewModel.goal.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${((transactionViewModel.totalExpense / transactionViewModel.goal) * 100).toStringAsFixed(1)}% Of Your Expenses, Looks Good.",
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Income and Expense Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(
                  context,
                  "Income",
                  "S/ ${transactionViewModel.totalIncome.toStringAsFixed(2)}",
                  Icons.arrow_downward,
                  Colors.green,
                ),
                _buildSummaryCard(
                  context,
                  "Expense",
                  "S/ ${transactionViewModel.totalExpense.toStringAsFixed(2)}",
                  Icons.arrow_upward,
                  Colors.red,
                ),
              ],
            ),
            SizedBox(height: 16),
            // Budgets Section Title
            Text(
              "Budgets",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 8),
            // Budgets List
            Expanded(
              child: ListView.builder(
                itemCount: budgetViewModel.budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgetViewModel.budgets[index];
                  // Obtén el nombre de la categoría directamente
                  final categoryName = transactionViewModel.getCategoryName(budget.categoryId);

                  return ListTile(
                    leading: Icon(Icons.category, color: Colors.blue),
                    title: Text(categoryName), // Muestra el nombre de la categoría aquí
                    subtitle: Text("Limit: S/ ${budget.amount}"),
                    trailing: Text(
                      "Spent: S/ ${budget.spent}",
                      style: TextStyle(
                        color: budget.spent > budget.amount ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, String amount, IconData icon, Color color) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
