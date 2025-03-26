// lib/screens/home/dialogs/delete_plan_dialog.dart
import 'package:flutter/material.dart';
import '../../../models/models.dart';

class DeletePlanDialog extends StatelessWidget {
  final TrainingPlan plan;
  final VoidCallback onConfirm;

  const DeletePlanDialog({
    Key? key,
    required this.plan,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Color(0xFF1C2F49),
      titlePadding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 0),
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
            'Delete Plan',
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
            'Are you sure you want to delete "${plan.name}"? This action cannot be undone.',
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
                  child: Text('CANCEL'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: Text('DELETE'),
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
    );
  }
}
