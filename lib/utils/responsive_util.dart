import 'package:flutter/material.dart';

int getResponsiveCrossAxisCount(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 640) {
    return 1;
  } else if (screenWidth < 768) {
    return 2;
  } else if (screenWidth < 1024) {
    return 3;
  } else if (screenWidth < 1280) {
    return 4;
  } else if (screenWidth < 1368) {
    return 5;
  } else {
    return 6;
  }
}
