import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Depression',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("ML Depression"),
        ),
        body: const HomeApp(),
      ),
    );
  }
}

class HomeApp extends StatelessWidget {
  const HomeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircleProgress(5, [0.0, 1, 0.4]));
  }
}

// This widget represents a circular progress bar, that is divided into segments.
// Accepts two parametrs: number of segments, a list of values, which is the percent of each segment.
class CircleProgress extends StatelessWidget {
  const CircleProgress(this.segment, this.percents, {Key? key})
      : super(key: key);

  final int segment;
  final List<double> percents;

  // Determines size of the circle.
  static const circleRadius = 0.7;

  // Thickness of the border. 1 = border covers the whole circle.
  static const borderThickness = 0.2;

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: [
        // Create primary radial axis
        RadialAxis(
          minimum: 0,
          maximum: segment.toDouble(),
          interval: 1,
          showLabels: false,
          showTicks: false,
          startAngle: 270,
          endAngle: 270,
          radiusFactor: circleRadius,
          axisLineStyle: const AxisLineStyle(
            thickness: borderThickness,
            color: Color.fromARGB(30, 0, 169, 181),
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          ranges: [
            GaugeRange(
              startValue: 0,
              endValue: segment.toDouble(),
              color: Colors.blueGrey,
              startWidth: 0.04,
              endWidth: 0.04,
              sizeUnit: GaugeSizeUnit.factor,
            ),
          ],
          pointers: List<GaugePointer>.generate(
            percents.length,
            (index) => RangePointer(
              value: (percents.length - index).toDouble(),
              width: borderThickness,
              sizeUnit: GaugeSizeUnit.factor,
              pointerOffset: 0,
              color: HSVColor.fromAHSV(
                      1, percents[percents.length - 1 - index] * 100, 1, 1)
                  .toColor(),
            ),
          ),
        ),
        // Create secondary radial axis for segmented line
        RadialAxis(
          minimum: 0,
          maximum: segment.toDouble(),
          interval: 1,
          showLabels: false,
          showTicks: true,
          showAxisLine: false,
          offsetUnit: GaugeSizeUnit.factor,
          minorTicksPerInterval: 0,
          startAngle: 270,
          endAngle: 270,
          radiusFactor: circleRadius,
          majorTickStyle: const MajorTickStyle(
              length: borderThickness,
              lengthUnit: GaugeSizeUnit.factor,
              thickness: 10,
              color: Colors.white),
        )
      ],
    );
  }
}
