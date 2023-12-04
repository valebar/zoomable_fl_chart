import 'dart:core';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zoomable_fl_chart/positioned_tap_detector_2.dart';

class ZoomableLineChart extends StatefulWidget {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final Widget Function(double minX, double maxX, double minY, double maxY, bool showMarker)
      builder;
  final Function(bool scaling) onScaling;
  final bool dragEnabled;
  final bool scaleEnabled;
  final bool longPressEnabled;

  const ZoomableLineChart({
    super.key,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.onScaling,
    required this.dragEnabled,
    required this.scaleEnabled,
    this.longPressEnabled = false,
    required this.builder,
  });

  @override
  State<ZoomableLineChart> createState() => _ZoomanleLineChartState();
}

class _ZoomanleLineChartState extends State<ZoomableLineChart> {
  double minX = double.infinity;
  double maxX = double.infinity;
  double minY = double.infinity;
  double maxY = double.infinity;
  double _minX = 0;
  double _minY = 0;
  double _maxX = 0;
  double _maxY = 0;
  bool _showMarker = false;
  Offset firstPoint = Offset.zero;
  Offset secondPoint = Offset.zero;

  final PositionedTapController _positionedTapController =
      PositionedTapController();
  final GestureArenaTeam _gestureArenaTeam = GestureArenaTeam();
  late Map<Type, GestureRecognizerFactory> _gestures;

  int _pointerCounter = 0;

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

  void _handlePointerDown(PointerDownEvent event) {
    _pointerCounter++;
  }

  void _handlePointerUp(PointerUpEvent event) {
    _pointerCounter--;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pointerCounter = 0;
  }

  void _handleOnTapUp(TapUpDetails details) {
    widget.onScaling(false);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    widget.onScaling(true);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    double zoomXDampeningFactor = 0.01;
    double zoomYDampeningFactor = 0.01;
    double scaleX = 1 + (details.scale - 1) * zoomXDampeningFactor;
    double scaleY = 1 + (details.scale - 1) * zoomYDampeningFactor;

    // Calculate the focal point relative to the chart's range
    double focalX =
        details.localFocalPoint.dx / context.size!.width * (_maxX - _minX) +
            _minX;
    double focalY =
        details.localFocalPoint.dy / context.size!.height * (_maxY - _minY) +
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
  }

  void _handleScaleEnd(ScaleEndDetails details) {
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

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    double panFactorX = (_maxX - _minX) / context.size!.width;
    double panX = details.delta.dx * panFactorX;
    _minX -= panX;
    _maxX -= panX;
    setState(() {
      minX = _minX;
      maxX = _maxX;
      minY = _minY;
      maxY = _maxY;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    double panFactorY = (_maxY - _minY) / context.size!.height;
    double panY = details.delta.dy * panFactorY;
    _minY += panY;
    _maxY += panY;
    setState(() {
      minX = _minX;
      maxX = _maxX;
      minY = _minY;
      maxY = _maxY;
    });
  }

  void _handleOnLongPress() {
    setState(() => _showMarker = !_showMarker);
    _positionedTapController.onLongPress;
  }
  Map<Type, GestureRecognizerFactory> _createGestures({
    required bool dragEnabled,
    required bool scaleEnabled,
    required int pointerCounter,
  }) {
    //check
    final gestureSettings = MediaQuery.gestureSettingsOf(context);
    return <Type, GestureRecognizerFactory>{
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(debugOwner: this),
        (recognizer) {
          recognizer
            ..onTapDown = _positionedTapController.onTapDown
            ..onTapUp = _handleOnTapUp
            ..onTap = _positionedTapController.onTap
            ..onSecondaryTap = _positionedTapController.onSecondaryTap
            ..onSecondaryTapDown = _positionedTapController.onTapDown;
        },
      ),
      LongPressGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(debugOwner: this),
        (recognizer) {
          recognizer.onLongPress = _handleOnLongPress;
        },
      ),
      if (dragEnabled)
        VerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(debugOwner: this),
          (recognizer) {
            recognizer
              ..gestureSettings = gestureSettings
              ..team ??= _gestureArenaTeam
              ..onUpdate = (details) {
                _handleVerticalDragUpdate(details);
              };
          },
        ),
      if (dragEnabled)
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(debugOwner: this),
            (recognizer) {
          recognizer
            ..gestureSettings = gestureSettings
            ..team ??= _gestureArenaTeam
            ..onUpdate = (details) {
              _handleHorizontalDragUpdate(details);
            };
        }),
      if (scaleEnabled)
        ScaleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer(debugOwner: this),
          (recognizer) {
            recognizer
              ..onStart = _handleScaleStart
              ..onUpdate = _handleScaleUpdate
              ..onEnd = _handleScaleEnd
              ..team ??= _gestureArenaTeam;
            _gestureArenaTeam.captain = recognizer;
          },
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    //creates gestures and dragEnabled if true they are enabled else disabled
    _gestures = _createGestures(
      dragEnabled: widget.dragEnabled,
      scaleEnabled: widget.scaleEnabled,
      pointerCounter: _pointerCounter,
    );

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _onPointerCancel,
      onPointerHover: (event) {
        debugPrint("onPointerHover");
      },
      onPointerSignal: (event) {
        debugPrint("onPointerSignal");
      },
      child: RawGestureDetector(
        gestures: _gestures,
        child: widget.builder(minX, maxX, minY, maxY, _showMarker),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
