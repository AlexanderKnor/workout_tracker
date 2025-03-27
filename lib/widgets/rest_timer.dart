// lib/widgets/rest_timer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late Timer _timer;
  late int _secondsRemaining;
  bool _isPaused = false;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialDuration;
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.initialDuration),
    );
    _startTimer();
    _progressController.reverse(from: 1.0); // Countdown animation
    HapticFeedback.mediumImpact(); // Vibration feedback when timer starts
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer.cancel();
            widget.onTimerComplete();
          }
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;

      if (_isPaused) {
        // Pause the animation
        _progressController.stop();
      } else {
        // Resume the animation
        _progressController.reverse(
          from: _secondsRemaining / widget.initialDuration,
        );
      }
    });
    HapticFeedback.lightImpact();
  }

  void _skipTimer() {
    HapticFeedback.mediumImpact();
    widget.onSkip?.call();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF3D85C6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.timer,
                  color: Color(0xFF3D85C6),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "SATZPAUSE",
                style: TextStyle(
                  color: Color(0xFF3D85C6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Timer display
          Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress indicator
              SizedBox(
                height: 180,
                width: 180,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _progressController.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isPaused
                            ? Color(0xFFF1A33C) // Orange when paused
                            : Color(0xFF3D85C6), // Blue when running
                      ),
                    );
                  },
                ),
              ),

              // Time remaining
              Column(
                children: [
                  Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "verbleibend",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pause/Resume button
              ElevatedButton.icon(
                onPressed: _togglePause,
                icon: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  size: 20,
                ),
                label: Text(
                  _isPaused ? "FORTSETZEN" : "PAUSE",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPaused
                      ? Color(0xFF44CF74) // Green when paused (resume)
                      : Color(0xFFF1A33C), // Orange when running (pause)
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Skip button
              ElevatedButton.icon(
                onPressed: _skipTimer,
                icon: Icon(
                  Icons.skip_next,
                  size: 20,
                ),
                label: Text(
                  "ÜBERSPRINGEN",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1C2F49),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
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
