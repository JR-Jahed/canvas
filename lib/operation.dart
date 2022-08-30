import 'canvas_model.dart';
import 'values.dart';
import 'util.dart';


// for translation we first need to rotate the object at (-r) degrees if the object is currently rotated at r degrees
// after performing translation we need to rotate the object at r degrees again
// without performing rotation desired translation cannot be achieved

void translate(double tX, double tY, List<CanvasModel> list, int currentlySelected) {
  opMat.setFrom(downMat);
  opMat.rotateZ(degToRad(-list[currentlySelected].rotation * (list[currentlySelected].isFlippedHorizontally ? -1 : 1)
      * (list[currentlySelected].isFlippedVertically ? -1 : 1)));
  opMat.translate(tX, tY);
  opMat.rotateZ(degToRad(list[currentlySelected].rotation * (list[currentlySelected].isFlippedHorizontally ? -1 : 1)
      * (list[currentlySelected].isFlippedVertically ? -1 : 1)));
  list[currentlySelected].matrix.setFrom(opMat);


  opMatFrame.setFrom(downMatFrame);
  opMatFrame.rotateZ(degToRad(-list[currentlySelected].rotation));
  opMatFrame.translate(tX * (list[currentlySelected].isFlippedHorizontally ? -1 : 1), tY* (list[currentlySelected].isFlippedVertically ? -1 : 1));
  opMatFrame.rotateZ(degToRad(list[currentlySelected].rotation));
  list[currentlySelected].matrixFrame.setFrom(opMatFrame);
}

// we cannot specify the pivot point in flutter
// to scale with respect to the midpoint we need to translate the object so that the beginning or upper-left point
// moves to midpoint and then scale the object and finally reverse the translation so that beginning point
// comes to its place. if we don't perform this operation scaling will be performed with respect to the beginning point

void scale(double scaleX, double scaleY, double tX, double tY, List<CanvasModel> list, int currentlySelected) {
  opMat.setFrom(downMat);
  opMat.translate(tX, tY);
  opMat.scale(scaleX, scaleY, 1);
  opMat.translate(-tX, -tY);
  list[currentlySelected].matrix.setFrom(opMat);


  opMatFrame.setFrom(downMatFrame);
  opMatFrame.translate(tX, tY);
  opMatFrame.scale(scaleX, scaleY, 1);
  opMatFrame.translate(-tX, -tY);
  list[currentlySelected].matrixFrame.setFrom(opMatFrame);
}

void scale2(double scaleX, double scaleY, double tX, double tY, List<CanvasModel> list, int currentlySelected) {
  opMat.setFrom(downMat);
  opMat.translate(tX, tY);
  opMat.storage[0] = scaleX;
  opMat.storage[5] = scaleY;
  opMat.translate(-tX, -tY);
  list[currentlySelected].matrix.setFrom(opMat);


  opMatFrame.setFrom(downMatFrame);
  opMatFrame.translate(tX, tY);
  opMatFrame.storage[0] = scaleX;
  opMatFrame.storage[5] = scaleY;
  opMatFrame.translate(-tX, -tY);
  list[currentlySelected].matrixFrame.setFrom(opMatFrame);
}



// if the object is flipped in any direction then rotation is performed in opposite direction
// to prevent that we multiply rotation angle by -1

double modifiedRotation(double r, List<CanvasModel> list, int currentlySelected) {
  return r * (list[currentlySelected].isFlippedHorizontally ? -1 : 1)
      * (list[currentlySelected].isFlippedVertically ? -1 : 1);
}


// to rotate with respect to midpoint we translate the object so that beginning point moves to midpoint
// perform rotation and translate the object to its original position again

void rotate(double r, double tX, double tY, List<CanvasModel> list, int currentlySelected) { // accepts angle in radian
  opMat.setFrom(downMat);
  opMat.translate(tX, tY);
  opMat.rotateZ(modifiedRotation(r, list, currentlySelected));
  opMat.translate(-tX, -tY);
  list[currentlySelected].matrix.setFrom(opMat);


  opMatFrame.setFrom(downMatFrame);
  opMatFrame.translate(tX, tY);
  opMatFrame.rotateZ(r);
  opMatFrame.translate(-tX, -tY);
  list[currentlySelected].matrixFrame.setFrom(opMatFrame);
}



// to flip horizontally we need to translate the object horizontally so that beginning point moves to midpoint horizontally
// after performing flip we need to reverse the translation
// to perform flip operation we just multiply scaling factor by -1.  in matrix scaling factor in X axis is stored
// in pos[0][0] or matrix.storage[0] if we consider it as a list

void flipHorizontally(List<CanvasModel> list, int currentlySelected) {

  if(list[currentlySelected].isFlippedHorizontally && list[currentlySelected].isFlippedVertically) {
    bothFlipVertical(list, currentlySelected);

    list[currentlySelected].isFlippedHorizontally = false;
    return;
  }

  if(!list[currentlySelected].isFlippedHorizontally) {
    if(list[currentlySelected].isFlippedVertically) {
      flipVertically2(list, currentlySelected);
    }
    else {
      flipHorizontally2(list, currentlySelected);
    }

    list[currentlySelected].isFlippedHorizontally = true;
  }
  else {
    if(list[currentlySelected].isFlippedVertically) {
      flipVertically2(list, currentlySelected);
    }
    else {
      flipHorizontally2(list, currentlySelected);
    }

    list[currentlySelected].isFlippedHorizontally = false;
  }
}

void flipHorizontally2(List<CanvasModel> list, int currentlySelected) {

  opMat.setFrom(downMat);
  opMat.translate(list[currentlySelected].width / 2, list[currentlySelected].height / 2);

  double r;

  if(list[currentlySelected].isFlippedHorizontally) {
    r = list[currentlySelected].rotation;
  }
  else {
    r = -list[currentlySelected].rotation;
  }

  opMat.rotateZ(degToRad(r));
  opMat.storage[0] *= -1;

  opMat.rotateZ(degToRad(r));

  opMat.translate(-list[currentlySelected].width / 2, -list[currentlySelected].height / 2);
  list[currentlySelected].matrix.setFrom(opMat);

}



// to flip vertically we need to translate the object vertically so that beginning point moves to midpoint vertically
// after performing flip we need to reverse the translation
// to perform flip operation we just multiply scaling factor by -1.  in matrix scaling factor in Y axis is stored
// in pos[1][1] or matrix.storage[5] if we consider it as a list

void flipVertically(List<CanvasModel> list, int currentlySelected) {

  if(list[currentlySelected].isFlippedHorizontally && list[currentlySelected].isFlippedVertically) {
    bothFlipHorizontal(list, currentlySelected);
    list[currentlySelected].isFlippedVertically = false;
    return;
  }

  if(!list[currentlySelected].isFlippedVertically) {
    if (list[currentlySelected].isFlippedHorizontally) {
      flipHorizontally2(list, currentlySelected);
    }
    else {
      flipVertically2(list, currentlySelected);
    }

    list[currentlySelected].isFlippedVertically = true;
  }
  else {
    if(list[currentlySelected].isFlippedHorizontally) {

      flipHorizontally2(list, currentlySelected);
    }
    else {
      flipVertically2(list, currentlySelected);
    }

    list[currentlySelected].isFlippedVertically = false;
  }
}



void flipVertically2(List<CanvasModel> list, int currentlySelected) {
  opMat.setFrom(downMat);
  opMat.translate(list[currentlySelected].width / 2, list[currentlySelected].height / 2);

  double r;

  if(list[currentlySelected].isFlippedVertically) {
    r = list[currentlySelected].rotation;
  }
  else {
    r = -list[currentlySelected].rotation;
  }

  opMat.rotateZ(degToRad(r));
  opMat.storage[5] *= -1;

  opMat.rotateZ(degToRad(r));

  opMat.translate(-list[currentlySelected].width / 2, -list[currentlySelected].height / 2);
  list[currentlySelected].matrix.setFrom(opMat);
}

void bothFlipHorizontal(List<CanvasModel> list, int currentlySelected) {

  opMat.setFrom(downMat);
  opMat.translate(list[currentlySelected].width / 2, list[currentlySelected].height / 2);

  opMat.rotateZ(degToRad(-list[currentlySelected].rotation));
  opMat.storage[0] *= -1;

  opMat.rotateZ(degToRad(-list[currentlySelected].rotation));

  opMat.translate(-list[currentlySelected].width / 2, -list[currentlySelected].height / 2);
  list[currentlySelected].matrix.setFrom(opMat);
}

void bothFlipVertical(List<CanvasModel> list, int currentlySelected) {

  opMat.setFrom(downMat);
  opMat.translate(list[currentlySelected].width / 2, list[currentlySelected].height / 2);

  opMat.rotateZ(degToRad(-list[currentlySelected].rotation));
  opMat.storage[5] *= -1;

  opMat.rotateZ(degToRad(-list[currentlySelected].rotation));

  opMat.translate(-list[currentlySelected].width / 2, -list[currentlySelected].height / 2);
  list[currentlySelected].matrix.setFrom(opMat);
}
