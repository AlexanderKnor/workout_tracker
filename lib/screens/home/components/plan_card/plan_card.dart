// lib/screens/home/components/plan_card/plan_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../providers/workout_provider.dart';
import '../../dialogs/delete_plan_dialog.dart';
import 'plan_card_header.dart';
import 'day_item.dart';

class PlanCard extends StatelessWidget {
  final TrainingPlan plan;
  final double parallaxOffset;
  final Function(TrainingPlan) onEditPressed;
  final Function(TrainingPlan, TrainingDay) onWorkoutPressed;

  const PlanCard({
    Key? key,
    required this.plan,
    required this.parallaxOffset,
    required this.onEditPressed,
    required this.onWorkoutPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xFF14253D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              PlanCardHeader(
                plan: plan,
                onMenuSelected: (value) => _handleMenuSelection(context, value),
              ),

              // Plan content
              Container(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                constraints: BoxConstraints(
                  maxWidth: size.width - 32, // Account for outside padding
                ),
                color: Color(0xFF1C2F49),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: plan.trainingDays.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 70,
                    endIndent: 20,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) => DayItem(
                    day: plan.trainingDays[index],
                    onTap: (day) => onWorkoutPressed(plan, day),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getTotalExercises(TrainingPlan plan) {
    int total = 0;
    for (var day in plan.trainingDays) {
      total += day.exercises.length;
    }
    return total;
  }

  void _handleMenuSelection(BuildContext context, String? value) {
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);

    switch (value) {
      case 'edit':
        onEditPressed(plan);
        break;
      case 'delete':
        // Zusätzliche Prüfung hinzufügen, ob dies der aktive Plan ist
        if (state.activePlan?.id == plan.id && state.plans.length > 1) {
          // Zeige einen speziellen Dialog an, wenn es der aktive Plan ist
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: Color(0xFF1C2F49),
              titlePadding:
                  EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 0),
              contentPadding: EdgeInsets.all(24),
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF95738).withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF95738),
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aktiven Plan löschen?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Du bist dabei den aktiven Plan "${plan.name}" zu löschen. Ein anderer Plan wird aktiviert.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('ABBRECHEN'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Vor dem Löschen einen anderen Plan aktivieren
                            String currentPlanId = plan.id;
                            state.deletePlan(plan.id);

                            // Wenn möglich, einen anderen Plan aktivieren
                            if (state.plans.isNotEmpty) {
                              String newActivePlanId = state.plans.first.id;
                              if (newActivePlanId != currentPlanId) {
                                state.setActivePlan(newActivePlanId);
                              }
                            }

                            Navigator.of(context).pop();
                          },
                          child: Text('LÖSCHEN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF95738),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          // Normaler Löschdialog für nicht-aktive Pläne
          showDialog(
            context: context,
            builder: (context) => DeletePlanDialog(
              plan: plan,
              onConfirm: () {
                state.deletePlan(plan.id);
                Navigator.of(context).pop();
              },
            ),
          );
        }
        break;
    }
  }
}
