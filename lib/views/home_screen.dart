import 'package:chioneapp/views/notification_screen.dart';
import 'package:chioneapp/views/report_screen.dart';
import 'package:chioneapp/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String? _userName;

  final List<Widget> _screens = [
    TransactionScreen(),
    BudgetScreen(),
    GoalScreen(),
    ReportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _fetchUserName();
    });
  }

  Future<void> _fetchUserName() async {
    final userId = 1;  //Hardcoded user id
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final name = await userViewModel.getNameOfUserById(userId);
    setState(() {
      _userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        automaticallyImplyLeading: false,
        title: _buildAppBarTitle(),
        actions: [_buildNotificationIcon(context)],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF664FA2), Color(0xFF7660B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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

  Widget _buildAppBarTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _userName != null ? "Hi, $_userName" : "Hi, welcome back",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getGreeting(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final hasUnreadNotifications = true;

    return hasUnreadNotifications
        ? IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.notifications, color: Colors.white),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 8,
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationScreen()),
        );
      },
    )
        : const SizedBox.shrink();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }
}
