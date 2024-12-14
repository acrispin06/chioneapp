import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/report_view_model.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.green,
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, reportViewModel, child) {
          return FutureBuilder(
            future: reportViewModel.fetchReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || reportViewModel.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    "Error fetching reports: ${reportViewModel.errorMessage}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done && reportViewModel.reports.isEmpty) {
                return const Center(
                  child: Text(
                    "No reports available.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final reports = reportViewModel.reports;

              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  final month = report['month'] ?? 'Unknown';
                  final year = report['year'] ?? 'Unknown';
                  final totalIncome = report['totalIncome'] ?? 0.0;
                  final totalExpense = report['totalExpense'] ?? 0.0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: const Icon(Icons.analytics, color: Colors.purple),
                      ),
                      title: Text(
                        "Report for $month/$year",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Income: S/ ${totalIncome.toStringAsFixed(2)} | Expense: S/ ${totalExpense.toStringAsFixed(2)}",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
