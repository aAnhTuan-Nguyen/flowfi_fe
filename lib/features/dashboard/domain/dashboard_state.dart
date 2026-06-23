import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.totalBalance = 0.0,
    this.monthlyIncome = 0.0,
    this.monthlyExpenses = 0.0,
    this.weeklySpending = const [],
    this.isLoading = false,
    this.error,
  });

  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<double> weeklySpending;
  final bool isLoading;
  final String? error;

  @override
  List<Object?> get props => [
        totalBalance,
        monthlyIncome,
        monthlyExpenses,
        weeklySpending,
        isLoading,
        error,
      ];
}
