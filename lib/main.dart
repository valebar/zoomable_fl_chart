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
    final x = i * pi / 180;
    final val = sin(x) * exp(-x / 5) + cos(x) * log(x + 1) - tan(x / 10);
    spots.add(FlSpot(i.toDouble(), val));
    //spots.add(FlSpot(i.toDouble(), sin(x)));
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

class _MyHomePageState extends State<MyHomePage> {
  bool _isScaling = false;
  int _pageIndex = 0;
  final PageController _pageController = PageController();
  final _spots = <String, List<FlSpot>>{
    "sinus": _generateSinusSpots(100000),
    "cosinus": _generateCosinusSpots(100000),
  };
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page == _pageController.page!.roundToDouble()) {
        setState(() => _pageIndex = _pageController.page!.toInt());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: PageView(
            controller: _pageController,
            physics: _isScaling ? const NeverScrollableScrollPhysics() : null,
            children: [_page1(), _page2()],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _pageIndex,
            onTap: (index) {
              setState(() => _pageIndex = index);
              _pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: "Chart",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label: "Image",
              ),
            ],
          )),
    );
  }

  _page1() {
    return ListView(
      physics: _isScaling ? const NeverScrollableScrollPhysics() : null,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: ZoomableLineChart(
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
            minX: 620.0,
            maxX: 1300.0,
            minY: -6.6,
            maxY: 6.6,
            builder: _builderFunction,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: ZoomableLineChart(
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
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
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
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
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
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
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
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
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
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
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
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
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
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
            onScaling: (scaling) => Future.delayed(
                Duration.zero, () => setState(() => _isScaling = scaling)),
            minX: 0,
            maxX: 100,
            minY: -1,
            maxY: 1,
            builder: _builderFunction,
          ),
        ),
      ],
    );
  }

  _page2() {
    return Center(
        child:
            Image.network("https://cdn.wallpapersafari.com/12/11/1Q7KOp.jpg"));
  }

  Widget _builderFunction(double minX, double maxX, double minY, double maxY) {
    final spots = {
      "sinus": _spots["sinus"]!
          .where((element) =>
              element.x >= minX - (maxX - minX) * 0.3 &&
              element.x <= maxX + (maxX - minX) * 0.3 &&
              element.y >= minY - (maxY - minY) * 0.3 &&
              element.y <= maxY + (maxY - minY) * 0.3)
          .toList(),
      "cosinus": _spots["cosinus"]!
          .where((element) =>
              element.x >= minX - (maxX - minX) * 0.3 &&
              element.x <= maxX + (maxX - minX) * 0.3 &&
              element.y >= minY - (maxY - minY) * 0.3 &&
              element.y <= maxY + (maxY - minY) * 0.3)
          .toList(),
    };
    //final spots = _spots;
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
        lineBarsData: spots.keys
            .toList()
            .map(
              (k) => LineChartBarData(
                spots: fillGapsInSpots(spots[k]!, 1),
                isCurved: false,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                color: k == "sinus" ? Colors.red : Colors.blue,
              ),
            )
            .toList(),
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }

  List<FlSpot> fillGapsInSpots(List<FlSpot> spots, double gapThreshold) {
    final localSpots = List.from(spots);
    // Ensure the list is sorted based on the x-value
    localSpots.sort((a, b) => a.x.compareTo(b.x));

    List<FlSpot> filledSpots = [];
    if (localSpots.isEmpty) {
      return filledSpots;
    }
    for (int i = 0; i < localSpots.length - 1; i++) {
      // Add the current spot to the new list
      filledSpots.add(localSpots[i]);

      // Calculate the difference between consecutive x-values
      if (localSpots.length > i + 1) {
        double diff = localSpots[i + 1].x - localSpots[i].x;

        // If the difference exceeds our threshold, we consider this a gap
        if (diff > gapThreshold) {
          // Insert a null spot to create a gap in the chart
          filledSpots.add(FlSpot(localSpots[i].x + diff / 2, double.nan));
        }
      }
    }

    // Add the last spot to the list since we are not checking it in the loop
    filledSpots.add(localSpots.last);

    return filledSpots;
  }
}
