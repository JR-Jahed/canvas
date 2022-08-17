import 'dart:ui';
import 'canvas_model.dart';


int getIdx(double x, double y, List<CanvasModel> list) {
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

int getIdxOfCircle(double x, double y, List<CanvasModel> list, int currentlySelected) {
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