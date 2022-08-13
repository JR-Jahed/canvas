import 'package:canvas_object/painter.dart';
import 'package:canvas_object/values.dart';
import 'package:flutter/material.dart';

import 'canvas_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


Matrix4 downMat = Matrix4.zero();
Matrix4 opMat = Matrix4.identity();

class _MyHomePageState extends State<MyHomePage> {

  double tapX = -1, tapY = -1;
  double lastX = -1, lastY = -1;
  double padLeft = 0, padTop = 0;

  double prWidth = -1, prHeight = -1;

  int idx = -1;
  int idxOfSelectedCircle = -1;

  int currentlySelected = -1;

  bool dragging = false;

  double ratio = 1;
  bool maintainRatio = true;

  List<CanvasModel> list = [];

  void deselectAll() {
    for(int i = 0; i < list.length; i++) {
      list[i].selected = false;
    }
  }

  void add() {
    deselectAll();
    list.add(
      CanvasModel(
        matrix: Matrix4.identity(),
        begin: const Offset(0, 0),
        selected: true,
        rotation: 0,
        curCircles: []
      ),
    );
    currentlySelected = list.length - 1;
    setState(() {});
  }

  int getIdx(double x, double y) {

    int ans = -1;

    for(int i = 0; i < list.length; i++) {

      double beginX = list[i].begin.dx + list[i].matrix.getTranslation().x;
      double beginY = list[i].begin.dy + list[i].matrix.getTranslation().y;
      double endX = beginX + (list[i].widthAfterScaling < 0 ? list[i].width : list[i].widthAfterScaling);
      double endY = beginY + (list[i].heightAfterScaling < 0 ? list[i].height : list[i].heightAfterScaling);

      if(x >= beginX &&
         x <= endX &&
         y >= beginY &&
         y <= endY && ans == -1) {
        ans = i;
      }
      else {
        // following line deselects an object if the user tapped outside it
        list[i].selected = false;
      }
    }

    return ans;
  }

  int getIdxOfCircle(double x, double y) {

    if(currentlySelected == -1) return -1;

    List<Offset> tmp = [];
    tmp.add(Offset(list[currentlySelected].matrix.getTranslation().x,
        list[currentlySelected].matrix.getTranslation().y)); // no change for flip

    tmp.add(Offset(list[currentlySelected].matrix.getTranslation().x + list[currentlySelected].widthAfterScaling,
        list[currentlySelected].matrix.getTranslation().y)); // change if flipped hor

    tmp.add(Offset(list[currentlySelected].matrix.getTranslation().x,
        list[currentlySelected].matrix.getTranslation().y + list[currentlySelected].heightAfterScaling)); // change if flipped ver

    tmp.add(Offset(list[currentlySelected].matrix.getTranslation().x + list[currentlySelected].widthAfterScaling,
        list[currentlySelected].matrix.getTranslation().y + list[currentlySelected].heightAfterScaling)); // change for both direction

    tmp.add(Offset(list[currentlySelected].matrix.getTranslation().x,
        list[currentlySelected].matrix.getTranslation().y + list[currentlySelected].heightAfterScaling * 2));

    tmp.add(Offset(list[currentlySelected].matrix.getTranslation().x + list[currentlySelected].widthAfterScaling,
        list[currentlySelected].matrix.getTranslation().y + list[currentlySelected].heightAfterScaling * 2));

    for (int i = 0; i < tmp.length; i++) {
      final o = tmp[i];
      if (x >= o.dx - 20 &&
          x <= o.dx + 20 &&
          y >= o.dy - 20 &&
          y <= o.dy + 20) {
        return i;
      }
    }

    return -1;
  }

  void translate(double tX, double tY) {
    opMat.setFrom(downMat);
    opMat.translate(tX, tY);
    list[currentlySelected].matrix.setFrom(opMat);
  }

  void scale(double scaleX, double scaleY, double tX, double tY) {
    opMat.setFrom(downMat);
    opMat.translate(tX, tY);
    opMat.scale(scaleX, scaleY);
    opMat.translate(-tX, -tY);
    list[currentlySelected].matrix.setFrom(opMat);
  }

  void flipHorizontally() {
    opMat.setFrom(downMat);
    opMat.translate(list[currentlySelected].width / 2, list[currentlySelected].height / 2);
    opMat.storage[0] *= -1;
    opMat.translate(-list[currentlySelected].width / 2, -list[currentlySelected].height / 2);
    list[currentlySelected].matrix.setFrom(opMat);
  }

  void flipVertically() {
    opMat.setFrom(downMat);
    opMat.translate(list[currentlySelected].width / 2, list[currentlySelected].height / 2);
    opMat.storage[5] *= -1;
    opMat.translate(-list[currentlySelected].width / 2, -list[currentlySelected].height / 2);
    list[currentlySelected].matrix.setFrom(opMat);
  }

  @override
  Widget build(BuildContext context) {

    padLeft = MediaQuery.of(context).padding.left;
    padTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .8,

              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraint) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,

                    onTapDown: (details) {
                      tapX = details.globalPosition.dx - padLeft;
                      tapY = details.globalPosition.dy - padTop;

                      lastX = tapX;
                      lastY = tapY;


                      // if an object is already selected and user taps outside the rectangle but within the bounds
                      // of the circles which might be outside the rectangle we need to detect it
                      // that's why the following block is used

                      if(currentlySelected != -1) {
                        ratio = list[currentlySelected].height / list[currentlySelected].width;
                        idxOfSelectedCircle = getIdxOfCircle(tapX, tapY);
                        downMat.setFrom(list[currentlySelected].matrix);

                        if(idxOfSelectedCircle != -1) {

                          if(idxOfSelectedCircle == 4) {
                            flipHorizontally();
                          }
                          else if(idxOfSelectedCircle == 5) {
                            flipVertically();
                          }

                          setState(() {
                            list[currentlySelected].curCircles[idxOfSelectedCircle].second = 10;
                          });
                          return;
                        }
                      }

                      idx = getIdx(tapX, tapY);

                      // if not within the bound of any object

                      if(idx == -1) {
                        // if any object is selected we need to deselect it

                        if(currentlySelected != -1) {
                          setState(() {
                            list[currentlySelected].selected = false;
                          });
                        }
                        currentlySelected = -1;
                      }
                      else {
                        bool shouldChangeState = false;

                        if(idx != currentlySelected) {
                          shouldChangeState = true;
                          currentlySelected = idx;
                          list[currentlySelected].selected = true;
                        }

                        ratio = list[currentlySelected].height / list[currentlySelected].width;
                        downMat.setFrom(list[currentlySelected].matrix);

                        idxOfSelectedCircle = getIdxOfCircle(tapX, tapY);

                        if(idxOfSelectedCircle != -1) {
                          shouldChangeState = true;
                          list[currentlySelected].curCircles[idxOfSelectedCircle].second = 10;
                        }
                        if(shouldChangeState) {
                          setState(() {});
                        }
                      }
                    },
                    onTapUp: (details) {
                      tapX = tapY = -1;

                      if(idxOfSelectedCircle != -1) {
                        setState(() {
                          list[currentlySelected].curCircles[idxOfSelectedCircle].second = 5;
                        });
                        idxOfSelectedCircle = -1;
                      }
                    },

                    onTap: () {
                    },

                    onPanStart: (details) {

                      if(tapX == -1 && tapY == -1) {
                        lastX = details.globalPosition.dx - padLeft;
                        lastY = details.globalPosition.dy - padTop;
                      }

                      // we'll perform operations on any object if and only if it is selected

                      if(currentlySelected != -1) {
                        idx = getIdx(lastX, lastY);

                        // if user taps within the bound of rectangle it is enabled for dragging
                        if(idx != -1) {
                          dragging = true;
                        }
                        idxOfSelectedCircle = getIdxOfCircle(lastX, lastY);

                        // if a circle is selected we need to select this object again. otherwise due to line 101
                        // if the tap is outside rectangle the object will be deselected
                        if(idxOfSelectedCircle != -1) {
                          list[currentlySelected].selected = true;
                        }

                        downMat.setFrom(list[currentlySelected].matrix);

                        // if it is being scaled for the first time, initialize variables

                        if(list[currentlySelected].widthAfterScaling == -1 && list[currentlySelected].heightAfterScaling == -1) {
                          list[currentlySelected].widthAfterScaling = list[currentlySelected].width;
                          list[currentlySelected].heightAfterScaling = list[currentlySelected].height;
                        }

                        prWidth = list[currentlySelected].widthAfterScaling;
                        prHeight = list[currentlySelected].heightAfterScaling;

                        if(idxOfSelectedCircle != -1) {
                          setState(() {
                            list[currentlySelected].curCircles[idxOfSelectedCircle].second = 10;
                          });
                        }
                      }
                    },

                    onPanUpdate: (details) {

                      double x = details.globalPosition.dx - padLeft;
                      double y = details.globalPosition.dy - padTop;

                      double dx = x - lastX;
                      double dy = y - lastY;

                      if(idxOfSelectedCircle >= 0 && idxOfSelectedCircle <= 3) {

                        double scaleX = 1, scaleY = 1;

                        if(maintainRatio) {
                          double ddx = 0;

                          if(idxOfSelectedCircle == 0) {
                            ddx = (dx + dy) / 2;
                          }
                          else if(idxOfSelectedCircle == 1) {
                            ddx = (-dx + dy) / 2;
                          }
                          else if(idxOfSelectedCircle == 2) {
                            ddx = (dx - dy) / 2;
                          }
                          else {
                            ddx = (-dx - dy) / 2;
                          }

                          scaleX = (prWidth - ddx * 2) / prWidth;
                          scaleY = (prHeight - ddx * ratio * 2) / prHeight;
                        }
                        else {

                        }

                        double nextWidthRect = prWidth * scaleX;
                        double nextHeightRect = prHeight * scaleY;


                        if(nextWidthRect >= minWidth && nextHeightRect >= minHeight) {

                          double tX = (list[currentlySelected].width / 2),
                              tY = (list[currentlySelected].height / 2);

                          // curScaleX = scaleX;
                          // curScaleY = scaleY;

                          scale(scaleX, scaleY, tX, tY);

                          list[currentlySelected].widthAfterScaling = nextWidthRect;
                          list[currentlySelected].heightAfterScaling = nextHeightRect;
                          list[currentlySelected].scaleX = list[currentlySelected].widthAfterScaling / list[currentlySelected].width;
                          list[currentlySelected].scaleY = list[currentlySelected].heightAfterScaling / list[currentlySelected].height;

                          setState(() {});
                        }
                      }

                      if(dragging && idxOfSelectedCircle == -1) {
                        translate(dx / list[currentlySelected].scaleX, dy / list[currentlySelected].scaleY);
                        setState(() {});
                      }
                    },

                    onPanEnd: (details) {
                      dragging = false;

                      tapX = tapY = -1;

                      if(idxOfSelectedCircle != -1) {
                        setState(() {
                          list[currentlySelected].curCircles[idxOfSelectedCircle].second = 5;
                        });
                        idxOfSelectedCircle = -1;
                      }
                    },

                    child: CustomPaint(
                      painter: Painter(
                        list: list,
                      ),
                      child: Container(),
                    ),
                  );
                }
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: FloatingActionButton(
                      onPressed: () {
                        add();
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),

    );
  }
}



//
// class _MyHomePageState extends State<MyHomePage> {
//   double padTop = 0, padLeft = 0;
//   double tapX = -1, tapY = -1;
//   double lastX = -1, lastY = -1;
//
//   bool dragging = false;
//   int id = -1;
//
//   final List<Offset> offset = [
//     const Offset(5, 5), const Offset(150, 5),
//     const Offset(5, 80), const Offset(150, 80),];
//
//   List<CanvasObject> list = [];
//
//   void add() {
//     list.add(
//       CanvasObject(
//         canvasModel: CanvasModel(
//           matrix: Matrix4.identity(),
//           begin: offset[(idx++) % offset.length],
//           selected: true,
//           rotation: 0,
//         ),
//       ),
//     );
//     setState(() {});
//   }
//
//   int getIdx(double x, double y) {
//
//     for(int i = 0; i < list.length; i++) {
//       if(x >= list[i].canvasModel.begin.dx &&
//          x <= list[i].canvasModel.begin.dx + list[i].canvasModel.width &&
//          y >= list[i].canvasModel.begin.dy &&
//          y <= list[i].canvasModel.begin.dy + list[i].canvasModel.height) {
//         return i;
//       }
//     }
//
//     return -1;
//   }
//
//   void translate(double tX, double tY) {
//     opMat.setFrom(downMat);
//     opMat.translate(tX, tY);
//     list[id].canvasModel.matrix.setFrom(opMat);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     padTop = MediaQuery.of(context).padding.top;
//     padLeft = MediaQuery.of(context).padding.left;
//
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(
//               height: MediaQuery.of(context).size.height * .8,
//               width: MediaQuery.of(context).size.width,
//
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//
//                 onTapDown: (details) {
//                   tapX = details.globalPosition.dx - padLeft;
//                   tapY = details.globalPosition.dy - padTop;
//
//                   lastX = tapX;
//                   lastY = tapY;
//
//                   id = getIdx(tapX, tapY);
//
//                   print('id = $id    tapx = $tapX  tapy = $tapY');
//
//                   if(id != -1) {
//                     downMat.setFrom(list[id].canvasModel.matrix);
//                   }
//                 },
//                 onTapUp: (details) {
//                   tapX = tapY = -1;
//                 },
//                 onTap: () {
//
//                 },
//
//                 onPanStart: (details) {
//                   if(tapX == -1 && tapY == -1) {
//                     lastX = details.globalPosition.dx - padLeft;
//                     lastY = details.globalPosition.dy - padTop;
//                   }
//                   id = getIdx(lastX, lastY);
//                   dragging = id != -1;
//
//                   print('id = $id  dragging = $dragging');
//
//                   if(id != -1) {
//                     downMat.setFrom(list[id].canvasModel.matrix);
//                   }
//                 },
//                 onPanUpdate: (details) {
//
//                   double x = details.globalPosition.dx - padLeft;
//                   double y = details.globalPosition.dy - padTop;
//
//                   double dx = x - lastX;
//                   double dy = y - lastY;
//
//                   if(dragging) {
//                     print('dx = $dx  dy = $dy');
//                     translate(dx, dy);
//                     setState(() {});
//                   }
//                 },
//                 onPanEnd: (details) {
//                   dragging = false;
//
//                   for(int i = 0; i < list.length; i++) {
//                     print('i = $i   tx = ${list[i].canvasModel.matrix.getTranslation().x}  ty = ${list[i].canvasModel.matrix.getTranslation().y}');
//                   }
//                 },
//
//                 child: Column(
//                   children: list,
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//                   child: FloatingActionButton(
//                     onPressed: () {
//                       add();
//                     },
//                     child: const Icon(Icons.add),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
