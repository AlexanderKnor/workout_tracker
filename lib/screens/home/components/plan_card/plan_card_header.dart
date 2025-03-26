// lib/screens/home/components/plan_card/plan_card_header.dart
import 'package:flutter/material.dart';
import '../../../../models/models.dart';

class PlanCardHeader extends StatelessWidget {
  final TrainingPlan plan;
  final Function(String?) onMenuSelected;

  const PlanCardHeader({
    Key? key,
    required this.plan,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3),
            Color(0xFF0D47A1),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  children: [
                    _buildPlanMetric(
                      Icons.calendar_today_outlined,
                      '${plan.trainingDays.length} ${plan.trainingDays.length == 1 ? 'day' : 'days'}',
                    ),
                    _buildPlanMetric(
                      Icons.fitness_center,
                      '${_getTotalExercises(plan)} exercises',
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          _buildContextMenu(),
        ],
      ),
    );
  }

  Widget _buildPlanMetric(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(0xFF1C2F49),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: Colors.white),
              SizedBox(width: 12),
              Text('Edit Plan', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Color(0xFFF95738)),
              SizedBox(width: 12),
              Text(
                'Delete',
                style: TextStyle(color: Color(0xFFF95738)),
              ),
            ],
          ),
        ),
      ],
      onSelected: onMenuSelected,
    );
  }

  int _getTotalExercises(TrainingPlan plan) {
    int total = 0;
    for (var day in plan.trainingDays) {
      total += day.exercises.length;
    }
    return total;
  }
}
