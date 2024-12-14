import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionViewModel = Provider.of<TransactionViewModel>(context, listen: false);
      transactionViewModel.fetchAllTransactions();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        backgroundColor: Colors.green,
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, transactionViewModel, child) {
          if (transactionViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transactionViewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                transactionViewModel.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (transactionViewModel.transactions.isEmpty) {
            return const Center(
              child: Text(
                "No transactions available.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final transactions = transactionViewModel.transactions;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final type = transaction['type_id'] == 1 ? "income" : "expense";
              final description = transaction['description'] ?? 'No description';
              final date = transaction['date'] != null
                  ? DateTime.parse(transaction['date'])
                  : DateTime.now();
              final amount = transaction['amount'] ?? 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: type == "income"
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      transaction['type_id'] == 1 ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transaction['type_id'] == 1 ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${date.toLocal()}".split(' ')[0], // Display date in YYYY-MM-DD format
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    "S/ ${amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: type == "income" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
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
}
