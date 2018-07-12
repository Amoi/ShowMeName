import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';


class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => new _CameraAppState();
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  String imagePath;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    availableCameras().then( (cameras) {
       if(cameras.isEmpty) {
         logError("camera", "camera is null!");
       } else {
         for (CameraDescription cameraDescription in cameras) {
           if(cameraDescription.lensDirection == CameraLensDirection.back) {
             controller = new CameraController(cameraDescription, ResolutionPreset.high);
             // If the controller is updated then update the UI.
             controller.addListener(() {
               if (mounted) setState(() {});
               if (controller.value.hasError) {
                 showInSnackBar('Camera error ${controller.value.errorDescription}');
               }
             });
             try {
               controller.initialize().then((Null) {
                 if (mounted) {
                   setState(() {});
                 }
               });
             } on CameraException catch (e) {
               _showCameraException(e);
             }
           }
         }
       }
    });
  }


  @override
  void dispose() {
    if(controller != null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: const Text('ShowMeName'),
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: new Padding(
                padding: const EdgeInsets.all(1.0),
                child: new Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: new BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          _captureControlRowWidget(),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if(imagePath != null) {
      return Image.file(File(imagePath));
    }

    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        '初始化...',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return new AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: new CameraPreview(controller),
      );
    }
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    if(imagePath != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.red,
            iconSize: 36.0,
            onPressed: () {
              imagePath = null;
              setState(() {
              });
            },
          ),
          IconButton(
            color: Colors.blue,
            iconSize: 36.0,
            icon: Icon(Icons.check),
            onPressed: () {
              logError("image", imagePath);
              Navigator.pop(context,imagePath);
            },
          )
        ],
      );
    }
    return new Center(
      child:
        new IconButton(
          iconSize: 36.0,
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
              controller.value.isInitialized
              ? onTakePictureButtonPressed
              : null,
        ),
    );
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}