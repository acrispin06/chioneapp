import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/report.dart';

class ReportViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Report> _reports = [];

  List<Report> get reports => _reports;

  Future<void> fetchReports() async {
    _reports = await _dbHelper.getReports();
    notifyListeners();
  }

  Future<void> addReport(Report report) async {
    await _dbHelper.insertReport(report);
    await fetchReports();
  }
}