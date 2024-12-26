import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chioneapp/models/goal.dart';
import '../viewmodels/goal_view_model.dart';
import '../viewmodels/transaction_view_model.dart';
import 'goal_detail_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalViewModel>().fetchGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8DEF8),
      appBar: AppBar(
        title: const Text(
          "My Goals",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF21005D),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<GoalViewModel>(
        builder: (context, goalViewModel, _) {
          if (goalViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6750A4),
              ),
            );
          }

          if (goalViewModel.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: const Color(0xFF6750A4).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Let's start creating goals!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF21005D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap the + button to add a new goal",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: goalViewModel.goals.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final goal = goalViewModel.goals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalDetailScreen(goal: goal),
                    ),
                  );
                },
                child: _buildGoalCard(goal as Goal),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        heroTag: 'addGoalButton',
        backgroundColor: const Color(0xFF6750A4),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final double progress = (goal.currentAmount / goal.amount).clamp(0, 1);
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6750A4).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF21005D),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6750A4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$daysLeft days",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6750A4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Goal",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "S/ ${goal.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF21005D),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Saved",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "S/ ${goal.currentAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: progress >= 1
                              ? Colors.green
                              : const Color(0xFF6750A4),
                        ),
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
        ),
      ),
    );
  }

  Future<void> _showAddGoalDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _amountController = TextEditingController();
    DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
    int? _selectedCategoryId;

    final goalViewModel = context.read<GoalViewModel>();
    final transactionViewmodel = context.read<TransactionViewModel>();

    // Cargar categorías antes de mostrar el diálogo
    await transactionViewmodel.fetchCategoriesByType(1);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Create a New Goal",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF21005D),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo para el nombre del objetivo
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Goal Name",
                          labelStyle: const TextStyle(color: Color(0xFF6750A4)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6750A4)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF6750A4).withOpacity(0.5),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a valid goal name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo para la cantidad del objetivo
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Amount",
                          prefixText: "S/ ",
                          labelStyle: const TextStyle(color: Color(0xFF6750A4)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6750A4)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF6750A4).withOpacity(0.5),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || double.tryParse(value) == null) {
                            return "Please enter a valid amount";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Selector de categoría
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: "Category",
                          labelStyle: const TextStyle(color: Color(0xFF6750A4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF6750A4).withOpacity(0.5),
                            ),
                          ),
                        ),
                        items: transactionViewmodel.categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'],
                            child: Text(category['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategoryId = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please select a category";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Selector de fecha
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF6750A4),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF6750A4).withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF6750A4),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Target Date",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "${_selectedDate.toLocal()}".split(' ')[0],
                                    style: const TextStyle(
                                      color: Color(0xFF21005D),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final newGoal = Goal(
                            userId: 1,
                            name: _nameController.text,
                            amount: double.parse(_amountController.text),
                            targetDate: _selectedDate,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );
                          context.read<GoalViewModel>().addGoalWithCategory(newGoal, _selectedCategoryId!);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6750A4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
}
