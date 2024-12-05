import 'dart:convert';
import 'package:flutter/services.dart';

Future<List> loadAlerts() async {
  List<dynamic> alerts = [];
  String response = await rootBundle.loadString('lib/assets/json/alert_locations.json');
  final data = json.decode(response);
  alerts = data['alerts'];
  return (alerts);
}