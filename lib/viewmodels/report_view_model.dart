import 'package:flutter/foundation.dart';
import '../services/report_service.dart';

class ReportViewModel with ChangeNotifier {
  final ReportService _reportService = ReportService();

  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _report = {};
  List<Map<String, dynamic>> _reports = [];
  String _selectedPeriod = 'Weekly';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get report => _report;
  List<Map<String, dynamic>> get reports => _reports;
  String get selectedPeriod => _selectedPeriod;

  /// Fetches all reports from the service and updates the state.
  Future<void> fetchReports() async {
    if (_isLoading) return; // Prevent duplicate calls

    _setLoadingState(true);

    try {
      final fetchedReports = await _reportService.getAllReports();
      await Future.delayed(Duration.zero, () {
        _reports = fetchedReports;
        _errorMessage = ''; // Clear previous errors
        notifyListeners();
      });
    } catch (e, stackTrace) {
      _errorMessage = 'Error fetching reports: ${e.toString()}';
      if (kDebugMode) {
        print(stackTrace); // Log error in debug mode
      }
    } finally {
      _setLoadingState(false);
    }
  }

  /// Fetches a specific monthly report based on the month and year.
  Future<void> fetchMonthlyReport(int month, int year) async {
    if (_isLoading) return; // Prevent duplicate calls

    _setLoadingState(true);

    try {
      final fetchedReport = await _reportService.getMonthlyReport(month, year);
      await Future.delayed(Duration.zero, () {
        _report = fetchedReport;
        _errorMessage = ''; // Clear previous errors
        notifyListeners();
      });
    } catch (e, stackTrace) {
      _errorMessage = 'Error fetching report: ${e.toString()}';
      if (kDebugMode) {
        print(stackTrace); // Log error in debug mode
      }
    } finally {
      _setLoadingState(false);
    }
  }

  /// Changes the selected reporting period (e.g., Weekly, Monthly).
  void changePeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      notifyListeners();
    }
  }

  /// Sets the loading state and notifies listeners if changed.
  void _setLoadingState(bool state) {
    if (_isLoading != state) {
      _isLoading = state;
      // Avoid `notifyListeners` during widget tree build
      Future.delayed(Duration.zero, () => notifyListeners());
    }
  }
}
