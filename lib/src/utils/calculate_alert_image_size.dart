double calculateAlertImageSize(double zoom) {
  double minSize = 50;
  double maxSize = 200;

  double minZoom = 10;
  double maxZoom = 20;

  if (zoom < minZoom) {
    return minSize;
  } else if (zoom > maxZoom) {
    return maxSize;
  }

  double size = minSize + ((zoom - minZoom) / (maxZoom - minZoom)) * (maxSize - minSize);
  return size;
}