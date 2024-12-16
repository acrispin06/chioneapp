import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedTypeId = 1; // 1: Income, 2: Expense
  DateTime _selectedDate = DateTime.now();
  int _selectedCategoryId = 1; // Default category
  int _selectedIconId = 1; // Default icon

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionViewModel>(context, listen: false).fetchAllTransactions();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showAddTransactionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Transaction"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Monto
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
                validator: (value) => value == null || value.isEmpty ? "Please enter amount" : null,
              ),
              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) => value == null || value.isEmpty ? "Please enter description" : null,
              ),
              // Tipo (Income/Expense)
              DropdownButtonFormField<int>(
                value: _selectedTypeId,
                decoration: const InputDecoration(labelText: "Type"),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Income")),
                  DropdownMenuItem(value: 2, child: Text("Expense")),
                ],
                onChanged: (value) => setState(() => _selectedTypeId = value ?? 1),
              ),
              // Fecha
              ListTile(
                title: Text("Date: ${_selectedDate.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _addTransaction,
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      final transaction = {
        'amount': double.parse(_amountController.text),
        'description': _descriptionController.text,
        'type_id': _selectedTypeId,
        'category_id': _selectedCategoryId,
        'icon_id': _selectedIconId,
        'date': _selectedDate.toIso8601String(),
        'time': TimeOfDay.now().format(context),
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
              return ListTile(
                leading: Icon(
                  type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: type == 'income' ? Colors.green : Colors.red,
                ),
                title: Text(transaction['description']),
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
