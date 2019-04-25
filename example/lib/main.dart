import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';
import 'package:scan_image/scan_image.dart';

enum Filter { magic, sepia, gamma, monochrome }

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _imagePath = 'Unknown';

  String _directoryPath;
  Filter currentFilter = Filter.magic;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _getDirectoryPath();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String imagePath;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      imagePath = await EdgeDetection.detectEdge;
    } on PlatformException {
      imagePath = 'Failed to get cropped image path.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _imagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Select a Filter'),
        ),
        body: Stack(
          children: <Widget>[
            Positioned(
              left: 0.0,
              bottom: 0.0,
              top: 0.0,
              right: 0.0,
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 100.0),
                child: FutureBuilder(
                  future: _getFilterWidget(currentFilter, false),
                  builder: (context, AsyncSnapshot<Widget> snapShot) {
                    if (snapShot.hasData == true) {
                      return snapShot.data;
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
            buildTiles()
          ],
        ),
      ),
    );
  }

  Widget buildTiles() {
    return Positioned(
      left: 0.0,
      bottom: 0.0,
      right: 0.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    height: 60.0,
                    width: 60.0,
                    padding: EdgeInsets.all(2.0),
                    child: FutureBuilder(
                      future: _getFilterWidget(Filter.magic, true),
                      builder: (context, AsyncSnapshot<Widget> snapShot) {
                        if (snapShot.hasData == true) {
                          return snapShot.data;
                        } else {
                          return Center(
                              child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 1.0,
                          ));
                        }
                      },
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      currentFilter = Filter.magic;
                    });
                  },
                ),
                Text("Magic Filter", style: TextStyle(color: Colors.white))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                      padding: EdgeInsets.all(2.0),
                      child: FutureBuilder(
                        future: _getFilterWidget(Filter.sepia, true),
                        builder: (context, AsyncSnapshot<Widget> snapShot) {
                          if (snapShot.data != null) {
                            return snapShot.data;
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 1.0,
                            ));
                          }
                        },
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        currentFilter = Filter.sepia;
                      });
                    }),
                Text("Sepia", style: TextStyle(color: Colors.white))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                      padding: EdgeInsets.all(2.0),
                      child: FutureBuilder(
                        future: _getFilterWidget(Filter.gamma, true),
                        builder: (context, AsyncSnapshot<Widget> snapShot) {
                          if (snapShot.data != null) {
                            return snapShot.data;
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 1.0,
                            ));
                          }
                        },
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        currentFilter = Filter.gamma;
                      });
                    }),
                Text("Gamma", style: TextStyle(color: Colors.white))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                      padding: EdgeInsets.all(2.0),
                      child: new FutureBuilder(
                        future: _getFilterWidget(Filter.monochrome, true),
                        builder: (context, AsyncSnapshot<Widget> snapShot) {
                          if (snapShot.data != null) {
                            return snapShot.data;
                          } else {
                            return Center(
                                child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 1.0,
                            ));
                          }
                        },
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        currentFilter = Filter.monochrome;
                      });
                    }),
                Text("Mono Chrome", style: TextStyle(color: Colors.white))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> _getFilterWidget(Filter filter, bool isThumbnail) async {
    Map<String, String> map = {
      "imagePath": _imagePath,
      "dirPath": _directoryPath,
      "isThumbnail": isThumbnail == true ? "y" : "n",
      "filterName": filter.toString()
    };

    return compute(_buildFilterImageWidget, map);
  }

  _getDirectoryPath() async {
    _directoryPath = (await getApplicationDocumentsDirectory()).path;
  }
}

Widget _buildFilterImageWidget(Map<String, String> map) {
  Widget widget;
  var imagePath = map["imagePath"];
  var directoryPath = map["dirPath"];
  var isThumbnail = map["isThumbnail"];
  var filterName = map["filterName"];

  Img.Image source = Img.decodeImage(new File(imagePath).readAsBytesSync());
  // Resize the image to a 80x thumbnail (maintaining the aspect ratio).
  Img.Image resizedCopy = Img.copyResize(source, isThumbnail == "y" ? 50 : 500);
  Img.Image finalImage;

  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  String extension = isThumbnail == "y" ? filterName : '$timestamp.jpg';
  String filePath = '$directoryPath/$extension';

  switch (filterName) {
    case "Filter.magic":
      Img.Image intermediateImage = Img.brightness(resizedCopy, -20);
      finalImage = Img.contrast(intermediateImage, 180);
      break;
    case "Filter.sepia":
      finalImage = Img.sepia(resizedCopy, amount: 2.0);
      break;
    case "Filter.gamma":
      finalImage = Img.adjustColor(resizedCopy, gamma: 3.0);
      break;
    case "Filter.monochrome":
      finalImage = Img.adjustColor(resizedCopy, saturation: -1.0);
      break;
  }

  File(filePath).writeAsBytesSync(Img.encodePng(finalImage), mode: FileMode.write);

  widget = Image.file(
    File(filePath),
    fit: BoxFit.cover,
  );

  return widget;
}
