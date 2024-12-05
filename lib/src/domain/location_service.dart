import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
  try {
    final apiKey = 'APIKEY';
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final place = data['results'][0];
      final formattedAddress = place['formatted_address'];
      return formattedAddress;
    } else {
      return 'Erro na solicitação: ${response.statusCode}';
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
