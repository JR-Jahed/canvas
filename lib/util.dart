import 'dart:math';
import 'dart:ui';
import 'package:canvas_object/pair.dart';
import 'package:flutter/material.dart';
import 'canvas_model.dart';


// this function deselects all the objects. there should be only one selected object at any given moment
void deselectAll(List<CanvasModel> list) {
  for (int i = 0; i < list.length; i++) {
    list[i].selected = false;
  }
}


// this function adds a new object to the list
int add(List<CanvasModel> list) {
  deselectAll(list);
  list.add(
    CanvasModel(
        matrix: Matrix4.identity(),
        matrixFrame: Matrix4.identity(),
        begin: const Offset(0, 0),
        selected: true,
        rotation: 0,
        curCircles: [],
    ),
  );

  return list.length - 1;
}


// this function returns the index of the object if the user tapped on it and -1 if the user tapped inside no object

int getIdx(double x, double y, List<CanvasModel> list) {
  int ans = -1;

  for (int i = 0; i < list.length; i++) {
    double curWidth = (list[i].widthAfterScaling < 0
        ? list[i].width
        : list[i].widthAfterScaling);
    double curHeight = (list[i].heightAfterScaling < 0
        ? list[i].height
        : list[i].heightAfterScaling);

    double beginX = list[i].begin.dx + list[i].matrixFrame.getTranslation().x;
    double beginY = list[i].begin.dy + list[i].matrixFrame.getTranslation().y;

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

  double curWidth = (list[currentlySelected].widthAfterScaling < 0
      ? list[currentlySelected].width
      : list[currentlySelected].widthAfterScaling);
  double curHeight = (list[currentlySelected].heightAfterScaling < 0
      ? list[currentlySelected].height
      : list[currentlySelected].heightAfterScaling);

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

  tmp.add(Offset(upperLeft.dx + curWidth / 2, upperLeft.dy + curHeight * 2));

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