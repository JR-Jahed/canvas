import 'package:canvas_object/canvas_model.dart';
import 'package:flutter/material.dart';

class TextModel extends CanvasModel {

  String originalText;
  TextPainter textPainter;
  bool shouldDrawText;
  SizedBox box;

  TextModel(
      {required super.matrix,
      required super.matrixFrame,
      required super.selected,
      required super.rotation,
      required super.curCircles,
      required super.width,
      required super.height,
      required super.widthAfterScaling,
      required super.heightAfterScaling,
      required super.midX,
      required super.midY,

      required this.originalText,
      required this.textPainter,
      this.shouldDrawText = true,
      this.box = const SizedBox(),
      });
}
