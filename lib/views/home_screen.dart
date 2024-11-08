import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';
import '../viewmodels/user_view_model.dart';
import 'budget_screen.dart';
import 'goal_screen.dart';
import 'notification_screen.dart';
import 'report_screen.dart';
import 'transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeContent(),
    //ReportScreen(),
    TransactionScreen(),
    BudgetScreen(),
    //GoalScreen(), // Aquí puedes usar una pantalla para el perfil o lo que corresponda
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, Welcome Back", style: TextStyle(fontSize: 18, color: Colors.white)),
            Text("Good Morning", style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance and Expense Section
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Balance", style: TextStyle(fontSize: 16)),
                          Text(
                            "S/ 7,783.00",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Expense", style: TextStyle(fontSize: 16)),
                          Text(
                            "- S/ 1,187.40",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.3,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("S/ 20,000.00", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text("30% Of Your Expenses, Looks Good."),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Savings and Revenue Section
          Card(
            color: Colors.green.shade50,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.directions_car, color: Colors.blue, size: 40),
                        SizedBox(height: 8),
                        Text("Savings On Goals", textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  VerticalDivider(),
                  Expanded(
                    child: Column(
                      children: [
                        Text("Revenue Last Week", style: TextStyle(fontSize: 16)),
                        Text(
                          "S/ 4,000.00",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text("Food Last Week", style: TextStyle(fontSize: 16)),
                        Text(
                          "- S/ 100.00",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Daily, Weekly, Monthly Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabButton(context, "Daily", true),
              _buildTabButton(context, "Weekly", false),
              _buildTabButton(context, "Monthly", false),
            ],
          ),
          SizedBox(height: 16),
          // Recent Transactions List
          Expanded(
            child: ListView.builder(
              itemCount: transactionViewModel.transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactionViewModel.transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      transaction.type == "income" ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transaction.type == "income" ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(transaction.category),
                  subtitle: Text("${transaction.date.toString()} - ${transaction.type}"),
                  trailing: Text(
                    "S/ ${transaction.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: transaction.type == "income" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String label, bool isSelected) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        // Manejar la selección de la pestaña
      },
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}