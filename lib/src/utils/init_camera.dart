import 'package:google_maps_flutter/google_maps_flutter.dart';

CameraPosition initCamera() {
  const CameraPosition initialPosition = CameraPosition(
      target: LatLng(-30.033056, -51.230000),
      zoom: 12);
  return initialPosition;
}
