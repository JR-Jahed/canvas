import 'package:canvas_object/pair.dart';
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
      canvas.transform(list[i].matrix.storage);

      if(list[i] is TextModel && (list[i] as TextModel).shouldDrawText) {
        (list[i] as TextModel).textPainter.paint(
            canvas, Offset(list[i].begin.dx + 5, list[i].begin.dy + 5));
      }

      if(list[i].selected) {
        canvas.restore();
        canvas.save();
        canvas.transform(list[i].matrixFrame.storage);

        canvas.drawRect(Rect.fromLTWH(list[i].begin.dx, list[i].begin.dy, list[i].width, list[i].height), paintObject);

        if(list[i].curCircles.isEmpty) {
          addToList(i);
        }

        for(int j = 0; j < list[i].curCircles.length; j++) {
          if(j <= 3) {
            canvas.drawCircle(
                list[i].curCircles[j].first, list[i].curCircles[j].second,
                paintRed);
          }
          else {
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
    list[i].curCircles.add(Pair(first: list[i].begin, second: 5));

    list[i].curCircles.add(Pair(first: Offset(list[i].begin.dx + list[i].width, list[i].begin.dy), second: 5));

    list[i].curCircles.add(Pair(first: Offset(list[i].begin.dx, list[i].begin.dy + list[i].height), second: 5));

    list[i].curCircles.add(Pair(first: Offset(list[i].begin.dx + list[i].width,
        list[i].begin.dy + list[i].height), second: 5));

    list[i].curCircles.add(Pair(first: Offset(list[i].begin.dx + list[i].width / 2,
        list[i].begin.dy + list[i].height + 50), second: 5));
  }
}
