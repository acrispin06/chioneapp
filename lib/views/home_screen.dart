import 'package:chioneapp/views/notification_screen.dart';
import 'package:chioneapp/views/report_screen.dart';
import 'package:flutter/material.dart';
import '../shared/navbar.dart';
import 'budget_screen.dart';
import 'goal_screen.dart';
import 'transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    TransactionScreen(),
    BudgetScreen(),
    GoalScreen(),
    ReportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: _buildAppBarTitle(),
        actions: [_buildNotificationIcon(context)],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Método para construir el título del AppBar
  Widget _buildAppBarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Hi, Welcome Back",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Text(
          "Good Morning",
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  // Método para construir el botón de notificaciones
  Widget _buildNotificationIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationScreen()),
        );
      },
    );
  }
}
