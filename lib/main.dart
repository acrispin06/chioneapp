import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home_screen.dart';
import 'viewmodels/budget_view_model.dart';
import 'viewmodels/category_view_model.dart';
import 'viewmodels/goal_view_model.dart';
import 'viewmodels/notification_view_model.dart';
import 'viewmodels/report_view_model.dart';
import 'viewmodels/transaction_view_model.dart';
import 'viewmodels/user_view_model.dart';

void main() {
  runApp(ChiOneApp());
}

class ChiOneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => GoalViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => ReportViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChiOneApp',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
