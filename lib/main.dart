import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'map_config/map_style.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Drainage Twin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer<
      GoogleMapController>();
  final Set<Marker> _markers = {};
  double _currentZoom = 12.0;
  List<dynamic> _alerts = [];

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-30.033056, -51.230000),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _updateMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _updateMarkerIcon();
            },
            onCameraMove: (position) {
              setState(() {
                _currentZoom = position.zoom;
                _updateMarkerIcon();
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            style: mapStyle,
          ),
          Positioned(
            bottom: 30,
            left: MediaQuery
                .of(context)
                .size
                .width / 2 - 28,
            child: FloatingActionButton(
              onPressed: _handleGoToLocation,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.assistant_navigation,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: FloatingActionButton(
              onPressed: _showCurrentAlerts,
              backgroundColor: Colors.red,
              child: Icon(
                Icons.crisis_alert,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrentAlerts() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lista de Alertas'),
          content: SizedBox(
            width: double.maxFinite,
            child: _alerts.isEmpty
                ? Center(child: Text('Nenhum alerta disponível'))
                : ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                var alert = _alerts[index];
                return ListTile(
                  title: Text(alert['type'] ?? 'Tipo de alerta desconhecido'),
                  subtitle: Text(alert['timestamp'] ?? 'Sem data'),
                  onTap: () {
                    Navigator.pop(context);
                    _goToAlertLocation(alert['latitude'], alert['longitude']);
                    _showAlertInfo(context, alert);
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

  Future<void> _handleGoToLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      await _goToUserLocation();
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

  Future<void> _goToAlertLocation(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 16.5,
        ),
      ),
    );
  }

  Future<void> _goToUserLocation() async {
    try {
      Position position = await _currentPosition();
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
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

  void _updateMarkerIcon() async {
    String imagePath;
    double imageSize;
    if (_currentZoom >= 13) {
      imagePath = 'assets/images/alert_low.png';
    }
    else {
      imagePath = 'assets/images/alert_far.png';
    }
    imageSize = _calculateImageSize(_currentZoom);

    BitmapDescriptor icon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(imageSize, imageSize)), imagePath,
    );

    String response = await rootBundle.loadString(
        'assets/json/alert_locations.json');
    final data = json.decode(response);
    _alerts = data['alerts'];

    _markers.clear();

    for (var alert in _alerts) {
      _markers.add(
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
}

double _calculateImageSize(double zoom) {
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

Future<void> _showAlertInfo(BuildContext context, Map<String, dynamic> alert) async {
  final currentContext = context;

  double latitude = alert['latitude'];
  double longitude = alert['longitude'];
  String address;

  try {
    address = await _getAddressFromCoordinates(latitude, longitude);
  } catch (e) {
    address = 'Não foi possível obter o endereço';
  }

  showDialog(
    context: currentContext,
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

Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
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