import 'dart:core';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zoomable_fl_chart/positioned_tap_detector_2.dart';

class ZoomableLineChart extends StatefulWidget {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final Widget Function(double minX, double maxX, double minY, double maxY)
      builder;
  final Function(bool scaling) onScaling;

  const ZoomableLineChart({
    super.key,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.onScaling,
    required this.builder,
  });

  @override
  State<ZoomableLineChart> createState() => _ChartState();
}

class _ChartState extends State<ZoomableLineChart> {
  double minX = double.infinity;
  double maxX = double.infinity;
  double minY = double.infinity;
  double maxY = double.infinity;
  double _minX = 0;
  double _minY = 0;
  double _maxX = 0;
  double _maxY = 0;
  Offset firstPoint = Offset.zero;
  Offset secondPoint = Offset.zero;
  final PositionedTapController _positionedTapController =
      PositionedTapController();
  final GestureArenaTeam _gestureArenaTeam = GestureArenaTeam();

  @override
  void initState() {
    super.initState();

    minX = widget.minX;
    maxX = widget.maxX;
    minY = widget.minY;
    maxY = widget.maxY;
    _minX = minX;
    _maxX = maxX;
    _minY = minY;
    _maxY = maxY;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        debugPrint("onPointerDown");
        widget.onScaling(true);
      },
      onPointerUp: (event) {
        debugPrint("onPointerUp");
      },
      onPointerCancel: (event) {
        debugPrint("onPointerCancel");
      },
      onPointerHover: (event) {
        debugPrint("onPointerHover");
      },
      onPointerSignal: (event) {
        debugPrint("onPointerSignal");
      },
      child: PositionedTapDetector2(
        controller: _positionedTapController,
        child: RawGestureDetector(
          gestures: {
            DoubleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                DoubleTapGestureRecognizer>(
              () => DoubleTapGestureRecognizer(debugOwner: this),
              (DoubleTapGestureRecognizer instance) {
                instance
                  ..onDoubleTapDown = (details) {
                    debugPrint("onDoubleTapDown");
                  }
                  ..onDoubleTap = () {
                    final xRange = maxX - minX;
                    final yRange = maxY - minY;
                    setState(() {
                      minX = minX + xRange * 0.25;
                      maxX = maxX - xRange * 0.25;
                      minY = minY + yRange * 0.25;
                      maxY = maxY - yRange * 0.25;
                    });
                    _minX = minX;
                    _maxX = maxX;
                    _minY = minY;
                    _maxY = maxY;
                  }
                  ..onDoubleTapCancel = () {
                    debugPrint("onDoubleTapCancel");
                  };
              },
            ),
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(debugOwner: this),
              (TapGestureRecognizer instance) {
                instance
                  ..onTapDown = (details) {
                    widget.onScaling(true);
                    debugPrint("onTapDown");
                  }
                  ..onTapUp = (details) {
                    widget.onScaling(false);
                    debugPrint("onTapUp");
                  }
                  ..onTap = () {
                    widget.onScaling(true);
                    debugPrint("onTap");
                  }
                  ..onSecondaryTap = () {
                    widget.onScaling(true);
                    debugPrint("onSecondaryTap");
                  }
                  ..onSecondaryTapDown = (details) {
                    widget.onScaling(true);
                    debugPrint("onSecondaryTapDown");
                  };
              },
            ),
            ScaleGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
              () => ScaleGestureRecognizer(debugOwner: this),
              (ScaleGestureRecognizer instance) {
                instance.team ??= _gestureArenaTeam;
                _gestureArenaTeam.captain = instance;
                instance
                  ..onEnd = (details) {
                    setState(() {
                      minX = _minX;
                      maxX = _maxX;
                      minY = _minY;
                      maxY = _maxY;
                      firstPoint = Offset.zero;
                      secondPoint = Offset.zero;
                    });
                    widget.onScaling(false);
                  }
                  ..onUpdate = (details) {
                    double zoomXDampeningFactor = 0.01;
                    double zoomYDampeningFactor = 0.01;
                    double scaleX =
                        1 + (details.scale - 1) * zoomXDampeningFactor;
                    double scaleY =
                        1 + (details.scale - 1) * zoomYDampeningFactor;
                    debugPrint("scaleX: $scaleX - scaleY: $scaleY");

                    // Calculate the focal point relative to the chart's range
                    double focalX = details.localFocalPoint.dx /
                            context.size!.width *
                            (_maxX - _minX) +
                        _minX;
                    double focalY = details.localFocalPoint.dy /
                            context.size!.height *
                            (_maxY - _minY) +
                        _minY;

                    // Calculate the scaled distance from the focal point to the current bounds
                    double distToLeft = (focalX - _minX) / scaleX;
                    double distToRight = (_maxX - focalX) / scaleX;
                    double distToTop = (focalY - _minY) / scaleY;
                    double distToBottom = (_maxY - focalY) / scaleY;

                    // Apply the new scaled distances to set the new bounds
                    _minX = focalX - distToLeft;
                    _maxX = focalX + distToRight;
                    _minY = focalY - distToTop;
                    _maxY = focalY + distToBottom;

                    // Check for no scale to distinguish from pinch zoom
                    // Calculate the panning factors based on the chart's visible range
                    double panFactorX = (_maxX - _minX) / context.size!.width;
                    double panFactorY = (_maxY - _minY) / context.size!.height;

                    // Calculate panning based on the focal point delta
                    double panX = details.focalPointDelta.dx * panFactorX;
                    double panY = details.focalPointDelta.dy * panFactorY;

                    // Apply panning
                    _minX -= panX;
                    _maxX -= panX;
                    _minY += panY;
                    _maxY += panY;

                    setState(() {
                      if (details.scale != 1) {
                        if (firstPoint == Offset.zero) {
                          firstPoint = details.localFocalPoint;
                        }
                        minX = _minX;
                        maxX = _maxX;
                        minY = _minY;
                        maxY = _maxY;
                        secondPoint = details.localFocalPoint;
                      } else {
                        minX = _minX;
                        maxX = _maxX;
                        minY = _minY;
                        maxY = _maxY;
                        secondPoint = Offset.zero;
                        firstPoint = Offset.zero;
                      }
                    });
                    debugPrint(
                        "firstPoint: $firstPoint - secondPoint: $secondPoint");
                    widget.onScaling(true);
                  }
                  ..onStart = (details) {
                    widget.onScaling(true);
                  };
              },
            ),
            PanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
              () => PanGestureRecognizer(debugOwner: this),
              (PanGestureRecognizer instance) {
                instance.team ??= _gestureArenaTeam;
                // _gestureArenaTeam.captain = instance;
                instance
                  ..onEnd = (details) {
                    debugPrint("pan onEnd");
                    widget.onScaling(false);
                  }
                  ..onUpdate = (DragUpdateDetails details) {
                    // Calculate the focal point relative to the chart's range
                    double focalX = details.localPosition.dx /
                            context.size!.width *
                            (_maxX - _minX) +
                        _minX;
                    double focalY = details.localPosition.dy /
                            context.size!.height *
                            (_maxY - _minY) +
                        _minY;

                    // Calculate the scaled distance from the focal point to the current bounds
                    double distToLeft = (focalX - _minX) / 1;
                    double distToRight = (_maxX - focalX) / 1;
                    double distToTop = (focalY - _minY) / 1;
                    double distToBottom = (_maxY - focalY) / 1;

                    // Apply the new scaled distances to set the new bounds
                    _minX = focalX - distToLeft;
                    _maxX = focalX + distToRight;
                    _minY = focalY - distToTop;
                    _maxY = focalY + distToBottom;

                    // Check for no scale to distinguish from pinch zoom
                    // Calculate the panning factors based on the chart's visible range
                    double panFactorX = (_maxX - _minX) / context.size!.width;
                    double panFactorY = (_maxY - _minY) / context.size!.height;

                    // Calculate panning based on the focal point delta
                    double panX = details.delta.dx * panFactorX;
                    double panY = details.delta.dy * panFactorY;

                    // Apply panning
                    _minX -= panX;
                    _maxX -= panX;
                    _minY += panY;
                    _maxY += panY;

                    setState(() {
                      minX = _minX;
                      maxX = _maxX;
                      minY = _minY;
                      maxY = _maxY;
                      secondPoint = Offset.zero;
                      firstPoint = Offset.zero;
                    });
                    debugPrint(
                        "firstPoint: $firstPoint - secondPoint: $secondPoint");
                    widget.onScaling(true);
                  }
                  ..onStart = (details) {
                    debugPrint("pan onStart");
                    widget.onScaling(true);
                  };
              },
            ),
          },
          child: widget.builder(minX, maxX, minY, maxY),
        ),
      ),
    );
  }

  FlBorderData showBorder() {
    return FlBorderData(
      show: true,
    );
  }
}
