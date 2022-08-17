import 'package:canvas_object/pair.dart';
import 'package:flutter/material.dart';
import 'package:canvas_object/paint.dart';

import 'canvas_model.dart';

class Painter extends CustomPainter {

  final List<CanvasModel> list;

  Painter({required this.list});

  static final TextPainter textPainter = TextPainter(
    text: const TextSpan(
      text: 'HELLO',
      style: TextStyle(
        color: Colors.black,
        fontSize: 30,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  @override
  void paint(Canvas canvas, Size size) {

    textPainter.layout(maxWidth: size.width - 35);

    for(int i = 0; i < list.length; i++) {

      canvas.save();
      canvas.transform(list[i].matrix.storage);

      list[i].width = textPainter.width + 10;
      list[i].height = textPainter.height + 10;

      textPainter.paint(canvas, Offset(list[i].begin.dx + 5, list[i].begin.dy + 5));

      if(list[i].selected) {
        canvas.drawRect(Rect.fromLTWH(list[i].begin.dx, list[i].begin.dy, textPainter.width + 10, textPainter.height + 10), paintObject);

        // we should add to list only when an object gets painted for the first time
        if(list[i].curCircles.isEmpty) {
          addToList(i);
        }

        for(int j = 0; j < list[i].curCircles.length; j++) {
          if(j <= 3) {
            canvas.drawCircle(
                list[i].curCircles[j].first, list[i].curCircles[j].second,
                paintRed);
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
  }
}
