import 'package:chioneapp/views/edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Map<String, dynamic>? _transaction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransaction();
    });
  }

  Future<void> _loadTransaction() async {
    final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
    try {
      final transaction = await viewModel.fetchTransactionById(widget.transactionId);
      if (mounted) {
        setState(() {
          _transaction = transaction;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load transaction")),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_transaction == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Transaction Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.category, color: Colors.green),
              title: const Text("Category"),
              subtitle: Text(_transaction!['category_name'] ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.green),
              title: const Text("Amount"),
              subtitle: Text("S/ ${_transaction!['amount'] ?? 0.0}"),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.green),
              title: const Text("Description"),
              subtitle: Text(_transaction!['description'] ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.green),
              title: const Text("Date & Time"),
              subtitle: Text(
                "${_transaction!['date']?.toString().split('T')[0] ?? 'N/A'} - ${_transaction!['time'] ?? 'N/A'}",
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showEditTransaction(context, _transaction!),
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  label: const Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteTransaction(context, _transaction!),
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  label: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransaction(BuildContext context, Map<String, dynamic> transaction) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditTransactionScreen(transaction: transaction),
    ));
  }

  void _deleteTransaction(BuildContext context, Map<String, dynamic> transaction) async {
    final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
    bool confirm = await _showConfirmationDialog(context);
    if (confirm) {
      await viewModel.deleteTransaction(transaction['id'], transaction['type_id']);
      Navigator.of(context).pop(); // Regresa a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction deleted successfully")),
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Delete")),
        ],
      ),
    );
  }
}