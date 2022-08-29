import 'dart:math';
import 'package:canvas_object/pair.dart';
import 'package:canvas_object/text.dart';
import 'package:flutter/material.dart';
import 'canvas_model.dart';
import 'values.dart';


// this function deselects all the objects. there should be only one selected object at any given moment
void deselectAll(List<CanvasModel> list) {
  for (int i = 0; i < list.length; i++) {
    list[i].selected = false;
  }
}


// this function adds a new object to the list
// int add(List<CanvasModel> list) {
//   deselectAll(list);
//   list.add(
//     CanvasModel(
//         matrix: Matrix4.identity(),
//         matrixFrame: Matrix4.identity(),
//         selected: true,
//         rotation: 0,
//         curCircles: [],
//     ),
//   );
//
//   return list.length - 1;
// }

int addText(List<CanvasModel> list, String s, double width, Color color) {
  deselectAll(list);
  final textPainter = getTextPainter(s, width, color: color);

  list.add(TextModel(
    originalText: s,
    textPainter: textPainter,
    matrix: Matrix4.identity(),
    matrixFrame: Matrix4.identity(),
    selected: true,
    rotation: 0,
    curCircles: [],
    width: textPainter.width + 10,
    height: textPainter.height + 10,
    widthAfterScaling: textPainter.width + 10,
    heightAfterScaling: textPainter.height + 10,
    midX: (textPainter.width + 10) / 2,
    midY: (textPainter.height + 10) / 2,
  ));

  return list.length - 1;
}

// this function returns the index of the object if the user tapped on it and -1 if the user tapped inside no object

int getIdx(double x, double y, List<CanvasModel> list) {
  int ans = -1;

  for (int i = 0; i < list.length; i++) {
    double curWidth = list[i].widthAfterScaling;
    double curHeight = list[i].heightAfterScaling;

    double beginX = list[i].matrixFrame.getTranslation().x;
    double beginY = list[i].matrixFrame.getTranslation().y;

    Pair<double, double> p = unrotated(beginX, beginY, list[i]);
    beginX = p.first;
    beginY = p.second;

    double endX = beginX + curWidth;
    double endY = beginY + curHeight;

    p = unrotated(x, y, list[i]);
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

// this function returns the index of the circle if the user tapped on the circle and -1 if the tap is outside
// all the circles..    0 = upperLeft   1 = upperRight   2 = lowerLeft   3 = lowerRight  4 = lowerCenter
// the indexing is according to the order of insertion to the list in painter.dart file addToList function

int getIdxOfCircle(double x, double y, List<CanvasModel> list, int currentlySelected) {
  if (currentlySelected == -1) return -1;

  double curWidth = list[currentlySelected].widthAfterScaling;
  double curHeight = list[currentlySelected].heightAfterScaling;

  List<Offset> tmp = [];

  Offset upperLeft = Offset(
      list[currentlySelected].matrixFrame.getTranslation().x,
      list[currentlySelected].matrixFrame.getTranslation().y);

  Pair<double, double> p = unrotated(upperLeft.dx, upperLeft.dy, list[currentlySelected]);
  upperLeft = Offset(p.first, p.second);
  tmp.add(upperLeft);

  tmp.add(Offset(upperLeft.dx + curWidth, upperLeft.dy));

  tmp.add(Offset(upperLeft.dx, upperLeft.dy + curHeight));

  tmp.add(Offset(upperLeft.dx + curWidth, upperLeft.dy + curHeight));

  tmp.add(Offset(upperLeft.dx + curWidth / 2, upperLeft.dy + curHeight + 50 * list[currentlySelected].scaleY));

  //print('x = $x  y = $y');
  p = unrotated(x, y, list[currentlySelected]);
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

double degToRad(double deg) {
  return deg * pi / 180;
}
double radToDeg(double rad) {
  return rad * 180 / pi;
}

// this function returns the position where the point (x, y) would have been located at, had it not been rotated
// with respect to the midpoint of the object at ob.rotation degrees

Pair<double, double> unrotated(double x, double y, CanvasModel ob) {
  double newX = (x - ob.midX) * cos(degToRad(ob.rotation)) - (ob.midY - y) * sin(degToRad(ob.rotation)) + ob.midX;

  double newY = (ob.midX - x) * sin(degToRad(ob.rotation)) + (y - ob.midY) * cos(degToRad(ob.rotation)) + ob.midY;

  return Pair(first: newX, second: newY);
}

TextPainter getTextPainter(String s,
    double width,
    {
      Color color = Colors.black,
      double fontSize = defaultFontSize,
      double letterSpacing = defaultLetterSpacing}) {

  final textPainter = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      ),
    ),
    textAlign: TextAlign.justify,
    textDirection: TextDirection.ltr,
    maxLines: 5555,
  );

  textPainter.layout(maxWidth: width);

  return textPainter;
}

















