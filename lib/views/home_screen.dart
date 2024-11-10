import 'package:chioneapp/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_view_model.dart';
import '../viewmodels/report_view_model.dart';
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
    TransactionScreen(),
    BudgetScreen(),
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
      )
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final reportViewModel = Provider.of<ReportViewModel>(context);

    double totalBalance = transactionViewModel.totalBalance;
    double totalExpense = transactionViewModel.getTotalExpense();
    double weeklyIncome = transactionViewModel.getWeeklyIncome();
    double weeklyFoodExpense = transactionViewModel.getWeeklyFoodExpense();
    String selectedPeriod = reportViewModel.selectedPeriod;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(totalBalance, totalExpense),
          SizedBox(height: 16),
          _buildGoalCard(weeklyIncome, weeklyFoodExpense),
          SizedBox(height: 16),
          _buildPeriodFilters(reportViewModel),
          SizedBox(height: 16),
          Expanded(
            child: _buildTransactionList(
                transactionViewModel.getFilteredTransactions(selectedPeriod).cast<Transaction>()),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance, double expense) {
    return Card(
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
                _buildBalanceInfo("Total Balance", "S/ ${balance.toStringAsFixed(2)}", Colors.green),
                _buildBalanceInfo("Total Expense", "-S/ ${expense.toStringAsFixed(2)}", Colors.red),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: expense / 20000.0,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
            ),
            SizedBox(height: 8),
            Text("${(expense / 20000 * 100).toStringAsFixed(1)}% Of Your Expenses, Looks Good."),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(double weeklyIncome, double weeklyFoodExpense) {
    return Card(
      color: Color(0xFFE6F4F1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryCard("Savings On Goals", "S/ 0.00", Icons.directions_car, Colors.blue)
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilters(ReportViewModel reportViewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ["Daily", "Weekly", "Monthly"].map((period) {
        bool isSelected = reportViewModel.selectedPeriod == period;
        return _buildPeriodButton(period, isSelected, reportViewModel);
      }).toList(),
    );
  }

  Widget _buildPeriodButton(String period, bool isSelected, ReportViewModel reportViewModel) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {
        reportViewModel.changePeriod(period);
      },
      child: Text(period, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(
              transaction.type == "income" ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.type == "income" ? Colors.green : Colors.red,
            ),
          ),
          title: Text(transaction.description),
          subtitle: Text("${transaction.date.day}/${transaction.date.month}/${transaction.date.year} | ${transaction.date.hour}:${transaction.date.minute} - ${transaction.type.toUpperCase()}"),
          trailing: Text(
            "S/ ${transaction.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: transaction.type == "income" ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String label, String amount, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 16)),
        Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildBalanceInfo(String title, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.black54)),
        Text(amount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
