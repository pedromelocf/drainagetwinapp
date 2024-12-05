import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/json_loader.dart';
import '../data/map_style.dart';
import '../domain/marker_service.dart';
import '../domain/user_location_service.dart';
import '../utils/init_camera.dart';
import '../presentation/show_current_alerts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer<
      GoogleMapController>();
  Set<Marker> _markers = {};
  double _currentZoom = 12.0;
  List<dynamic> _alerts = [];
  CameraPosition _initialPosition = initCamera();

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      List<dynamic> loadedAlerts = await loadAlerts();
      setState(() {
        _alerts = loadedAlerts;
      });
    } catch (e) {
      debugPrint('Erro ao carregar alertas: $e');
    }
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
              updateMarkerIcon(_markers, _currentZoom, _alerts);
            },
            onCameraMove: (position) {
              setState(() {
                _currentZoom = position.zoom;
                updateMarkerIcon(_markers, _currentZoom, _alerts);
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
              onPressed: () => handleGoToUserLocation(context, _controller),
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
              onPressed: () => showCurrentAlerts(context, _alerts, _controller),
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
}
