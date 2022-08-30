import 'dart:ui' as ui;
import 'package:canvas_object/canvas_model.dart';

class StickerModel extends CanvasModel {

  ui.Image image;

  StickerModel({
    required super.matrix,
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

    required this.image,
  });

}
