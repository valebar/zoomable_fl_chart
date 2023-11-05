import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zoomable_fl_chart/zoomable_line_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Zoom & Pan Chart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List<FlSpot> _generateSinusSpots(dataRange) {
  List<FlSpot> spots = [];
  for (int i = 0; i < dataRange; i++) {
    spots.add(FlSpot(i.toDouble(), sin(i * pi / 180)));
  }
  return spots;
}

List<FlSpot> _generateCosinusSpots(dataRange) {
  List<FlSpot> spots = [];
  for (int i = 0; i < dataRange; i++) {
    spots.add(FlSpot(i.toDouble(), cos(i * pi / 180)));
  }
  return spots;
}

List<FlSpot> _generateWaveFunction(
    int nPoints,
    double amplitude,
    double frequency,
    double phase,
    double width,
    Function(double) waveFunction,
    double noiseLevel) {
  List<FlSpot> waveFunctionList = [];
  for (int i = 0; i < nPoints; i++) {
    double x = i / nPoints;
    double y = amplitude * waveFunction(2.0 * pi * frequency * (x - phase)) +
        noiseLevel * Random().nextDouble();
    if (x < phase - width / 2.0 || x > phase + width / 2.0) {
      y = 0.0;
    }
    waveFunctionList.add(FlSpot(x, y));
  }
  return waveFunctionList;
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ZoomableLineChart(
              minX: 0,
              maxX: 100,
              minY: -1,
              maxY: 1,
              builder: _builderFunction,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _builderFunction(double minX, double maxX, double minY, double maxY) {
    return LineChart(
      duration: Duration.zero,
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(
          show: true,
        ),
        lineBarsData: {
          "sinus": _generateSinusSpots(100000),
          "cosinus": _generateCosinusSpots(100001),
        }
            .values
            .toList()
            .map(
              (v) => LineChartBarData(
                spots:
                    v, // Getting filtered spots based on startRange and endRange
                isCurved: false,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                color: v.length > 100000 ? Colors.red : Colors.blue,
              ),
            )
            .toList(),
        lineTouchData: const LineTouchData(enabled: true),
      ),
    );
  }
}
