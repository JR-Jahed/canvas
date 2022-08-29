import 'package:canvas_object/pair.dart';
import 'package:canvas_object/util.dart';
import 'package:canvas_object/values.dart';
import 'package:flutter/material.dart';

class CanvasModel {
  Matrix4 matrix;
  Matrix4 matrixFrame;
  bool selected;

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
    this.scaleX = 1,
    this.scaleY = 1,
    required this.rotation,
    required this.curCircles,
    required this.width,
    required this.height,
    required this.widthAfterScaling,
    required this.heightAfterScaling,
    this.midX = -1,
    this.midY = -1,
    this.isFlippedHorizontally = false,
    this.isFlippedVertically = false,
  });

  // for translation we first need to rotate the object at (-r) degrees if the object is currently rotated at r degrees
  // after performing translation we need to rotate the object at r degrees again
  // without performing rotation desired translation cannot be achieved

  void translate(double tX, double tY) {
    opMat.setFrom(downMat);
    opMat.rotateZ(degToRad(-rotation * (isFlippedHorizontally ? -1 : 1)
        * (isFlippedVertically ? -1 : 1)));
    opMat.translate(tX, tY);
    opMat.rotateZ(degToRad(rotation * (isFlippedHorizontally ? -1 : 1)
        * (isFlippedVertically ? -1 : 1)));
    matrix.setFrom(opMat);


    opMatFrame.setFrom(downMatFrame);
    opMatFrame.rotateZ(degToRad(-rotation));
    opMatFrame.translate(tX * (isFlippedHorizontally ? -1 : 1), tY * (isFlippedVertically ? -1 : 1));
    opMatFrame.rotateZ(degToRad(rotation));
    matrixFrame.setFrom(opMatFrame);
  }

  // we cannot specify the pivot point in flutter
  // to scale with respect to the midpoint we need to translate the object so that the beginning or upper-left point
  // moves to midpoint and then scale the object and finally reverse the translation so that beginning point
  // comes to its place. if we don't perform this operation scaling will be performed with respect to the beginning point

  void scale(double scaleX, double scaleY, double tX, double tY) {
    opMat.setFrom(downMat);
    opMat.translate(tX, tY);
    opMat.scale(scaleX, scaleY, 1);
    opMat.translate(-tX, -tY);
    matrix.setFrom(opMat);


    opMatFrame.setFrom(downMatFrame);
    opMatFrame.translate(tX, tY);
    opMatFrame.scale(scaleX, scaleY, 1);
    opMatFrame.translate(-tX, -tY);
    matrixFrame.setFrom(opMatFrame);
  }

  // to flip horizontally we need to translate the object horizontally so that beginning point moves to midpoint horizontally
  // after performing flip we need to reverse the translation
  // to perform flip operation we just multiply scaling factor by -1.  in matrix scaling factor in X axis is stored
  // in pos[0][0] or matrix.storage[0] if we consider it as a list

  void flipHorizontally() {

    opMat.setFrom(downMat);
    opMat.translate(width / 2, 0);

    double r;

    if(isFlippedHorizontally) {
      r = rotation;
    }
    else {
      r = -rotation;
    }

    opMat.rotateZ(degToRad(r));
    opMat.storage[0] *= -1;

    if(isFlippedHorizontally) {
      r = rotation;
    }
    else {
      r = -rotation;
    }

    opMat.rotateZ(degToRad(r));
    isFlippedHorizontally ^= true;

    opMat.translate(-width / 2, 0);
    matrix.setFrom(opMat);
  }

  // to flip vertically we need to translate the object vertically so that beginning point moves to midpoint vertically
  // after performing flip we need to reverse the translation
  // to perform flip operation we just multiply scaling factor by -1.  in matrix scaling factor in Y axis is stored
  // in pos[1][1] or matrix.storage[5] if we consider it as a list

  void flipVertically() {

    opMat.setFrom(downMat);
    opMat.translate(width / 2, height / 2);

    double r;

    if(isFlippedVertically) {
      r = rotation;
    }
    else {
      r = -rotation;
    }

    opMat.rotateZ(degToRad(r));
    opMat.storage[5] *= -1;
    if(isFlippedVertically) {
      r = rotation;
    }
    else {
      r = -rotation;
    }

    opMat.rotateZ(degToRad(r));
    isFlippedVertically ^= true;

    opMat.translate(-width / 2, -height / 2);
    matrix.setFrom(opMat);
  }


  // if the object is flipped in any direction then rotation is performed in opposite direction
  // to prevent that we multiply rotation angle by -1

  double modifiedRotation(double r) {
    return r * (isFlippedHorizontally ? -1 : 1)
        * (isFlippedVertically ? -1 : 1);
  }


  // to rotate with respect to midpoint we translate the object so that beginning point moves to midpoint
  // perform rotation and translate the object to its original position again

  void rotate(double r, double tX, double tY) { // accepts angle in radian
    opMat.setFrom(downMat);
    opMat.translate(tX, tY);
    opMat.rotateZ(modifiedRotation(r));
    opMat.translate(-tX, -tY);
    matrix.setFrom(opMat);


    opMatFrame.setFrom(downMatFrame);
    opMatFrame.translate(tX, tY);
    opMatFrame.rotateZ(r);
    opMatFrame.translate(-tX, -tY);
    matrixFrame.setFrom(opMatFrame);
  }


}

































