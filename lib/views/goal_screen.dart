import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/goal_view_model.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Llama a fetchGoals después de la construcción inicial del widget
      final goalViewModel = context.read<GoalViewModel>();
      goalViewModel.fetchGoals(1); // Pasa el userId aquí
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Goals"),
        backgroundColor: Colors.green,
      ),
      body: Consumer<GoalViewModel>(
        builder: (context, goalViewModel, child) {
          final goals = goalViewModel.goals;

          if (goals.isEmpty) {
            return const Center(child: Text("No goals available"));
          }

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final name = goal['name'] ?? "Unnamed Goal";
              final amount = goal['amount'] ?? 0.0;
              final currentAmount = goal['currentAmount'] ?? 0.0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.flag, color: Colors.blue),
                ),
                title: Text(name),
                subtitle: Text(
                  "Target: S/ ${amount.toStringAsFixed(2)} | Saved: S/ ${currentAmount.toStringAsFixed(2)}",
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              );
            },
          );
        },
      ),
    );
  }
}
