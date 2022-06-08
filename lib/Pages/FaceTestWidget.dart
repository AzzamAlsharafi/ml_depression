import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// TODO: what happens if user refuses camera permission

Future<CameraDescription> getCamera() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get the front camera from the list of available cameras.
  return cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.front);
}

class FaceTestWidget extends StatefulWidget {
  const FaceTestWidget({Key? key}) : super(key: key);

  @override
  State<FaceTestWidget> createState() => _FaceTestWidgetState();
}

class _FaceTestWidgetState extends State<FaceTestWidget> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  bool cameraReady = false; // true if camera is ready to be used

  bool hasPicture = false; // true if user has already taken a picture
  String imagePath = ""; // path to the image taken by the user

  void perpareCamera() async {
    if (!cameraReady) {
      getCamera().then((value) {
        controller = CameraController(value, ResolutionPreset.max);
        controller.initialize().then((value) {
          setState(() {
            cameraReady = true;
          });
        });
      });
    }
  }

  Widget getCameraPreview() {
    if (cameraReady) {
      return CameraPreview(controller);
    }
    perpareCamera();
    return Container(color: Colors.black,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: hasPicture
                  ? Image.file(
                      File(imagePath),
                      scale: 1,
                    )
                  : getCameraPreview(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FloatingActionButton.extended(
              onPressed: () async {
                if (hasPicture) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Retake picture?"),
                          content: const Text(
                              "Are you sure you want to replace the current picture?"),
                            actions: [
                              TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: Text("No")),
                              TextButton(onPressed: (){
                                setState(() {
                                  hasPicture = false;
                                  imagePath = "";
                                  Navigator.pop(context);
                                });
                              }, child: Text("Yes")),
                            ],
                        );
                      });
                } else {
                  try {
                    if (cameraReady) {
                      final image = await controller.takePicture();
                      controller.dispose();
                      cameraReady = false;

                      setState(() {
                        hasPicture = true;
                        imagePath = image.path;
                      });
                    }
                  } catch (e) {
                    print(e);
                  }
                }
              },
              label: Text(hasPicture ? "Retake picture" : "Take picture"),
              icon: const Icon(Icons.camera_alt),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (cameraReady) {
      controller.dispose();
    }
    super.dispose();
  }
}

class NoPictureWidget extends StatelessWidget {
  const NoPictureWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            color: Colors.grey.shade400,
            size: 200,
          ),
          Text(
            "No picture taken",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
