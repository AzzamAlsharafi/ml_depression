import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final screenWidth = queryData.size.width;
    // final screenHeight = queryData.size.height;

    // randomly generate data.
    const int segments = 5;
    final List<List<double>> randomData = List.generate(Random().nextInt(13),
        (index) => List.generate(segments, (index) => Random().nextDouble()));
    randomData.add(List.generate(
        Random().nextInt(segments), (index) => Random().nextDouble()));
    int today = randomData.length - 1;
    randomData.addAll(List.generate(14 - randomData.length, (index) => []));

    return Scaffold(
      appBar: AppBar(
        title: const Text("ML Depression"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [CircleProgress(segments, randomData[today]),
                  Text("${randomData[today].length} / $segments",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                ])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                margin: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "All days ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    ...List.generate(
                      2,
                      (index) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                          7,
                          (innerIndex) {
                            return SizedBox(
                              width: (screenWidth - 20) / 7,
                              height: (screenWidth - 20) / 7,
                              child: Container(
                                  decoration: today == innerIndex + (index * 7)
                                      ? BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 3,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )
                                      : null,
                                  child: CircleProgress(
                                    segments,
                                    randomData[innerIndex + (index * 7)],
                                    borderThickness: 0.4,
                                    dividerThickness: 1,
                                  )),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: FloatingActionButton.extended(
                onPressed: () {},
                label: const Text(
                  "Start test",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(Icons.play_arrow, size: 24),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// This widget represents a circular progress bar, that is divided into segments.
class CircleProgress extends StatelessWidget {
  const CircleProgress(this.segment, this.percents,
      {Key? key,
      this.circleRadius = 0.7,
      this.borderThickness = 0.2,
      this.dividerThickness = 10})
      : super(key: key);

  static CircleProgress getRandom({bool mode = false, bool on = true}) {
    if (mode) {
      if (on) {
        return CircleProgress(
            5, List<double>.generate(5, (index) => Random().nextDouble()),
            borderThickness: 0.4, dividerThickness: 1);
      }
      return const CircleProgress(5, [],
          borderThickness: 0.4, dividerThickness: 1);
    }
    return CircleProgress(
        5,
        List<double>.generate(
            Random().nextInt(5), (index) => Random().nextDouble()));
  }

  // Number of segments.
  final int segment;

  // Percent of each segment.
  final List<double> percents;

  // Determines size of the circle.
  final double circleRadius;

  // Thickness of the border. 1 = border covers the whole circle.
  final double borderThickness;

  final double dividerThickness;

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
          axisLineStyle: AxisLineStyle(
            thickness: borderThickness,
            color: const Color.fromARGB(30, 0, 169, 181),
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
          majorTickStyle: MajorTickStyle(
              length: borderThickness,
              lengthUnit: GaugeSizeUnit.factor,
              thickness: dividerThickness.toDouble(),
              color: Colors.white),
        )
      ],
    );
  }
}
