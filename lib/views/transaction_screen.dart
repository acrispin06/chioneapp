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
  int? _selectedIconId; // Auto-selected based on category
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
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
      // Evita asignar un valor no válido
      setState(() {
        _selectedCategoryId = null;
        _selectedIconId = null;
      });
    }
  }

  // UI para agregar una nueva transacción
  Future<void> _showAddTransactionDialog() async {
  final context = this.context;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Add New Transaction", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Amount
              _buildTextField("Amount", _amountController, TextInputType.number),
              // Description
              _buildTextField("Description", _descriptionController, TextInputType.text),
              // Type
              _buildTypeDropdown(),
              // Category
              _buildCategoryDropdown(),
              // Date
              _buildDatePicker(),
              // Time
              _buildTimePicker(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
        ElevatedButton(onPressed: _addTransaction, child: const Text("Add")),
      ],
    ),
  );
}

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return TextFormField(
        controller: controller,
        keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter $label" : null,
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
              final selectedCategory = viewModel.categories.firstWhere((c) => c['id'] == value);
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
      title: Text("Date: ${_selectedDate.toLocal()}".split(' ')[0]),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
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

      await Provider.of<TransactionViewModel>(context, listen: false).addTransaction(transaction);
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
      _selectedIconId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSummarySection(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.add),
        label: const Text("Add Transaction"),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              viewModel.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }
        if (viewModel.transactions.isEmpty) {
          return const Center(child: Text("No transactions available."));
        }
        return ListView.builder(
          itemCount: viewModel.transactions.length,
          itemBuilder: (context, index) {
            final transaction = viewModel.transactions[index];
            final type = transaction['type_name'];
            final iconPath = viewModel.icons[transaction['icon_id']] ?? 'assets/icons/default.png';

            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransactionDetailScreen(transactionId: transaction['id']),
                ),
              ),
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: type == 'income' ? Colors.green.shade100 : Colors.red.shade100,
                    child: Image.asset(iconPath, width: 30, height: 30),
                  ),
                  title: Text(
                    transaction['description'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${transaction['date'].toString().split('T')[0]} - ${transaction['time']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    "S/ ${transaction['amount']}",
                    style: TextStyle(
                      color: type == 'income' ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummarySection() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
        if (viewModel.errorMessage.isNotEmpty) {
          return Center(child: Text(viewModel.errorMessage, style: const TextStyle(color: Colors.red)));
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryCard("Income", "S/ ${viewModel.totalIncome.toStringAsFixed(2)}", Colors.green.shade400),
              SizedBox(width: 16),
              _summaryCard("Expense", "S/ ${viewModel.totalExpense.toStringAsFixed(2)}", Colors.red.shade400),
              SizedBox(width: 16),
              _summaryCard("Balance", "S/ ${(viewModel.totalIncome - viewModel.totalExpense).toStringAsFixed(2)}", Colors.blue.shade400),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  title == "Income" ? Icons.trending_up :
                  title == "Expense" ? Icons.trending_down :
                  Icons.account_balance_wallet,
                  color: Color.fromRGBO(16, 97, 66, 100),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(16, 97, 66, 100),
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(16, 97, 66, 100),
                shadows: [
                  Shadow(
                    blurRadius: 6.0,
                    color: color.withOpacity(0.4),
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
