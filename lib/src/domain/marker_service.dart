import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/calculate_alert_image_size.dart';
import '../utils/get_image_path.dart';
import 'package:flutter/material.dart';

void updateMarkerIcon(Set<Marker> markers, double currentZoom, List<dynamic> alerts) async {
  String imagePath = getImagePath(currentZoom);
  double imageSize = calculateAlertImageSize(currentZoom);
  BitmapDescriptor icon = await BitmapDescriptor.asset(
    ImageConfiguration(size: Size(imageSize, imageSize)), imagePath);
  updateMarkerFromAlerts(markers, alerts, icon);
}

void updateMarkerFromAlerts(Set<Marker> markers, List<dynamic> alerts, BitmapDescriptor icon) {

  markers.clear();
  for (var alert in alerts) {
    markers.add(
      Marker(
        markerId: MarkerId(alert['id'].toString()),
        position: LatLng(alert['latitude'], alert['longitude']),
        icon: icon,
        infoWindow: InfoWindow(
          title: alert['type'],
          snippet: alert['timestamp'],
        ),
      ),
    );
  }
}
