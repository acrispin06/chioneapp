import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';
import '../models/transaction.dart';

class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);

    // Cargar transacciones solo una vez cuando se construye el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transactionViewModel.fetchTransactions();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text("Transaction", style: TextStyle(color: Colors.white)),
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
            // Total Balance Section
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Balance", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      "S/ ${transactionViewModel.totalBalance.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
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
            // Transaction List
            Expanded(
              child: Consumer<TransactionViewModel>(
                builder: (context, model, child) {
                  if (model.transactions.isEmpty) {
                    return Center(child: Text("No transactions available."));
                  }

                  return ListView.builder(
                    itemCount: model.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = model.transactions[index];
                      return _buildTransactionTile(context, transaction, model);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction transaction, TransactionViewModel transactionViewModel) {
    // Obtén el nombre de la categoría directamente del mapa en transactionViewModel
    final categoryName = transactionViewModel.getCategoryName(transaction.category);

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
          title: Text(categoryName), // Muestra el nombre de la categoría aquí
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