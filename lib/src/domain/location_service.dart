import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return '${place.street}, ${place.administrativeArea}, ${place.country}';
    } else {
      return 'Endereço não encontrado';
    }
  } catch (e) {
    return 'Erro ao obter endereço: $e';
  }
}

Future<void> showAlertInfo(BuildContext context, Map<String, dynamic> alert) async {
  double latitude = alert['latitude'];
  double longitude = alert['longitude'];
  String address;

  try {
    address = await getAddressFromCoordinates(latitude, longitude);
  } catch (e) {
    address = 'Não foi possível obter o endereço';
  }

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 300.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1.0,
              child: AlertDialog(
                title: Text('Informações do Alerta'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo: ${alert['type'] ?? 'Desconhecido'}'),
                    SizedBox(height: 8),
                    Text('Data: ${alert['timestamp'] ?? 'Sem data'}'),
                    SizedBox(height: 8),
                    Text('Endereço: $address'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
