import 'package:equatable/equatable.dart';

class GoalModel extends Equatable {
  const GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
    this.streakDays = 0,
    this.status = GoalStatus.active,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String icon;
  final int streakDays;
  final GoalStatus status;

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;

  @override
  List<Object?> get props => [id, name, targetAmount, currentAmount, status];
}

enum GoalStatus { active, completed, paused }
