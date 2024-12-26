import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chioneapp/models/goal.dart';
import 'package:chioneapp/viewmodels/goal_view_model.dart';
import '../viewmodels/transaction_view_model.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({Key? key, required this.goal}) : super(key: key);

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
  if (widget.goal.id != null) {
    context.read<TransactionViewModel>().fetchGoalTransactions(widget.goal.id!);
  }
});
  }

  Future<void> _deleteGoal() async {
    final goalViewModel = context.read<GoalViewModel>();
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Goal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to delete this goal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.goal.id != null) {
      await goalViewModel.deleteGoal(widget.goal.id!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionViewModel = context.watch<TransactionViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8DEF8),
      appBar: AppBar(
        title: Text(
          widget.goal.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF21005D),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _deleteGoal,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGoalSummary(),
          const SizedBox(height: 16),
          Expanded(
            child: transactionViewModel.isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6750A4)),
            )
                : _buildTransactionList(transactionViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSummary() {
    //calculate progress
    final progress = context.watch<GoalViewModel>().goals.firstWhere((goal) => goal.id == widget.goal.id).currentAmount / widget.goal.amount;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Goal Amount", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    "S/ ${widget.goal.amount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF21005D)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Saved", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    "S/ ${widget.goal.currentAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6750A4)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF6750A4).withOpacity(0.1),
              color: progress >= 1 ? Colors.green : const Color(0xFF6750A4),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${(progress * 100).toStringAsFixed(1)}% completed",
            style: TextStyle(
              fontSize: 14,
              color: progress >= 1 ? Colors.green : const Color(0xFF6750A4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(TransactionViewModel transactionViewModel) {
    if (transactionViewModel.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: const Color(0xFF6750A4).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              "No contributions yet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF21005D)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactionViewModel.transactions.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final transaction = transactionViewModel.transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6750A4).withOpacity(0.1),
              child: Icon(
                Icons.monetization_on_outlined,
                color: const Color(0xFF6750A4),
              ),
            ),
            title: Text(
              transaction['description'] ?? 'No description',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF21005D)),
            ),
            subtitle: Text(
              "S/ ${transaction['amount'].toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            trailing: Text(
              transaction['date'].toString().split('T')[0],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
