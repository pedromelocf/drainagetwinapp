import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> handleGoToUserLocation(BuildContext context,  Completer<GoogleMapController> controller) async {
  var status = await Permission.location.request();
  if (context.mounted) {
    if (status.isGranted) {
      await _goToUserLocation(context, controller);
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de localização necessária!')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            'Permissão negada permanentemente. Habilite nas configurações.')),
      );
      await openAppSettings();
    }
  }
}

Future<void> _goToUserLocation(BuildContext context,  Completer<GoogleMapController> controller) async {
  if (context.mounted) {
    try {
      Position position = await _currentPosition();
      final GoogleMapController googleMapController = await controller.future;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }
}

Future<Position> _currentPosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception("Serviço de localização está desativado.");
  }
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("Permissão negada.");
    }
  }
  return await Geolocator.getCurrentPosition();
}
