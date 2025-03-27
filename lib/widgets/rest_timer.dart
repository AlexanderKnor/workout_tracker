// lib/widgets/rest_timer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class RestTimer extends StatefulWidget {
  final int initialDuration; // in seconds
  final VoidCallback onTimerComplete;
  final VoidCallback? onSkip;

  const RestTimer({
    Key? key,
    required this.initialDuration,
    required this.onTimerComplete,
    this.onSkip,
  }) : super(key: key);

  @override
  _RestTimerState createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with TickerProviderStateMixin {
  late int _secondsRemaining;
  bool _isNegative = false;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Initial seconds remaining from the state
    final state = Provider.of<WorkoutTrackerState>(context, listen: false);
    _secondsRemaining = state.currentRestTime;
    _isNegative = _secondsRemaining <= 0;

    // Animation controller for normal countdown
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.initialDuration),
    );

    // Setze den Startwert für die Animation basierend auf der verbleibenden Zeit
    double initialAnimationValue = _secondsRemaining / widget.initialDuration;
    initialAnimationValue = initialAnimationValue.clamp(0.0, 1.0);
    _progressController.value = initialAnimationValue;

    // Starte die Animation nur, wenn Zeit übrig ist
    if (initialAnimationValue > 0) {
      _progressController.reverse(from: initialAnimationValue);
    }

    HapticFeedback.mediumImpact();
  }

  String _formatTime(int seconds) {
    bool negative = seconds < 0;
    seconds = seconds.abs();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${negative ? "-" : ""}${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_isNegative) {
      return Color(0xFFF95738); // Static red for negative time
    } else if (_secondsRemaining < 5) {
      return Color(0xFFF1A33C); // Yellow/Orange for last few seconds
    } else {
      return Color(0xFF3D85C6); // Blue for normal time
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutTrackerState>(
      builder: (context, state, child) {
        return ValueListenableBuilder<int>(
            valueListenable: state.timerNotifier,
            builder: (context, timerValue, _) {
              // Update local state from the notifier
              _secondsRemaining = timerValue;
              _isNegative = _secondsRemaining <= 0;

              return AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF14253D),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _isNegative
                                ? _getTimerColor().withOpacity(0.15)
                                : Colors.black.withOpacity(0.15),
                            blurRadius: _isNegative ? 8 : 6,
                            spreadRadius: _isNegative ? 1 : 0,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: _isNegative
                            ? Border.all(
                                color: _getTimerColor().withOpacity(0.4),
                                width: 1.5,
                              )
                            : null,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Timer progress and display
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Base circle
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1A2D4A),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getTimerColor().withOpacity(0.15),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),

                              // Timer track
                              Container(
                                width: 64,
                                height: 64,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 4,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),

                              // Progress indicator
                              _isNegative
                                  ? Container(
                                      width: 64,
                                      height: 64,
                                      child: CircularProgressIndicator(
                                        value: 1.0, // Full circle
                                        strokeWidth: 4,
                                        strokeCap: StrokeCap.round,
                                        color: _getTimerColor(),
                                      ),
                                    )
                                  : Container(
                                      width: 64,
                                      height: 64,
                                      child: CircularProgressIndicator(
                                        value: _secondsRemaining /
                                            widget.initialDuration,
                                        strokeWidth: 4,
                                        strokeCap: StrokeCap.round,
                                        color: _getTimerColor(),
                                      ),
                                    ),

                              // Time text
                              Text(
                                _formatTime(_secondsRemaining),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: _isNegative
                                      ? _getTimerColor()
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16),

                          // Timer status information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header with icon and text
                                Row(
                                  children: [
                                    Icon(
                                      _isNegative
                                          ? Icons.timer_off_outlined
                                          : Icons.timer_outlined,
                                      color: _getTimerColor(),
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      _isNegative
                                          ? "PAUSE ÜBERSCHRITTEN"
                                          : "SATZPAUSE",
                                      style: TextStyle(
                                        color: _getTimerColor(),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),

                                if (_isNegative)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 4,
                                          width: 4,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _getTimerColor(),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Nächster Satz",
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Skip button
                          InkWell(
                            onTap: widget.onSkip,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.skip_next,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Skip",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            });
      },
    );
  }
}
