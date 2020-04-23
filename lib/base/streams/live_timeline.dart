import 'dart:async';

import 'package:fastotv_common/colors.dart';
import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:flutter/material.dart';

class LiveTimeLine extends StatefulWidget {
  final ProgrammeInfo programmeInfo;
  final double width;
  final double height;
  final Color color;

  LiveTimeLine({@required this.programmeInfo, @required this.width, this.height, this.color});

  @override
  createState() => LiveTimeLineState();
}

class LiveTimeLineState<T extends LiveTimeLine> extends State<T> {
  static const REFRESH_TIMELINE_SEC = 1;

  Timer _timer;
  double _width = 0;

  int start;
  int stop;

  @override
  void initState() {
    super.initState();
    initTimeline(widget.programmeInfo);
  }

  @override
  void didUpdateWidget(LiveTimeLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.programmeInfo != widget.programmeInfo) {
      initTimeline(widget.programmeInfo);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 5;
    return Stack(children: <Widget>[
      Container(color: widget.color ?? Theme.of(context).accentColor, height: height, width: _width),
      Container(
          color: CustomColor().themeBrightnessColor(context).withOpacity(0.1), height: height, width: widget.width)
    ]);
  }

  @protected
  void initTimeline(ProgrammeInfo programmeInfo) {
    if (programmeInfo == null) {
      return;
    }
    start = programmeInfo.start;
    stop = programmeInfo.stop;
    _update(programmeInfo);
    _timer = Timer.periodic(Duration(seconds: REFRESH_TIMELINE_SEC), (Timer t) {
      _update(programmeInfo);
    });
  }

  // private:
  void _update(ProgrammeInfo programmeInfo) {
    _syncControls(programmeInfo);
    if (mounted) {
      setState(() {});
    }
  }

  void _syncControls(ProgrammeInfo programmeInfo) {
    if (programmeInfo == null) {
      return;
    }

    final curUtc = DateTime.now().millisecondsSinceEpoch;
    final totalTime = stop - start;
    final passed = curUtc - start;
    double inPercent = 0;
    if (totalTime != 0) {
      inPercent = passed / totalTime;
    }

    if (curUtc > stop) {
      _width = 0;
    } else {
      _width = widget.width * inPercent;
    }
  }
}
