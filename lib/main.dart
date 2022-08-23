import 'dart:math';
import 'package:canvas_object/painter.dart';
import 'package:canvas_object/test.dart';
import 'package:canvas_object/text.dart';
import 'package:canvas_object/values.dart';
import 'package:flutter/material.dart';

import 'canvas_model.dart';
import 'util.dart';
import 'operation.dart';

const secondRoute = '/test/';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyHomePage(),
    routes: {
      secondRoute: (context) => const Second()
    },
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double tapX = -1, tapY = -1;
  double lastX = -1, lastY = -1;
  double lastTouchedX = -1, lastTouchedY = - 1;
  double padLeft = 0, padTop = 0;

  double prWidth = -1, prHeight = -1;

  int idx = -1;
  int idxOfSelectedCircle = -1;

  int currentlySelected = -1;

  bool dragging = false;

  bool activateTextField = false;

  double ratio = 1;
  bool maintainRatio = true;
  double rotationAtBeginning = 0;

  List<CanvasModel> list = [];

  double screenWidth = 0;

  late final TextEditingController _dialogTextFieldController;

  @override
  void initState() {
    super.initState();
    _dialogTextFieldController = TextEditingController();
  }

  //  I made textPainter an instance variable so that I can assign maxLine of TextField dynamically at runtime

  void recalculate() {
    list[currentlySelected].width = (list[currentlySelected] as TextModel).textPainter.width + 10;
    list[currentlySelected].height = (list[currentlySelected] as TextModel).textPainter.height + 10;
    list[currentlySelected].widthAfterScaling = list[currentlySelected].width * list[currentlySelected].scaleX;
    list[currentlySelected].heightAfterScaling = list[currentlySelected].height * list[currentlySelected].scaleY;
  }

  int calculateMaxLine(String s, double fontSize) {

    final textPainter = getTextPainter(s, 3000, fontSize: fontSize);

    for(int i = 1; ; i++) {
      //print('tpw = ${textPainter.width}   i = $i   ${(screenWidth - list[currentlySelected].matrix.getTranslation().x) * i}');
      if(textPainter.width <= (screenWidth - list[currentlySelected].matrix.getTranslation().x) * i) return i;
    }
  }

  SizedBox getBox(double width, double height, double letterSpacing, double fontSize, int curMaxLine) {

    return SizedBox(
      width: max(0, width),
      height: max(0, height),
      child: TextField(
        controller: _dialogTextFieldController,
        enabled: true,
        autocorrect: false,
        showCursor: true,
        autofocus: true,
        style: TextStyle(
          letterSpacing: letterSpacing,
          fontSize: fontSize,
        ),
        maxLines: curMaxLine,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        onChanged: (text) {

          int maxLine = calculateMaxLine("${text}W", ((list[currentlySelected] as TextModel).textPainter.text as TextSpan).style!.fontSize!);

          // if(maxLine > curMaxLine) {
          //   text += '\n';
          //   // _dialogTextFieldController.text = text;
          // }

          setState(() {
            list[currentlySelected].curCircles.clear();
            (list[currentlySelected] as TextModel).textPainter = getTextPainter(text,
                (screenWidth - list[currentlySelected].matrix.getTranslation().x) / list[currentlySelected].scaleX);
            recalculate();

            // if(list[currentlySelected].matrix.getTranslation().x +  > screenWidth) {
            //
            // }

          });
          (list[currentlySelected] as TextModel).box =
              getBox(list[currentlySelected].widthAfterScaling,
                  list[currentlySelected].heightAfterScaling, 2, fontSize, maxLine);
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    padLeft = MediaQuery.of(context).padding.left;
    padTop = MediaQuery.of(context).padding.top;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .8,
                child: Stack(
                  children: [
                    LayoutBuilder(
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

                           //print('line 113');

                            if (currentlySelected != -1) {

                              ratio = list[currentlySelected].height / list[currentlySelected].width;
                              idxOfSelectedCircle = getIdxOfCircle(tapX, tapY, list, currentlySelected);
                              downMat.setFrom(list[currentlySelected].matrix);
                              downMatFrame.setFrom(list[currentlySelected].matrixFrame);

                              if (idxOfSelectedCircle != -1) {
                                if (idxOfSelectedCircle == 4) {
                                  rotationAtBeginning = list[currentlySelected].rotation;
                                }
                                setState(() {
                                  //print('line 127');
                                  list[currentlySelected].curCircles[idxOfSelectedCircle].second = 10;
                                });
                                return;
                              }
                              idx = getIdx(tapX, tapY, list);

                              if(idx == currentlySelected) {
                                activateTextField = true;
                              }
                              else {
                                activateTextField = false;
                                setState(() {
                                  // (list[currentlySelected] as TextModel).textPainter =
                                      // getTextPainter(_dialogTextFieldController.text,
                                      //     (screenWidth - list[currentlySelected].matrix.getTranslation().x) / list[currentlySelected].scaleX);
                                  (list[currentlySelected] as TextModel).shouldDrawText = true;
                                  (list[currentlySelected] as TextModel).box = const SizedBox();
                                });
                              }
                            }
                            else {
                              idx = getIdx(tapX, tapY, list);
                            }

                            //print('line 163  idx = $idx  $currentlySelected');

                            // if not within the bound of any object

                            if (idx == -1) {
                              // if any object is selected we need to deselect it

                              if (currentlySelected != -1) {
                                setState(() {
                                  (list[currentlySelected] as TextModel).shouldDrawText = true;
                                  list[currentlySelected].selected = false;
                                });
                              }
                              currentlySelected = -1;
                            }
                            else {
                              bool shouldChangeState = false;

                              if (idx != currentlySelected) {
                                shouldChangeState = true;
                                currentlySelected = idx;
                                list[currentlySelected].selected = true;
                              }
                              if(list[currentlySelected].midX == -1 && list[currentlySelected].midY == -1) {
                                list[currentlySelected].midX = list[currentlySelected].matrix.getTranslation().x + list[currentlySelected].width / 2;
                                list[currentlySelected].midY = list[currentlySelected].matrix.getTranslation().y + list[currentlySelected].height / 2;
                              }

                              ratio = list[currentlySelected].height / list[currentlySelected].width;
                              downMat.setFrom(list[currentlySelected].matrix);
                              downMatFrame.setFrom(list[currentlySelected].matrixFrame);

                              idxOfSelectedCircle = getIdxOfCircle(tapX, tapY, list, currentlySelected);

                              if (idxOfSelectedCircle != -1) {
                                if(idxOfSelectedCircle == 4) {
                                  rotationAtBeginning = list[currentlySelected].rotation;
                                }
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
                          onTap: () {

                            if(activateTextField) {
                              setState(() {
                                (list[currentlySelected] as TextModel).shouldDrawText = false;
                                _dialogTextFieldController.text = ((list[currentlySelected] as TextModel).textPainter.text as TextSpan).text!;

                                // print('${(list[currentlySelected] as TextModel).fontSize}'
                                // '  ${list[currentlySelected].scaleX}  '
                                //     ' ${(list[currentlySelected] as TextModel).fontSize * list[currentlySelected].scaleX * .85}');

                                double fontSize =
                                    ((list[currentlySelected] as TextModel).textPainter.text as TextSpan).style!.fontSize!
                                        * list[currentlySelected].scaleX * (list[currentlySelected].scaleX <= 1 ? .83 : .85);

                                int maxLine = calculateMaxLine(_dialogTextFieldController.text, fontSize);

                                (list[currentlySelected] as TextModel).box = getBox(
                                  list[currentlySelected].widthAfterScaling - 10,
                                  list[currentlySelected].heightAfterScaling,
                                  2,
                                  fontSize,
                                  maxLine,
                                );
                              });
                            }
                          },
                          onPanStart: (details) {
                            if (tapX == -1 && tapY == -1) {
                              lastX = details.globalPosition.dx - padLeft;
                              lastY = details.globalPosition.dy - padTop;
                            }

                            // we'll perform operations on any object if and only if it is selected

                            if (currentlySelected != -1) {
                              idx = getIdx(lastX, lastY, list);
                              list[currentlySelected].selected = true;

                              idxOfSelectedCircle = getIdxOfCircle(lastX, lastY, list, currentlySelected);

                              // if user taps within the bound of selected rectangle but not within bound of any circle it is enabled for dragging
                              if (idx != -1 && idxOfSelectedCircle == -1 && idx == currentlySelected) {
                                dragging = true;
                              }

                              // if a circle is selected we need to select this object again. otherwise due to line 112
                              // if the tap is outside rectangle the object will be deselected
                              if (idxOfSelectedCircle != -1) {
                                list[currentlySelected].selected = true;
                              }
                              if(idxOfSelectedCircle == 4) {
                                rotationAtBeginning = list[currentlySelected].rotation;
                              }

                              downMat.setFrom(list[currentlySelected].matrix);
                              downMatFrame.setFrom(list[currentlySelected].matrixFrame);

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

                            lastTouchedX = x;
                            lastTouchedY = y;

                            double dx = x - lastX;
                            double dy = y - lastY;

                            if (idxOfSelectedCircle >= 0 && idxOfSelectedCircle <= 3) {
                              double scaleX = 1, scaleY = 1;

                              int modifiedIdx = idxOfSelectedCircle;

                              if(list[currentlySelected].rotation > 45 && list[currentlySelected].rotation <= 135) {
                                modifiedIdx = rotate1[idxOfSelectedCircle];
                              }
                              else if(list[currentlySelected].rotation > 135 && list[currentlySelected].rotation <= 225) {
                                modifiedIdx = rotate2[idxOfSelectedCircle];
                              }
                              else if(list[currentlySelected].rotation > 225 && list[currentlySelected].rotation <= 315) {
                                modifiedIdx = rotate3[idxOfSelectedCircle];
                              }

                              if (maintainRatio) {
                                double ddx = 0;

                                if (modifiedIdx == 0) {
                                  ddx = (dx + dy) / 2;
                                }
                                else if (modifiedIdx == 1) {
                                  ddx = (-dx + dy) / 2;
                                }
                                else if (modifiedIdx == 2) {
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

                              if (nextWidthRect >= minWidth && nextHeightRect >= minHeight) {
                                double tX = (list[currentlySelected].width / 2),
                                    tY = (list[currentlySelected].height / 2);

                                scale(scaleX, scaleY, tX, tY, list, currentlySelected);

                                list[currentlySelected].widthAfterScaling = nextWidthRect;
                                list[currentlySelected].heightAfterScaling = nextHeightRect;

                                list[currentlySelected].scaleX = list[currentlySelected].widthAfterScaling / list[currentlySelected].width;
                                list[currentlySelected].scaleY = list[currentlySelected].heightAfterScaling / list[currentlySelected].height;

                                setState(() {});
                              }
                            }
                            else if(idxOfSelectedCircle == 4) {
                              double ddx = x - list[currentlySelected].midX;
                              double ddy = y - list[currentlySelected].midY;

                              double r = -atan2(ddx, ddy);

                              if(r < 0) {
                                r = radToDeg(r);
                                r += 360;
                                r = degToRad(r);
                              }

                              double rotation = r - degToRad(rotationAtBeginning);

                              rotate(rotation, list[currentlySelected].width / 2, list[currentlySelected].height / 2, list, currentlySelected);
                              list[currentlySelected].rotation = radToDeg(r);

                              setState(() {});
                            }

                            if (dragging && idxOfSelectedCircle == -1) {
                              translate(dx / list[currentlySelected].scaleX * (list[currentlySelected].isFlippedHorizontally ? -1 : 1),
                                  dy / list[currentlySelected].scaleY * (list[currentlySelected].isFlippedVertically ? -1 : 1), list, currentlySelected);

                              setState(() {});
                            }
                          },

                          onPanEnd: (details) {

                            if(dragging) {
                              list[currentlySelected].midX += (lastTouchedX - lastX);
                              list[currentlySelected].midY += (lastTouchedY - lastY);
                            }
                            dragging = false;
                            lastTouchedX = lastTouchedY = -1;
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

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          currentlySelected == -1 ? 0 : max(0, list[currentlySelected].matrix.getTranslation().x + 5 * list[currentlySelected].scaleX * 1.2),
                          //currentlySelected == -1 ? 0 : max(0, list[currentlySelected].matrix.getTranslation().y/* + 5 * list[currentlySelected].scaleY*/),
                          currentlySelected == -1 ? 0 : max(0, list[currentlySelected].matrix.getTranslation().y
                          - (list[currentlySelected].scaleY <= 1 ? 5 : 0)),
                          0, 0),

                      child: currentlySelected == -1 ? null : (list[currentlySelected] as TextModel).box,
                    ),

                  ]
                ),
              ),

              // Container(
              //   child: currentlySelected == -1 ? null : (list[currentlySelected] as TextModel).box,
              // ),







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

                              _dialogTextFieldController.text = "";

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Enter Text'),
                                    content: TextField(
                                      controller: _dialogTextFieldController,
                                      maxLines: 2,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          currentlySelected = addText(list, _dialogTextFieldController.text, screenWidth);
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: const Text('OK'),
                                      )
                                    ],
                                  );
                                }
                              );

                              // currentlySelected = add(list);
                              // setState(() {});
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
                                flipHorizontally(list, currentlySelected);
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
                                flipVertically(list, currentlySelected);
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
                                list.removeAt(currentlySelected);
                                setState(() {
                                  currentlySelected = -1;
                                });
                              }
                            },
                            child: Center(
                              child: Column(
                                children: const [
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                          child: TextButton(
                            onPressed: () {
                              //Navigator.of(context).pushNamed(secondRoute);

                              String? s = ((list[currentlySelected] as TextModel).textPainter.text as TextSpan).text;

                              int cnt = 0;

                              for(int i = 0; i < s!.length; i++) {
                                if(s[i] == '\n') {
                                  cnt++;
                                }
                              }

                              print(cnt);
                            },
                            child: Center(
                              child: Column(
                                children: const [
                                  Text('Second'),
                                  //Text('Rotation'),
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
      ),
    );
  }
}
