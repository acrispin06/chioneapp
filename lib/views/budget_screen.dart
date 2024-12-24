import 'package:chioneapp/models/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../viewmodels/budget_view_model.dart';
import '../viewmodels/transaction_view_model.dart';
import 'budget_detail_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetViewModel = context.read<BudgetViewModel>();
      budgetViewModel.fetchBudgets(1); // Fetch budgets for the userId
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          "Budgets",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<BudgetViewModel>(
        builder: (context, budgetViewModel, _) {
          if (budgetViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final budgets = budgetViewModel.budgets;

          return FutureBuilder<double>(
            future: Future.wait([
              budgetViewModel.getTotalBudgetAmount(1),
              budgetViewModel.getTotalSpentAmount(1),
            ]).then((values) => values[0] - values[1]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final totalAvailable = snapshot.data ?? 0.0;

              return Column(
                children: [
                  _buildSummarySection(
                    snapshot.data ?? 0.0, // totalAvailable
                    budgetViewModel.totalSpent,
                    budgetViewModel.totalBudget,
                  ),
                  Expanded(
                    child: budgets.isEmpty
                        ? const Center(
                      child: Text(
                        "No budgets available",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      itemCount: budgets.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final Budget budget = budgets[index];
                        return FutureBuilder<String>(
                          future: context.read<TransactionViewModel>().getCategoryName(budget.categoryId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError || snapshot.data == null) {
                              return _buildBudgetCard(
                                context,
                                budget,
                                "Category not found",
                                0.0,
                              );
                            }

                            final categoryName = snapshot.data!;
                            final double progress = (budget.spent / budget.amount).clamp(0, 1);

                            return _buildBudgetCard(
                              context,
                              budget,
                              categoryName,
                              progress,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        heroTag: 'addBudgetButton',
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummarySection(double totalBudget, double totalSpent, double totalAvailable) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryTile("Total Budgeted", totalBudget, Colors.blue),
            const SizedBox(height: 8),
            _buildSummaryTile("Total Spent", totalSpent, Colors.red),
            const SizedBox(height: 8),
            _buildSummaryTile("Total Available", totalAvailable, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(String title, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "S/ ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext context, Budget budget, String categoryName, double progress) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BudgetDetailScreen(budget: budget),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: const Icon(Icons.attach_money, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Budget: S/ ${budget.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                "Remaining: S/ ${(budget.amount - budget.spent).toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _amountController = TextEditingController();
    int? selectedCategory;

    // Espera a que las categorías disponibles se carguen
    final availableCategories = await context.read<TransactionViewModel>().getAvailableCategories();

    if (availableCategories.isEmpty) {
      // Si no hay categorías disponibles, muestra un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No categories available to create a budget.")),
      );
      return;
    }

    // Muestra el diálogo una vez que las categorías estén disponibles
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Budget",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Amount"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter an amount";
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return "Please enter a valid amount greater than 0";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedCategory,
                        items: availableCategories
                            .map((category) => DropdownMenuItem<int>(
                          value: (category as Category).id,
                          child: Text(category.name),
                        ))
                            .toList(),
                        onChanged: (value) {
                          selectedCategory = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please select a category";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final amount = double.parse(_amountController.text);
                          context.read<BudgetViewModel>().addBudget(1, selectedCategory!, amount);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Add"),
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
