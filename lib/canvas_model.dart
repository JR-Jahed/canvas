import 'package:canvas_object/pair.dart';
import 'package:flutter/material.dart';

class CanvasModel {
  Matrix4 matrix;
  Matrix4 matrixFrame;
  bool selected;
  Offset begin;

  double scaleX;
  double scaleY;
  double rotation;
  double width;
  double height;
  double widthAfterScaling;
  double heightAfterScaling;
  double midX;
  double midY;

  bool isFlippedHorizontally;
  bool isFlippedVertically;

  List<Pair<Offset, double>> curCircles;

  CanvasModel({
    required this.matrix,
    required this.matrixFrame,
    required this.selected,
    required this.begin,
    this.scaleX = 1,
    this.scaleY = 1,
    required this.rotation,
    required this.curCircles,
    this.width = 0,
    this.height = 0,
    this.widthAfterScaling = -1,
    this.heightAfterScaling = -1,
    this.midX = -1,
    this.midY = -1,
    this.isFlippedHorizontally = false,
    this.isFlippedVertically = false,
  });
}
