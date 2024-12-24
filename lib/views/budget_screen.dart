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
      context.read<BudgetViewModel>().fetchBudgets(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8DEF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Budgets",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF21005D),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<BudgetViewModel>(
        builder: (context, budgetViewModel, _) {
          if (budgetViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6750A4)),
            );
          }

          final budgets = budgetViewModel.budgets;

          return FutureBuilder<double>(
            future: Future.wait([
              budgetViewModel.getTotalBudgetAmount(1),
              budgetViewModel.getTotalSpentAmount(1),
            ]).then((values) => values[0] - values[1]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6750A4)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Color(0xFF21005D)),
                  ),
                );
              }

              final totalAvailable = snapshot.data ?? 0.0;

              return Column(
                children: [
                  _buildSummarySection(
                    snapshot.data ?? 0.0,
                    budgetViewModel.totalSpent,
                    budgetViewModel.totalBudget,
                  ),
                  Expanded(
                    child: budgets.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: const Color(0xFF6750A4).withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No budgets available",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF21005D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Add a budget to get started",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      itemCount: budgets.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final Budget budget = budgets[index];
                        return FutureBuilder<String>(
                          future: context
                              .read<TransactionViewModel>()
                              .getCategoryName(budget.categoryId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6750A4),
                                ),
                              );
                            }

                            final categoryName =
                                snapshot.data ?? "Category not found";
                            final double progress =
                            (budget.spent / budget.amount).clamp(0, 1);

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
        backgroundColor: const Color(0xFF6750A4),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildSummarySection(
      double totalAvailable, double totalSpent, double totalBudget) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6750A4).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildSummaryTile(
              "Total Budget",
              totalBudget,
              const Color(0xFF6750A4),
              Icons.account_balance_wallet,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _buildSummaryTile(
              "Spent",
              totalSpent,
              const Color(0xFFB3261E),
              Icons.trending_down,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _buildSummaryTile(
              "Available",
              totalAvailable,
              const Color(0xFF1B873B),
              Icons.savings,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummaryTile(
      String title, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                "S/ ${amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(
      BuildContext context, Budget budget, String categoryName, double progress) {
    final remainingAmount = budget.amount - budget.spent;
    final isOverBudget = remainingAmount < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6750A4).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6750A4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Color(0xFF6750A4),
                    ),
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
                            color: Color(0xFF21005D),
                          ),
                        ),
                        Text(
                          "Budgeted: S/ ${budget.amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isOverBudget
                          ? const Color(0xFFB3261E)
                          : const Color(0xFF1B873B))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${(progress * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isOverBudget
                            ? const Color(0xFFB3261E)
                            : const Color(0xFF1B873B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF6750A4).withOpacity(0.1),
                  color: isOverBudget
                      ? const Color(0xFFB3261E)
                      : const Color(0xFF6750A4),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Spent: S/ ${budget.spent.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "${isOverBudget ? 'Exceeded: ' : 'Available: '}S/ ${remainingAmount.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isOverBudget
                          ? const Color(0xFFB3261E)
                          : const Color(0xFF1B873B),
                    ),
                  ),
                ],
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
    final expenseCategories = availableCategories.where((category) => (category as Category).type_id == 1).toList();
    if (availableCategories.isEmpty) {
      // Si no hay categorías disponibles, muestra un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No categories available. Please add a category first."),
          backgroundColor: Color(0xFF6750A4),
        ),
      );
      return;
    }

    // Muestra el diálogo una vez que las categorías estén disponibles
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
                  "Add New Budget",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color(0xFF21005D)),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Amount",prefixText: "S/",
                          labelStyle:
                          const TextStyle(color: Color(0xFF6750A4)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            const BorderSide(color: Color(0xFF6750A4)),
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
