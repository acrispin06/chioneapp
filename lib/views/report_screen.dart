import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/report_view_model.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reportViewModel = Provider.of<ReportViewModel>(context);

    // Cargar transacciones y reportes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reportViewModel.fetchReports();
    });

    final totalBalance = reportViewModel.getTotalBalance();
    final totalExpense = reportViewModel.getTotalExpense();
    final progress = totalExpense / 20000.0;
    final selectedPeriod = reportViewModel.selectedPeriod;

    return Scaffold(
      backgroundColor: Color(0xFF00B686), // Fondo verde
      appBar: AppBar(
        backgroundColor: Color(0xFF00B686),
        elevation: 0,
        title: Text("Analysis", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Acción para notificaciones
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance y gastos totales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceInfo("Total Balance", "S/ ${totalBalance.toStringAsFixed(2)}", Colors.green),
                  _buildBalanceInfo("Total Expense", "-S/ ${totalExpense.toStringAsFixed(2)}", Colors.red),
                ],
              ),
              SizedBox(height: 16),
              // Barra de progreso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: progress.isFinite ? progress : 0.0,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${(progress * 100).toStringAsFixed(1)}% Of Your Expenses, Looks Good.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Filtros de periodo (Diario, Semanal, etc.)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ["Daily", "Weekly", "Monthly", "Year"]
                    .map((period) => _buildPeriodButton(context, period, period == selectedPeriod))
                    .toList(),
              ),
              SizedBox(height: 16),
              // Gráfico de Ingresos y Gastos
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFE6F4F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Income & Expenses", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 16),
                            Icon(Icons.calendar_today, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Gráfico de líneas
                    SizedBox(
                      height: 200,
                      child: LineChart(LineChartData(
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: reportViewModel.getIncomeExpenseSpots(),
                            isCurved: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
                            color: Colors.green,
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Resumen de Income y Expense
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard("Income", "S/ ${reportViewModel.getTotalIncome().toStringAsFixed(2)}", Icons.arrow_downward, Colors.green),
                  _buildSummaryCard("Expense", "S/ ${reportViewModel.getTotalExpense().toStringAsFixed(2)}", Icons.arrow_upward, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para mostrar el balance total y el gasto
  Widget _buildBalanceInfo(String title, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.black54)),
        Text(
          amount,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  // Método para construir botones de periodos (Diario, Semanal, etc.)
  Widget _buildPeriodButton(BuildContext context, String period, bool isSelected) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF00B686) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        final reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
        reportViewModel.changePeriod(period);
      },
      child: Text(
        period,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  // Método para construir tarjetas de resumen (Income, Expense)
  Widget _buildSummaryCard(String label, String amount, IconData icon, Color color) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
