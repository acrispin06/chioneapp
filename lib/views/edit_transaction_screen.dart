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
        title: const Text(
          "Edit Transaction",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Amount"),
                _buildAmountField(),
                const SizedBox(height: 24),
                _buildSectionTitle("Details"),
                _buildDetailsCard(),
                const SizedBox(height: 24),
                _buildSectionTitle("Date & Time"),
                _buildDateTimeCard(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.attach_money,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            border: InputBorder.none,
            hintText: "0.00",
          ),
          validator: (value) => value == null || value.isEmpty ? "Please enter an amount" : null,
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              "Description",
              _descriptionController,
              TextInputType.text,
              Icons.description_outlined,
            ),
            const SizedBox(height: 16),
            _buildTypeDropdown(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDatePicker(),
            const Divider(height: 1),
            _buildTimePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      TextInputType type,
      IconData icon,
      ) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? "Please enter $label" : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedTypeId,
      decoration: InputDecoration(
        labelText: "Type",
        prefixIcon: Icon(
          Icons.account_balance_wallet_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.arrow_upward, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              const Text("Income"),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.arrow_downward, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              const Text("Expense"),
            ],
          ),
        ),
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
        final categories = viewModel.categories;
        if (!categories.any((category) => category['id'] == _selectedCategoryId)) {
          _selectedCategoryId = categories.isNotEmpty ? categories.first['id'] : null;
        }

        return DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            labelText: "Category",
            prefixIcon: Icon(
              Icons.category_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
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
      leading: Icon(
        Icons.calendar_today,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text("Date"),
      subtitle: Text(
        "${_selectedDate.toLocal()}".split(' ')[0],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
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
      leading: Icon(
        Icons.access_time,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text("Time"),
      subtitle: Text(
        _selectedTime.format(context),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) setState(() => _selectedTime = time);
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
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
      await viewModel.updateTransaction(updatedTransaction);

      Navigator.of(context).pop(); // Regresar al detalle después de guardar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction updated successfully"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
