String getImagePath(double currentZoom) {
  if (currentZoom >= 13) {
    return ('lib/assets/images/alert_low.png');
  } else {
    return ('lib/assets/images/alert_far.png');
  }
}