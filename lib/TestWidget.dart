import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;

class TestWidget extends StatelessWidget {
  const TestWidget({Key? key}) : super(key: key);

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  void prepareModel() async {
    final interpreter = await Interpreter.fromAsset('model.tflite');

    final inputType = interpreter.getInputTensor(0).type;

    var _outputShape = interpreter.getOutputTensor(0).shape;
    var _outputType = interpreter.getOutputTensor(0).type;


    TensorImage input = TensorImage(inputType);

    File file = await getImageFileFromAssets("1.jpeg");

    
    
    img.Image imageInput = img.decodeImage(file.readAsBytesSync())!;

    var outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);

    input.loadImage(imageInput);

    interpreter.run(input.buffer, outputBuffer.getBuffer());

    print(outputBuffer);
  }

  @override
  Widget build(BuildContext context) {
    prepareModel();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing"),
      ),
      body: const Center(
        child: Image(image: AssetImage("assets/1.jpeg")),
      ),
    );
  }
}
