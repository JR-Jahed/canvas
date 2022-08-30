import 'dart:math';

import 'package:canvas_object/pair.dart';
import 'package:canvas_object/stickermodel.dart';
import 'package:canvas_object/values.dart';
import 'package:flutter/material.dart';
import 'package:canvas_object/paint.dart';
import 'canvas_model.dart';
import 'text.dart';

class Painter extends CustomPainter {

  final List<CanvasModel> list;

  Painter({required this.list,});

  @override
  void paint(Canvas canvas, Size size) {

    for(int i = 0; i < list.length; i++) {

      canvas.save();

      Matrix4 matrix = Matrix4.identity();
      matrix.setFrom(list[i].matrix);

      if(list[i].isFlippedHorizontally && list[i].isFlippedVertically) {
        opMat.setFrom(matrix);
        opMat.translate(list[i].width / 2, list[i].height / 2);
        opMat.rotateZ(pi);
        opMat.translate(-list[i].width / 2, -list[i].height / 2);
        matrix.setFrom(opMat);
      }

      canvas.transform(matrix.storage);

      if(list[i] is TextModel && (list[i] as TextModel).shouldDrawText) {
        (list[i] as TextModel).textPainter.paint(
            canvas, const Offset(5, 5));
      }

      if(list[i] is StickerModel) {
        canvas.drawImage((list[i] as StickerModel).image, const Offset(0, 0), Paint());
      }

      if(list[i].selected) {
        canvas.restore();
        canvas.save();
        canvas.transform(list[i].matrixFrame.storage);

        canvas.drawRect(Rect.fromLTWH(0, 0, list[i].width, list[i].height), paintObject);

        if(list[i].curCircles.isEmpty) {
          addToList(i);
        }

        for(int j = 0; j < list[i].curCircles.length; j++) {
          if(j <= 3) {
            canvas.drawCircle(
                list[i].curCircles[j].first, list[i].curCircles[j].second,
                paintRed);
          }
          else if(j == 4) {
            canvas.drawCircle(list[i].curCircles[j].first, list[i].curCircles[j].second, paintGreen);
          }
        }
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void addToList(int i) {
    list[i].curCircles.add(Pair(first: const Offset(0, 0), second: 5));

    list[i].curCircles.add(Pair(first: Offset(list[i].width, 0), second: 5));

    list[i].curCircles.add(Pair(first: Offset(0, list[i].height), second: 5));

    list[i].curCircles.add(Pair(first: Offset(list[i].width, list[i].height), second: 5));

    list[i].curCircles.add(Pair(first: Offset(list[i].width / 2, list[i].height + 50), second: 5));
  }
}



















