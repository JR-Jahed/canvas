import 'dart:math';
import 'package:canvas_object/painter.dart';
import 'package:canvas_object/pair.dart';
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

  double  _curSliderValue = 0;

  void deselectAll() {
    for (int i = 0; i < list.length; i++) {
      list[i].selected = false;
    }
  }

  void add() {
    deselectAll();
    _curSliderValue = 0;
    currentlySelected = list.length;
    list.add(
      CanvasModel(
          matrix: Matrix4.identity(),
          begin: const Offset(0, 0),
          selected: true,
          rotation: 0,
          curCircles: []),
    );
    setState(() {});
  }

  int getIdx(double x, double y) {
    int ans = -1;

    for (int i = 0; i < list.length; i++) {
      double curWidth = (list[i].widthAfterScaling < 0
          ? list[i].width
          : list[i].widthAfterScaling);
      double curHeight = (list[i].heightAfterScaling < 0
          ? list[i].height
          : list[i].heightAfterScaling);

      double beginX = list[i].begin.dx +
          list[i].matrix.getTranslation().x +
          curWidth * (list[i].isFlippedHorizontally ? -1 : 0);
      double beginY = list[i].begin.dy +
          list[i].matrix.getTranslation().y +
          curHeight * (list[i].isFlippedVertically ? -1 : 0);
      double endX = beginX + curWidth;
      double endY = beginY + curHeight;

      if (x >= beginX && x <= endX && y >= beginY && y <= endY && ans == -1) {
        ans = i;
      } else {
        // following line deselects an object if the user tapped outside it
        list[i].selected = false;
      }
    }

    return ans;
  }
  int getIdx2(double x, double y) {
    int ans = -1;

    for (int i = 0; i < list.length; i++) {
      double curWidth = (list[i].widthAfterScaling < 0
          ? list[i].width
          : list[i].widthAfterScaling);
      double curHeight = (list[i].heightAfterScaling < 0
          ? list[i].height
          : list[i].heightAfterScaling);

      double beginX = list[i].begin.dx +
          list[i].matrix.getTranslation().x;
      double beginY = list[i].begin.dy +
          list[i].matrix.getTranslation().y;

      calculateMid(i);
      Pair<double, double> p = unrotated(beginX, beginY, list[i].rotation);
      beginX = p.first;
      beginY = p.second;

      beginX += curWidth * (list[i].isFlippedHorizontally ? -1 : 0);
      beginY += curHeight * (list[i].isFlippedVertically ? -1 : 0);

      double endX = beginX + curWidth;
      double endY = beginY + curHeight;

      p = unrotated(x, y, list[i].rotation);
      double newX = p.first;
      double newY = p.second;

      if (newX >= beginX && newX <= endX && newY >= beginY && newY <= endY && ans == -1) {
        ans = i;
      } else {
        // following line deselects an object if the user tapped outside it
        list[i].selected = false;
      }
    }

    return ans;
  }

  int getIdxOfCircle(double x, double y) {
    if (currentlySelected == -1) return -1;

    double curWidth = (list[currentlySelected].widthAfterScaling < 0
        ? list[currentlySelected].width
        : list[currentlySelected].widthAfterScaling);
    double curHeight = (list[currentlySelected].heightAfterScaling < 0
        ? list[currentlySelected].height
        : list[currentlySelected].heightAfterScaling);

    List<Offset> tmp = [];

    tmp.add(Offset(
        list[currentlySelected].matrix.getTranslation().x,
        list[currentlySelected]
            .matrix
            .getTranslation()
            .y)); // no change for flip

    tmp.add(Offset(
        list[currentlySelected].matrix.getTranslation().x +
            curWidth * (list[currentlySelected].isFlippedHorizontally ? -1 : 1),
        list[currentlySelected]
            .matrix
            .getTranslation()
            .y)); // change if flipped hor

    tmp.add(Offset(
        list[currentlySelected].matrix.getTranslation().x,
        list[currentlySelected].matrix.getTranslation().y +
            curHeight *
                (list[currentlySelected].isFlippedVertically
                    ? -1
                    : 1))); // change if flipped ver

    tmp.add(Offset(
        list[currentlySelected].matrix.getTranslation().x +
            curWidth * (list[currentlySelected].isFlippedHorizontally ? -1 : 1),
        list[currentlySelected].matrix.getTranslation().y +
            curHeight *
                (list[currentlySelected].isFlippedVertically
                    ? -1
                    : 1))); // change for both direction

    tmp.add(Offset(
        list[currentlySelected].matrix.getTranslation().x,
        list[currentlySelected].matrix.getTranslation().y +
            curHeight *
                2 *
                (list[currentlySelected].isFlippedVertically
                    ? -1
                    : 1))); // change for both direction

    tmp.add(Offset(
        list[currentlySelected].matrix.getTranslation().x +
            curWidth * (list[currentlySelected].isFlippedHorizontally ? -1 : 1),
        list[currentlySelected].matrix.getTranslation().y +
            curHeight *
                2 *
                (list[currentlySelected].isFlippedVertically
                    ? -1
                    : 1))); // change for both direction

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

  int getIdxOfCircle2(double x, double y) {
    if (currentlySelected == -1) return -1;

    double curWidth = (list[currentlySelected].widthAfterScaling < 0
        ? list[currentlySelected].width
        : list[currentlySelected].widthAfterScaling);
    double curHeight = (list[currentlySelected].heightAfterScaling < 0
        ? list[currentlySelected].height
        : list[currentlySelected].heightAfterScaling);

    List<Offset> tmp = [];

    Offset upperLeft = Offset(
        list[currentlySelected].matrix.getTranslation().x,
        list[currentlySelected].matrix.getTranslation().y); // no change for flip

    Pair<double, double> p = unrotated(upperLeft.dx, upperLeft.dy, list[currentlySelected].rotation);
    upperLeft = Offset(p.first, p.second);
    tmp.add(upperLeft);

    tmp.add(Offset(
        upperLeft.dx +
            curWidth * (list[currentlySelected].isFlippedHorizontally ? -1 : 1), upperLeft.dy)); // change if flipped hor

    tmp.add(Offset(
        upperLeft.dx,
        upperLeft.dy +
            curHeight * (list[currentlySelected].isFlippedVertically ? -1 : 1))); // change if flipped ver

    tmp.add(Offset(
        upperLeft.dx +
            curWidth * (list[currentlySelected].isFlippedHorizontally ? -1 : 1),
        upperLeft.dy +
            curHeight * (list[currentlySelected].isFlippedVertically ? -1 : 1))); // change for both direction

    // tmp.add(Offset(
    //     upperLeft.dx,
    //     upperLeft.dy +
    //         curHeight * 2 * (list[currentlySelected].isFlippedVertically ? -1 : 1))); // change for both direction
    //
    // tmp.add(Offset(
    //     upperLeft.dx + curWidth * (list[currentlySelected].isFlippedHorizontally ? -1 : 1),
    //     upperLeft.dy + curHeight * 2 * (list[currentlySelected].isFlippedVertically ? -1 : 1))); // change for both direction

    //print('x = $x  y = $y');
    p = unrotated(x, y, list[currentlySelected].rotation);
    double newX = p.first;
    double newY = p.second;
    //print('x = $x  y = $y');

    for (int i = 0; i < tmp.length; i++) {
      final o = tmp[i];
      if (newX >= o.dx - 20 &&
          newX <= o.dx + 20 &&
          newY >= o.dy - 20 &&
          newY <= o.dy + 20) {
        return i;
      }
    }

    return -1;
  }

  void translate(double tX, double tY) {
    opMat.setFrom(downMat);

    opMat.rotateZ(degToRad(-list[currentlySelected].rotation * (list[currentlySelected].isFlippedHorizontally ? -1 : 1)
        * (list[currentlySelected].isFlippedVertically ? -1 : 1)));
    opMat.translate(tX, tY);
    opMat.rotateZ(degToRad(list[currentlySelected].rotation * (list[currentlySelected].isFlippedHorizontally ? -1 : 1)
        * (list[currentlySelected].isFlippedVertically ? -1 : 1)));

    list[currentlySelected].matrix.setFrom(opMat);
  }

  void scale(double scaleX, double scaleY, double tX, double tY) {
    opMat.setFrom(downMat);
    opMat.translate(tX, tY);
    opMat.scale(scaleX, scaleY, 1);
    opMat.translate(-tX, -tY);
    list[currentlySelected].matrix.setFrom(opMat);
  }

  void flipHorizontally() {

    opMat.setFrom(downMat);
    opMat.translate(list[currentlySelected].width / 2, list[currentlySelected].height / 2);

    double r;

    if(list[currentlySelected].isFlippedHorizontally) {
      r = list[currentlySelected].rotation;
    }
    else {
      r = -list[currentlySelected].rotation;
    }

    opMat.rotateZ(degToRad(r));
    opMat.storage[0] *= -1;

    if(list[currentlySelected].isFlippedHorizontally) {
      r = list[currentlySelected].rotation;
    }
    else {
      r = -list[currentlySelected].rotation;
    }

    opMat.rotateZ(degToRad(r));
    list[currentlySelected].isFlippedHorizontally ^= true;

    opMat.translate(-list[currentlySelected].width / 2, -list[currentlySelected].height / 2);
    list[currentlySelected].matrix.setFrom(opMat);
  }

  void flipVertically() {

    opMat.setFrom(downMat);
    opMat.translate(list[currentlySelected].width / 2, list[currentlySelected].height / 2);

    double r;

    if(list[currentlySelected].isFlippedVertically) {
      r = list[currentlySelected].rotation;
    }
    else {
      r = -list[currentlySelected].rotation;
    }

    opMat.rotateZ(degToRad(r));
    opMat.storage[5] *= -1;
    if(list[currentlySelected].isFlippedVertically) {
      r = list[currentlySelected].rotation;
    }
    else {
      r = -list[currentlySelected].rotation;
    }

    opMat.rotateZ(degToRad(r));
    list[currentlySelected].isFlippedVertically ^= true;

    opMat.translate(-list[currentlySelected].width / 2, -list[currentlySelected].height / 2);
    list[currentlySelected].matrix.setFrom(opMat);
  }

  double curRotation = 0, midX = 0, midY = 0;
  double degToRad(double deg) {
    return deg * pi / 180;
  }
  double radToDeg(double rad) {
    return rad * 180 / pi;
  }
  void calculateMid(int _idx) {
    midX = list[_idx].matrix.getTranslation().x + list[_idx].width / 2;
    midY = list[_idx].matrix.getTranslation().y + list[_idx].height / 2;
  }
  Pair<double, double> unrotated(double x, double y, double r) {
    double newX = (x - midX) * cos(degToRad(r)) - (midY - y) * sin(degToRad(r)) + midX;
    double newY = (midX - x) * sin(degToRad(r)) + (y - midY) * cos(degToRad(r)) + midY;

    return Pair(first: newX, second: newY);
  }
  void rotate(double r, double tX, double tY) {
    opMat.setFrom(downMat);
    opMat.translate(tX, tY);
    opMat.rotateZ(r);
    opMat.translate(-tX, -tY);
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
              height: MediaQuery.of(context).size.height * .78,
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

                      if (currentlySelected != -1) {
                        ratio = list[currentlySelected].height / list[currentlySelected].width;
                        idxOfSelectedCircle = getIdxOfCircle2(tapX, tapY);
                        downMat.setFrom(list[currentlySelected].matrix);

                        if (idxOfSelectedCircle != -1) {
                          if (idxOfSelectedCircle == 4) {
                            flipHorizontally();
                          } else if (idxOfSelectedCircle == 5) {
                            flipVertically();
                          }

                          setState(() {
                            list[currentlySelected].curCircles[idxOfSelectedCircle].second = 10;
                          });
                          return;
                        }
                      }

                      idx = getIdx2(tapX, tapY);

                      // if not within the bound of any object

                      if (idx == -1) {
                        // if any object is selected we need to deselect it

                        if (currentlySelected != -1) {
                          setState(() {
                            _curSliderValue = 0;
                            list[currentlySelected].selected = false;
                          });
                        }
                        currentlySelected = -1;
                      } else {
                        bool shouldChangeState = false;

                        if (idx != currentlySelected) {
                          shouldChangeState = true;
                          currentlySelected = idx;
                          _curSliderValue = list[currentlySelected].rotation;
                          _curSliderValue = max(_curSliderValue, 0);
                          _curSliderValue = min(_curSliderValue, 360);
                          list[currentlySelected].selected = true;
                        }

                        ratio = list[currentlySelected].height / list[currentlySelected].width;
                        downMat.setFrom(list[currentlySelected].matrix);

                        idxOfSelectedCircle = getIdxOfCircle2(tapX, tapY);

                        if (idxOfSelectedCircle != -1) {
                          shouldChangeState = true;
                          list[currentlySelected].curCircles[idxOfSelectedCircle].second = 10;
                        }
                        if (shouldChangeState) {
                          setState(() {});
                        }
                      }
                    },
                    onTapUp: (details) {
                      tapX = tapY = -1;

                      if (idxOfSelectedCircle != -1) {
                        setState(() {
                          list[currentlySelected].curCircles[idxOfSelectedCircle].second = 5;
                        });
                        idxOfSelectedCircle = -1;
                      }
                    },
                    onTap: () {},
                    onPanStart: (details) {
                      if (tapX == -1 && tapY == -1) {
                        lastX = details.globalPosition.dx - padLeft;
                        lastY = details.globalPosition.dy - padTop;
                      }

                      // we'll perform operations on any object if and only if it is selected

                      if (currentlySelected != -1) {
                        idx = getIdx2(lastX, lastY);

                        // if user taps within the bound of rectangle it is enabled for dragging
                        if (idx != -1) {
                          dragging = true;
                        }
                        idxOfSelectedCircle = getIdxOfCircle2(lastX, lastY);

                        // if a circle is selected we need to select this object again. otherwise due to line 101
                        // if the tap is outside rectangle the object will be deselected
                        if (idxOfSelectedCircle != -1) {
                          list[currentlySelected].selected = true;
                        }

                        downMat.setFrom(list[currentlySelected].matrix);

                        // if it is being scaled for the first time, initialize variables

                        if (list[currentlySelected].widthAfterScaling == -1 &&
                            list[currentlySelected].heightAfterScaling == -1) {
                          list[currentlySelected].widthAfterScaling =
                              list[currentlySelected].width;
                          list[currentlySelected].heightAfterScaling =
                              list[currentlySelected].height;
                        }

                        prWidth = list[currentlySelected].widthAfterScaling;
                        prHeight = list[currentlySelected].heightAfterScaling;

                        if (idxOfSelectedCircle != -1) {
                          setState(() {
                            list[currentlySelected]
                                .curCircles[idxOfSelectedCircle]
                                .second = 10;
                          });
                        }
                      }
                    },
                    onPanUpdate: (details) {
                      double x = details.globalPosition.dx - padLeft;
                      double y = details.globalPosition.dy - padTop;

                      double dx = x - lastX;
                      double dy = y - lastY;

                      if (idxOfSelectedCircle >= 0 && idxOfSelectedCircle <= 3) {
                        double scaleX = 1, scaleY = 1;

                        int modifiedIdx = idxOfSelectedCircle;

                        if (list[currentlySelected].isFlippedHorizontally &&
                            list[currentlySelected].isFlippedVertically) {
                          modifiedIdx = flippedBoth[idxOfSelectedCircle];
                        } else if (list[currentlySelected]
                            .isFlippedHorizontally) {
                          modifiedIdx = flippedHor[idxOfSelectedCircle];
                        } else if (list[currentlySelected].isFlippedVertically) {
                          modifiedIdx = flippedVer[idxOfSelectedCircle];
                        }

                        if (maintainRatio) {
                          double ddx = 0;

                          if (modifiedIdx == 0) {
                            ddx = (dx + dy) / 2;
                          } else if (modifiedIdx == 1) {
                            ddx = (-dx + dy) / 2;
                          } else if (modifiedIdx == 2) {
                            ddx = (dx - dy) / 2;
                          } else {
                            ddx = (-dx - dy) / 2;
                          }

                          scaleX = (prWidth - ddx * 2) / prWidth;
                          scaleY = (prHeight - ddx * ratio * 2) / prHeight;
                        } else {

                        }

                        double nextWidthRect = prWidth * scaleX;
                        double nextHeightRect = prHeight * scaleY;

                        if (nextWidthRect >= minWidth &&
                            nextHeightRect >= minHeight) {
                          double tX = (list[currentlySelected].width / 2),
                              tY = (list[currentlySelected].height / 2);

                          scale(scaleX, scaleY, tX, tY);

                          list[currentlySelected].widthAfterScaling = nextWidthRect;
                          list[currentlySelected].heightAfterScaling = nextHeightRect;

                          list[currentlySelected].scaleX = list[currentlySelected].widthAfterScaling / list[currentlySelected].width;
                          list[currentlySelected].scaleY = list[currentlySelected].heightAfterScaling / list[currentlySelected].height;

                          setState(() {});
                        }
                      }

                      if (dragging && idxOfSelectedCircle == -1) {
                        //print('dx = $dx  dy = $dy  sx = ${list[currentlySelected].scaleX}  sy = ${list[currentlySelected].scaleY}');
                        translate(
                            dx / list[currentlySelected].scaleX * (list[currentlySelected].isFlippedHorizontally ? -1 : 1),
                            dy / list[currentlySelected].scaleY * (list[currentlySelected].isFlippedVertically ? -1 : 1));
                        setState(() {});
                      }
                    },
                    onPanEnd: (details) {
                      dragging = false;

                      tapX = tapY = -1;

                      if (idxOfSelectedCircle != -1) {
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
                },
              ),
            ),







            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Slider(
                onChanged: (double value) {
                  if(currentlySelected != -1) {
                    double rotation = value - _curSliderValue;
                    downMat.setFrom(list[currentlySelected].matrix);
                    list[currentlySelected].rotation += rotation;
                    rotate(degToRad(rotation) * (list[currentlySelected].isFlippedHorizontally ? -1 : 1)
                        * (list[currentlySelected].isFlippedVertically ? -1 : 1),
                        list[currentlySelected].width / 2,
                        list[currentlySelected].height / 2);
                    _curSliderValue = value;
                    setState(() {});
                  }
                },
                value: _curSliderValue,
                label: _curSliderValue.round().toString(),
                divisions: 361,
                max: 360,
              ),
            ),
            // Row(
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            //       child: FloatingActionButton(
            //         onPressed: () {
            //           add();
            //         },
            //         child: const Icon(Icons.add),
            //       ),
            //     ),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: TextButton(
                          onPressed: () {
                            if(currentlySelected != -1) {
                              downMat.setFrom(list[currentlySelected].matrix);
                              flipHorizontally();
                              setState(() {});
                            }
                          },
                          child: Center(
                            child: Column(
                              children: const [
                                Text('Flip'),
                                Text('Horizontally'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: TextButton(
                          onPressed: () {
                            if(currentlySelected != -1) {
                              downMat.setFrom(list[currentlySelected].matrix);
                              flipVertically();
                              setState(() {});
                            }
                          },
                          child: Center(
                            child: Column(
                              children: const [
                                Text('Flip'),
                                Text('Vertically'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                        child: TextButton(
                          onPressed: () {
                            if(currentlySelected != -1) {
                              print(list[currentlySelected].rotation);
                            }
                          },
                          child: Center(
                            child: Column(
                              children: const [
                                Text('Current'),
                                Text('Rotation'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
