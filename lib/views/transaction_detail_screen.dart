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
        const SnackBar(
          content: Text("Failed to load transaction"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_transaction == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final isIncome = _transaction!['type_id'] == 1;
    final amount = _transaction!['amount'] ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Colors.black87,
            onPressed: () => _showEditTransaction(context, _transaction!),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.redAccent,
            onPressed: () => _deleteTransaction(context, _transaction!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountSection(isIncome, amount),
            const SizedBox(height: 24),
            _buildDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection(bool isIncome, double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isIncome ? 'Income' : 'Expense',
            style: TextStyle(
              fontSize: 16,
              color: isIncome ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? Colors.green[700] : Colors.red[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'S/ ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          _buildDetailTile(
            icon: Icons.category_outlined,
            title: "Category",
            value: _transaction!['category_name'] ?? 'N/A',
          ),
          _buildDetailTile(
            icon: Icons.description_outlined,
            title: "Description",
            value: _transaction!['description'] ?? 'N/A',
          ),
          _buildDetailTile(
            icon: Icons.calendar_today_outlined,
            title: "Date",
            value: _transaction!['date']?.toString().split('T')[0] ?? 'N/A',
          ),
          _buildDetailTile(
            icon: Icons.access_time_outlined,
            title: "Time",
            value: _transaction!['time'] ?? 'N/A',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.grey[200],
          ),
      ],
    );
  }

  void _showEditTransaction(BuildContext context, Map<String, dynamic> transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _deleteTransaction(BuildContext context, Map<String, dynamic> transaction) async {
    final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
    bool confirm = await _showConfirmationDialog(context);
    if (confirm) {
      await viewModel.deleteTransaction(transaction['id'], transaction['type_id']);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction deleted successfully"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Confirm Deletion",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this transaction?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}