import 'package:flutter/material.dart';

const int minWidth = 40;
const int minHeight = 20;
const List<int> rotate1 = [1, 3, 0, 2];
const List<int> rotate2 = [3, 2, 1, 0];
const List<int> rotate3 = [2, 0, 3, 1];

Matrix4 downMat = Matrix4.zero();
Matrix4 opMat = Matrix4.zero();
Matrix4 downMatFrame = Matrix4.zero();
Matrix4 opMatFrame = Matrix4.zero();