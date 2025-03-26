// lib/screens/workout/components/workout_log_card.dart
import 'package:flutter/material.dart';
import '../../../models/models.dart';

class WorkoutLogCard extends StatelessWidget {
  final List<SetLog> workoutLog;

  const WorkoutLogCard({
    Key? key,
    required this.workoutLog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF14253D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF3D85C6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.history,
                        color: Color(0xFF3D85C6),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'SESSION LOG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: Color(0xFF3D85C6),
                      ),
                    ),
                  ],
                ),
                // Exercise count pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C2F49),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${workoutLog.length} sets',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  child: isSmallScreen
                      ? _buildCompactWorkoutLogTable()
                      : _buildFullWorkoutLogTable(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact table for small screens
  Widget _buildCompactWorkoutLogTable() {
    return Table(
      columnWidths: {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      border: TableBorder(
        verticalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
        horizontalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Color(0xFF253B59),
          ),
          children: [
            _buildTableHeader('Exercise / Set'),
            _buildTableHeader('Kg'),
            _buildTableHeader('Reps'),
            _buildTableHeader('RIR'),
          ],
        ),
        ...workoutLog.map((log) => TableRow(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.exerciseName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Set ${log.set}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTableCell('${log.weight}'),
                _buildTableCell('${log.reps}'),
                _buildTableCell('${log.rir}'),
              ],
            )),
      ],
    );
  }

  // Full table for larger screens
  Widget _buildFullWorkoutLogTable() {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1.5),
      },
      border: TableBorder(
        verticalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
        horizontalInside: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Color(0xFF253B59),
          ),
          children: [
            _buildTableHeader('Exercise'),
            _buildTableHeader('Set'),
            _buildTableHeader('Weight'),
            _buildTableHeader('Reps'),
            _buildTableHeader('RIR'),
            _buildTableHeader('1RM'),
          ],
        ),
        ...workoutLog.map((log) => TableRow(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text(
                    log.exerciseName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                _buildTableCell('${log.set}'),
                _buildTableCell('${log.weight} kg'),
                _buildTableCell('${log.reps}'),
                _buildTableCell('${log.rir}'),
                _buildTableCell('${log.oneRM} kg'),
              ],
            )),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 13,
        ),
      ),
    );
  }
}
