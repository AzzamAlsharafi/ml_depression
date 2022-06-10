import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera_windows/camera_windows.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

import '../constants.dart';

// TODO: what happens if user refuses camera permission

// get the front camera
Future<CameraDescription> getCamera() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await CameraPlatform.instance.availableCameras();

  // Get the front camera from the list of available cameras.
  return cameras.firstWhere(
      (element) => element.lensDirection == CameraLensDirection.front);
}

class FaceTestWidget extends StatefulWidget {
  const FaceTestWidget({Key? key}) : super(key: key);

  @override
  State<FaceTestWidget> createState() => _FaceTestWidgetState();
}

class _FaceTestWidgetState extends State<FaceTestWidget> {
  late int cameraId;
  bool cameraReady = false; // true if camera is ready to be used
  late Size previewSize;

  bool hasPicture = false; // true if user has already taken a picture
  String imagePath = ""; // path to the image taken by the user

  // prepare the camera for use
  void perpareCamera() async {
    if (!cameraReady) {
      final cameraDes = await getCamera();

      cameraId = await CameraPlatform.instance
          .createCamera(cameraDes, ResolutionPreset.max, enableAudio: false);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
        imageFormatGroup: ImageFormatGroup.unknown,
      );

      final CameraInitializedEvent event = await initialized;

      setState(() {
        previewSize = Size(
        event.previewWidth,
        event.previewHeight,);

        cameraReady = true;
      });

      // getCamera().then((value) {
      //   controller = CameraController(value, ResolutionPreset.medium,
      //       enableAudio: false);
      //   controller.initialize().then((value) {
      //     setState(() {
      //       cameraReady = true;
      //     });
      //   });
      // });
    }
  }

  // get the camera preview, but first prepare the camera if it's not ready yet.
  Widget getCameraPreview() {
    if (cameraReady) {
      Widget preview = CameraPlatform.instance.buildPreview(cameraId);
      return AspectRatio(aspectRatio: previewSize.width / previewSize.height, child: preview,);
    }
    perpareCamera();
    return Container(
      color: Colors.black,
    );
  }

  // check if the user has already taken a picture, if so then update hasPicture and imagePath.
  void checkIfHasPicture() async {
    final prefs = await SharedPreferences.getInstance();
    hasPicture = prefs.getBool(hasPictureKey) ?? false;

    if (hasPicture) {
      imagePath = prefs.getString(picturePathKey) ?? "";
    }
  }

  // takes a picture and save it.
  void takeAndSavePicture() async {
    final image = await CameraPlatform.instance.takePicture(cameraId);
    // controller.dispose();
    // cameraReady = false;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(hasPictureKey, true);

    // final directory = await getApplicationDocumentsDirectory();
    String path = image.path;
    await image.saveTo(path);
    prefs.setString(picturePathKey, path);

    setState(() {
      hasPicture = true;
      imagePath = path;
    });
  }

  // remove the picture.
  void removePicture() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(hasPictureKey, false);

    File file = File(prefs.getString(picturePathKey) ?? "");
    file.delete();

    setState(() {
      hasPicture = false;
      imagePath = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    checkIfHasPicture();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Column(
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
              constraints: BoxConstraints(maxHeight: 500, maxWidth: 900),
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
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("No")),
                              TextButton(
                                  onPressed: () async {
                                    removePicture();
      
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Yes")),
                            ],
                          );
                        });
                  } else {
                    try {
                      if (cameraReady) {
                        takeAndSavePicture();
                      } else {
                        perpareCamera();
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
        )],
      ),
    );
  }

  void disposeCamera() async {
    if (cameraReady) {
      await CameraPlatform.instance.dispose(cameraId);
    }
  }

  @override
  void dispose() {
    disposeCamera();
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
