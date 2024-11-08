import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';
import '../viewmodels/budget_view_model.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

class BudgetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final budgetViewModel = Provider.of<BudgetViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text("Account Balance", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                        "S/ 7,783.00",
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
                              "S/ 7,783.00",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Expense", style: TextStyle(fontSize: 14)),
                            Text(
                              "- S/ 1,187.40",
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
                            value: 0.3,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text("S/ 20,000.00", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text("30% Of Your Expenses, Looks Good."),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Income and Expense Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(context, "Income", "S/ 4,000.00", Icons.arrow_downward, Colors.green),
                _buildSummaryCard(context, "Expense", "S/ 1,187.40", Icons.arrow_upward, Colors.red),
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
                  return ListTile(
                    leading: Icon(Icons.category, color: Colors.blue),
                    title: Text(budget.category),
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

  Widget _buildTransactionTile(BuildContext context, Transaction transaction) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              transaction.type == "income" ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.type == "income" ? Colors.green : Colors.red,
            ),
          ),
          title: Text(transaction.category),
          subtitle: Text("${transaction.date.toString()} - ${transaction.type}"),
          trailing: Text(
            "S/ ${transaction.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: transaction.type == "income" ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}