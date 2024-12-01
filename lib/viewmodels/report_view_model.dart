import 'package:flutter/foundation.dart';
import '../services/report_service.dart';

class ReportViewModel with ChangeNotifier {
  final ReportService _reportService = ReportService();

  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _report = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get report => _report;

  Future<void> fetchMonthlyReport(int month, int year) async {
    _isLoading = true;
    notifyListeners();

    try {
      _report = await _reportService.getMonthlyReport(month, year);
    } catch (e) {
      _errorMessage = 'Error fetching report';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
