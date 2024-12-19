import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late int _selectedTypeId;
  late int _selectedCategoryId;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  late Map<String, dynamic> _mutableTransaction;

  @override
  void initState() {
    super.initState();

    // Crear una copia mutable de la transacción
    _mutableTransaction = Map<String, dynamic>.from(widget.transaction);

    _amountController = TextEditingController(text: _mutableTransaction['amount'].toString());
    _descriptionController = TextEditingController(text: _mutableTransaction['description']);
    _selectedTypeId = _mutableTransaction['type_id'];
    _selectedDate = DateTime.parse(_mutableTransaction['date']);
    _selectedTime = _parseTime(_mutableTransaction['time']);
    _selectedCategoryId = _mutableTransaction['category_id'];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
      await viewModel.fetchCategoriesByType(_selectedTypeId);
      _initializeCategorySelection(viewModel.categories);
    });
  }

  void _initializeCategorySelection(List<Map<String, dynamic>> categories) {
    if (categories.isNotEmpty) {
      _selectedCategoryId = categories.any((c) => c['id'] == _selectedCategoryId)
          ? _selectedCategoryId
          : categories.first['id'];
    } else {
      _selectedCategoryId = -1;
    }
  }

  TimeOfDay _parseTime(String time) {
    final isPM = time.toLowerCase().contains('pm');
    final cleanTime = time.replaceAll(RegExp(r'[^0-9:]'), '');
    final parts = cleanTime.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Transaction"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Amount", _amountController, TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField("Description", _descriptionController, TextInputType.text),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildTimePicker(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter $label" : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedTypeId,
      decoration: InputDecoration(
        labelText: "Type",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text("Income")),
        DropdownMenuItem(value: 2, child: Text("Expense")),
      ],
      onChanged: (value) async {
        setState(() => _selectedTypeId = value ?? 1);
        final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
        await viewModel.fetchCategoriesByType(_selectedTypeId);
        _initializeCategorySelection(viewModel.categories);
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, _) {
        // Asegurarse de que _selectedCategoryId existe en la lista
        final categories = viewModel.categories;

        // Validar que la categoría seleccionada existe en la lista
        if (!categories.any((category) => category['id'] == _selectedCategoryId)) {
          _selectedCategoryId = categories.isNotEmpty ? categories.first['id'] : null;
        }

        return DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: "Category",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<int>(
              value: category['id'] as int,
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: (value) {
            final selectedCategory = categories.firstWhere((c) => c['id'] == value);
            setState(() {
              _selectedCategoryId = value ?? _selectedCategoryId;
              _mutableTransaction['icon_id'] = selectedCategory['icon_id'];
            });
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

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedTransaction = {
        'id': widget.transaction['id'],
        'amount': double.parse(_amountController.text),
        'description': _descriptionController.text,
        'type_id': _selectedTypeId,
        'category_id': _selectedCategoryId,
        'icon_id': _mutableTransaction['icon_id'] ?? 1,
        'date': _selectedDate.toIso8601String(),
        'time': _selectedTime.format(context),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final viewModel = Provider.of<TransactionViewModel>(context, listen: false);

      try {
        await viewModel.updateTransaction(updatedTransaction);

        // Redirigir y mostrar SnackBar
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction updated successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }
}
