import 'package:flutter/material.dart';

const int minWidth = 40;
const int minHeight = 20;
const double defaultFontSize = 30;

const List<int> rotate1 = [1, 3, 0, 2]; //   45  < rotation < 135
const List<int> rotate2 = [3, 2, 1, 0]; //   135 < rotation < 225
const List<int> rotate3 = [2, 0, 3, 1]; //   225 < rotation < 315

Matrix4 downMat = Matrix4.zero();   // this matrix is used to store the current state of the matrix when user taps on any object
Matrix4 opMat = Matrix4.zero();     // operational matrix   we'll perform operation on this matrix
Matrix4 downMatFrame = Matrix4.zero();
Matrix4 opMatFrame = Matrix4.zero();