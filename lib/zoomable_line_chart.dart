import 'dart:core';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ZoomableLineChart extends StatefulWidget {
  //final Map<String, List<FlSpot>> spots;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final Widget Function(double minX, double maxX, double minY, double maxY)?
      builder;

  ZoomableLineChart({
    super.key,
    //required this.spots,
    required this.builder,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
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
    return GestureDetector(
      onLongPress: () {
        //_setInitialRanges();
        setState(() {
          minX = widget.minX!;
          maxX = widget.maxX!;
          minY = widget.minY!;
          maxY = widget.maxY!;
        });
      },
      onDoubleTap: () {
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
      },
      //onScaleStart: (details) {},
      onScaleUpdate: (ScaleUpdateDetails details) {
        //setState(() {
        // Scale factors for X and Y
        double zoomXDampeningFactor = 0.01;
        //((_maxX - _minX) / context.size!.width).abs() * .1;
        double zoomYDampeningFactor = 0.01;
        //((_maxY - _minY) / context.size!.height).abs() * .1;
        double scaleX =
            1 + (details.horizontalScale - 1) * zoomXDampeningFactor;
        double scaleY = 1 + (details.verticalScale - 1) * zoomYDampeningFactor;
        debugPrint("scaleX: $scaleX - scaleY: $scaleY");

        // Calculate the focal point relative to the chart's range
        double focalX =
            details.localFocalPoint.dx / context.size!.width * (_maxX - _minX) +
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
        debugPrint("firstPoint: $firstPoint - secondPoint: $secondPoint");
      },
      onScaleEnd: (details) => setState(() {
        minX = _minX;
        maxX = _maxX;
        minY = _minY;
        maxY = _maxY;
        firstPoint = Offset.zero;
        secondPoint = Offset.zero;
      }),
      child: Stack(
        children: [
          //widget.builder == null
          // ? LineChart(
          //     duration: Duration.zero,
          //     LineChartData(
          //       minX: minX,
          //       maxX: maxX,
          //       minY: minY,
          //       maxY: maxY,
          //       clipData: const FlClipData.all(),
          //       gridData: const FlGridData(show: true),
          //       titlesData: const FlTitlesData(show: true),
          //       borderData: showBorder(),
          //       lineBarsData: getSpots()
          //           .values
          //           .toList()
          //           .map(
          //             (v) => LineChartBarData(
          //               spots:
          //                   v, // Getting filtered spots based on startRange and endRange
          //               isCurved: false,
          //               dotData: const FlDotData(show: false),
          //               belowBarData: BarAreaData(show: false),
          //               color: v.length > 100000 ? Colors.red : Colors.blue,
          //             ),
          //           )
          //           .toList(),
          //       lineTouchData: const LineTouchData(enabled: false),
          //     ),
          //   )
          //? const Text("builder is null")
          /*:*/ widget.builder!(minX, maxX, minY, maxY),
          Positioned.fromRect(
              rect: Rect.fromPoints(firstPoint, secondPoint),
              child: Container(
                  //color: const Color.fromARGB(134, 248, 187, 251),
                  )),
        ],
      ),
    );
  }

  FlBorderData showBorder() {
    return FlBorderData(
      show: true,
    );
  }

  // Map<String, List<FlSpot>> getSpots() {
  //   final spots = Map<String, List<FlSpot>>.from(widget.spots);
  //   return spots;
  // }

  // Function to set the initial ranges based on the data
  // void _setInitialRanges() {
  //   for (String key in widget.spots.keys) {
  //     if (minX == double.infinity) {
  //       minX = widget.spots[key]!
  //           .reduce((min, spot) => spot.x < min.x ? spot : min)
  //           .x;
  //       maxX = widget.spots[key]!
  //           .reduce((max, spot) => spot.x > max.x ? spot : max)
  //           .x;
  //       minY = widget.spots[key]!
  //           .reduce((min, spot) => spot.y < min.y ? spot : min)
  //           .y;
  //       maxY = widget.spots[key]!
  //           .reduce((max, spot) => spot.y > max.y ? spot : max)
  //           .y;
  //       _minX = minX;
  //       _maxX = maxX;
  //       _minY = minY;
  //       _maxY = maxY;
  //     } else {
  //       final lminX = widget.spots[key]!
  //           .reduce((min, spot) => spot.x < min.x ? spot : min)
  //           .x;
  //       if (lminX < minX) {
  //         minX = lminX;
  //       }
  //       final lmaxX = widget.spots[key]!
  //           .reduce((max, spot) => spot.x > max.x ? spot : max)
  //           .x;
  //       if (lmaxX > maxX) {
  //         maxX = lmaxX;
  //       }
  //       final lminY = widget.spots[key]!
  //           .reduce((min, spot) => spot.y < min.y ? spot : min)
  //           .y;
  //       if (lminY < minY) {
  //         minY = lminY;
  //       }
  //       final lmaxY = widget.spots[key]!
  //           .reduce((max, spot) => spot.y > max.y ? spot : max)
  //           .y;
  //       if (lmaxY > maxY) {
  //         maxY = lmaxY;
  //       }
  //       _minX = minX;
  //       _maxX = maxX;
  //       _minY = minY;
  //       _maxY = maxY;
  //     }
  //   }
  // }
}
