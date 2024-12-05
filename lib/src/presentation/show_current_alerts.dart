import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/location_service.dart';

void showCurrentAlerts(BuildContext context, List<dynamic> alerts, Completer<GoogleMapController> controller) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Lista de Alertas'),
        content: SizedBox(
          width: double.maxFinite,
          child: alerts.isEmpty
              ? Center(child: Text('Nenhum alerta disponível'))
              : ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              var alert = alerts[index];
              return ListTile(
                title: Text(alert['type'] ?? 'Tipo de alerta desconhecido'),
                subtitle: Text(alert['timestamp'] ?? 'Sem data'),
                onTap: () {
                  Navigator.pop(context);
                  goToAlertLocation(alert['latitude'], alert['longitude'], controller);
                  showAlertInfo(context, alert);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Fechar'),
          ),
        ],
      );
    },
  );
}

Future<void> goToAlertLocation(double latitude, double longitude, Completer<GoogleMapController> controller) async {
  final GoogleMapController googleMapController = await controller.future;
  googleMapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15.0,
      ),
    ),
  );
}