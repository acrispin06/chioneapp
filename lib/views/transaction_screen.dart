import 'package:chioneapp/models/goal.dart';
import 'package:chioneapp/viewmodels/goal_view_model.dart';
import 'package:chioneapp/views/transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedTypeId = 1; // 1: Income, 2: Expense
  int? _selectedCategoryId;
  int? _selectedGoalId;
  int? _selectedIconId; // Auto-selected based on category
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<TransactionViewModel>(
          context, listen: false);
      await viewModel.fetchIcons();
      await viewModel.fetchCategoriesByType(_selectedTypeId);
      viewModel.fetchAllTransactions();
      viewModel.fetchSummaryData();
      _initializeCategorySelection();
    });
  }

  void _initializeCategorySelection() {
    final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
    if (viewModel.categories.isNotEmpty) {
      final firstCategory = viewModel.categories.first;
      setState(() {
        _selectedCategoryId = firstCategory['id'] as int;
        _selectedIconId = firstCategory['icon_id'] as int;
      });
    } else {
      setState(() {
        _selectedCategoryId = null;
        _selectedIconId = null;
      });
    }
  }

  Future<void> _showAddTransactionDialog() async {
    final transactionViewModel = Provider.of<TransactionViewModel>(context, listen: false);
    final goalViewModel = Provider.of<GoalViewModel>(context, listen: false);
    // Fetch available goals
    await goalViewModel.fetchGoals();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "Add New Transaction",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Form fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Amount
                    _buildTextField("Amount", _amountController, TextInputType.number),
                    const SizedBox(height: 12),

                    // Description
                    _buildTextField("Description", _descriptionController, TextInputType.text),
                    const SizedBox(height: 12),

                    // Type Dropdown
                    _buildTypeDropdown(),
                    const SizedBox(height: 12),

                    // Category Dropdown
                    _buildCategoryDropdown(),
                    const SizedBox(height: 12),

                    // Goal Dropdown (only for income)
                    if (_selectedTypeId == 1) _buildGoalDropdown(goalViewModel),
                    const SizedBox(height: 12),

                    // Date Picker
                    _buildDatePicker(),
                    const SizedBox(height: 12),

                    // Time Picker
                    _buildTimePicker(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addTransaction,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Add", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildGoalDropdown(GoalViewModel goalViewModel) {
    return DropdownButtonFormField<int>(
      value: _selectedGoalId,
      decoration: const InputDecoration(
        labelText: "Goal",
      ),
      items: goalViewModel.goals.map((goal) {
        return DropdownMenuItem<int>(
          value: (goal as Goal).id,
          child: Text((goal as Goal).name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGoalId = value;
        });
      },
      validator: (value) {
        if (_selectedTypeId == 1 && value == null) {
          return "Please select a goal for this income.";
        }
        return null;
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) =>
      value == null || value.isEmpty
          ? "Please enter $label"
          : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedTypeId,
      decoration: InputDecoration(
        labelText: "Type",
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text("Income")),
        DropdownMenuItem(value: 2, child: Text("Expense")),
      ],
      onChanged: (value) async {
        setState(() => _selectedTypeId = value ?? 1);
        await Provider.of<TransactionViewModel>(context, listen: false)
            .fetchCategoriesByType(_selectedTypeId);
        _initializeCategorySelection();
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, _) {
        return DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: "Category",
          ),
          items: viewModel.categories.map((category) {
            return DropdownMenuItem<int>(
              value: category['id'] as int,
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final selectedCategory = viewModel.categories.firstWhere((
                  c) => c['id'] == value);
              setState(() {
                _selectedCategoryId = value;
                _selectedIconId = selectedCategory['icon_id'];
              });
            }
          },
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          const Text(
            "Date:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Text(
            "${_selectedDate.toLocal()}".split(' ')[0],
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            setState(() {
              _selectedDate = date;
            });
          }
        },
      ),
    );
  }


  Widget _buildTimePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text("Time: ${_selectedTime.format(context)}"),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) setState(() => _selectedTime = time);
      },
    );
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final transaction = {
        'amount': double.parse(_amountController.text),
        'description': _descriptionController.text,
        'type_id': _selectedTypeId,
        'category_id': _selectedCategoryId,
        'icon_id': _selectedIconId ?? 1,
        'date': _selectedDate.toIso8601String(),
        'time': _selectedTime.format(context),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Provider.of<TransactionViewModel>(context, listen: false)
          .addTransactionWithGoal(transaction, goalId: _selectedGoalId);
      Navigator.of(context).pop();
      _clearForm();
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedTypeId = 1;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedCategoryId = null;
      _selectedGoalId = null;
      _selectedIconId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSummarySection(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildTransactionListSliver(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Transaction",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true, // Añadimos esta línea para centrar el título
        title: Text(
          'Transactions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              _buildBalanceCard(viewModel),
              const SizedBox(height: 16),
              _buildIncomeExpenseRow(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(TransactionViewModel viewModel) {
    final balance = viewModel.totalIncome - viewModel.totalExpense;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme
          .of(context)
          .colorScheme
          .primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'S/ ${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseRow(TransactionViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryTile(
            title: "Income",
            amount: viewModel.totalIncome,
            icon: Icons.arrow_upward,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryTile(
            title: "Expense",
            amount: viewModel.totalExpense,
            icon: Icons.arrow_downward,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTile({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'S/ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListSliver() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.transactions.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No transactions yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final transaction = viewModel.transactions[index];
                final type = transaction['type_name'];
                final iconPath = viewModel.icons[transaction['icon_id']] ??
                    'assets/icons/default.png';
                final isIncome = type == 'income';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () =>
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionDetailScreen(
                                    transactionId: transaction['id']),
                          ),
                        ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isIncome ? Colors.green : Colors.red)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                iconPath,
                                width: 24,
                                height: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction['description'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${transaction['date'].toString().split(
                                        'T')[0]} - ${transaction['time']}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'S/ ${transaction['amount']}',
                                  style: TextStyle(
                                    color: isIncome ? Colors.green[700] : Colors
                                        .red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isIncome ? Colors.green : Colors
                                        .red).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: isIncome
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: viewModel.transactions.length,
            ),
          ),
        );
      },
    );
  }
}