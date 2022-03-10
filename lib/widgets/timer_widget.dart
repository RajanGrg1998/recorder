import 'dart:async';

import 'package:flutter/material.dart';

class TimerController extends ValueNotifier<bool> {
  TimerController({bool isPlaying = false}) : super(isPlaying);

  void startTimer() => value = true;
  void stopTimer() => value = false;
}

class TimerWideget extends StatefulWidget {
  final TimerController timerController;
  const TimerWideget({Key? key, required this.timerController})
      : super(key: key);

  @override
  State<TimerWideget> createState() => _TimerWidegetState();
}

class _TimerWidegetState extends State<TimerWideget> {
  Duration duration = Duration();
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.timerController.addListener(() {
      if (widget.timerController.value) {
        startTimer();
      } else {
        stopTimer();
      }
    });
  }

  void reset() => setState(() => duration = Duration());

  void addTime() {
    final addSeconds = 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void startTimer({bool resets = true}) {
    if (!mounted) return;
    if (resets) {
      reset();
    }

    timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => addTime(),
    );
  }

  void stopTimer({bool resets = true}) {
    if (!mounted) return;
    if (resets) {
      reset();
    }

    setState(() => timer?.cancel());
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Text('$hours:$minutes:$seconds',
        style: TextStyle(color: Colors.white));
  }
}
