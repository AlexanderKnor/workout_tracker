// lib/screens/home/components/empty_plans_view.dart
import 'package:flutter/material.dart';

class EmptyPlansView extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const EmptyPlansView({
    Key? key,
    required this.onCreatePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPlaceholderIcon(),
            SizedBox(height: 24),
            Text(
              'No training plans yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Create your first workout plan to start\ntracking your fitness journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onCreatePressed,
              icon: Icon(Icons.add),
              label: Text('CREATE YOUR FIRST PLAN'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Color(0xFF2196F3).withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    // Custom placeholder animation widget
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1C2F49),
      ),
      child: Icon(
        Icons.fitness_center,
        size: 80,
        color: Color(0xFF2196F3),
      ),
    );
  }
}
