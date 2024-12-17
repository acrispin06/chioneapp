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
      _initializeCategorySelection();
    });
  }

  void _initializeCategorySelection() {
  final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
  if (viewModel.categories.isNotEmpty) {
    setState(() {
      _selectedCategoryId = viewModel.categories.first['id'];
      _selectedIconId = viewModel.categories.first['icon_id'];
    });
  }
}

Future<void> _showAddTransactionDialog() async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Add New Transaction"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
                validator: (value) => value == null || value.isEmpty ? "Please enter amount" : null,
              ),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) => value == null || value.isEmpty ? "Please enter description" : null,
              ),
              // Type (Income/Expense)
              DropdownButtonFormField<int>(
                value: _selectedTypeId,
                decoration: const InputDecoration(labelText: "Type"),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Income")),
                  DropdownMenuItem(value: 2, child: Text("Expense")),
                ],
                onChanged: (value) async {
                  setState(() => _selectedTypeId = value ?? 1);
                  await Provider.of<TransactionViewModel>(context, listen: false).fetchCategoriesByType(_selectedTypeId);
                  _initializeCategorySelection();
                },
              ),
              // Category
              Consumer<TransactionViewModel>(
                builder: (context, viewModel, _) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: viewModel.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'] as int,
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final selectedCategory = viewModel.categories.firstWhere((c) => c['id'] == value);
                      setState(() {
                        _selectedCategoryId = value;
                        _selectedIconId = selectedCategory['icon_id'];
                      });
                    },
                  );
                },
              ),
              // Date
              ListTile(
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
              ),
              // Time
              ListTile(
                title: Text("Time: ${_selectedTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),
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
      appBar: AppBar(title: const Text("Transactions"), backgroundColor: Colors.green),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
          if (viewModel.errorMessage.isNotEmpty) {
            return Center(child: Text(viewModel.errorMessage, style: const TextStyle(color: Colors.red)));
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
              return ListTile(
                leading: Image.asset(iconPath, width: 40, height: 40),
                title: Text(
                  transaction['description'],
                  style: TextStyle(color: type == 'income' ? Colors.green : Colors.red),
                ),
                subtitle: Text(transaction['date']),
                trailing: Text(
                  "S/ ${transaction['amount']}",
                  style: TextStyle(color: type == 'income' ? Colors.green : Colors.red),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
