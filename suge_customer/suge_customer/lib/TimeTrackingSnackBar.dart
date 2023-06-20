import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:suge_customer/util/common.dart';

class TimeTrackingSnackBar extends SnackBar {
  TimeTrackingSnackBar({
    required Duration duration,
    required String message,
    String? actionLabel,
    void Function()? onActionPressed,
  }) : super(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          content: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      if (duration != null) TimeTracker(duration: duration),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          child: QrImageView(
                              data: message,
                              size: 200,
                              embeddedImageStyle: QrEmbeddedImageStyle(
                                size: const Size(
                                  100,
                                  100,
                                ),
                              ))),
                      Text(
                        "생성된 QR코드를 카운터에 제시해주세요.",
                        style: textStyle15BBlack,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  onPressed: onActionPressed!,
                )
              : null,
          duration: duration,
        );
}

class TimeTracker extends StatefulWidget {
  final Duration duration;

  TimeTracker({required this.duration});

  @override
  _TimeTrackerState createState() => _TimeTrackerState();
}

class _TimeTrackerState extends State<TimeTracker> {
  late Timer _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.duration.inSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;

    return Text(
      '$minutes : $seconds',
      style: TextStyle(fontWeight: FontWeight.bold, color: customer),
    );
  }
}
