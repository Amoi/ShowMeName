import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unicorndial/unicorndial.dart';

import 'camera.dart';
import 'service/baidu_recognize.dart';

void main() => runApp(new MyApp());

class IMAGE_TYPE {
  static const CAR = 0;
  static const PLANT = 1;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'ShowMeName'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _childButtons = List<UnicornButton>();
  String _imagePath;
  int _currentType;
  String _result;

  _MyHomePageState() {
    _childButtons.add(UnicornButton(
      label: Chip(label: Text("汽车")),
      currentButton: FloatingActionButton(
        heroTag: "car",
        child: Icon(Icons.local_car_wash),
        onPressed: () {
          Navigator
              .push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => CameraApp()))
              .then((imagePath) {
            fetchPlantResult(imagePath).then((entity) {
              print(entity.result.first);
              setState(() {
                _currentType = IMAGE_TYPE.CAR;
                _imagePath = imagePath;
                _result = entity.result.first.name;
              });
            });
          });
        },
      ),
    ));
    _childButtons.add(UnicornButton(
      label: Chip(label: Text("植物")),
      currentButton: FloatingActionButton(
          heroTag: 'plant',
          child: Icon(Icons.local_florist),
          onPressed: () {
            Navigator
                .push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => CameraApp()))
                .then((imagePath) {
              fetchPlantResult(imagePath).then((entity) {
                print(entity.result.first);
                setState(() {
                  _currentType = IMAGE_TYPE.CAR;
                  _imagePath = imagePath;
                  _result = entity.result.first.name;
                });
              });
            });
          }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _imagePath == null
            ? new Center(
                child: new Text(
                  '请拍摄想要识别的图片',
                ),
              )
            : Column(
                children: <Widget>[
                  Image.file(File(_imagePath)),
                  Text("$_result")
                ],
              ),
      ),
      floatingActionButton: new UnicornDialer(
        hasBackground: false,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.camera_alt),
        childButtons: _childButtons,
      ),
    );
  }
}
