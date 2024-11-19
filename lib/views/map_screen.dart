import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  //Controlador de Mapas
  late GoogleMapController mapController;

  //Posición actual
  LatLng? _currentPosition;

  //TextControllers para el Origen y el Destino
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // Inicializar el servicio de ubicación
  final LocationService locationService = LocationService();

  //Estado de la pantalla de los mapas
  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  // Establecer la ubicación actual
  Future<void> _setCurrentLocation() async {
    Position? position = await locationService.getLocation();
    if (position != null) {
      setState(() {
        _currentPosition = const LatLng(18.850486450318503, -99.20070331772618);
      });
    }
  }

  // Configurar el controlador del mapa
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  //Decodificar la polilínea
  List<LatLng> decodePoly(String encoded) {
    List<LatLng> points = <LatLng>[];
    int index = 0,
        len = encoded.length;
    int lat = 0,
        lng = 0;
    while (index < len) {
      int b,
          shift = 0,
          result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  //Dibujar la ruta en el mapa
  Set<Polyline> _polylines = {};

  void _drawRoute(List<LatLng> points) {
    setState(() {
      _polylines.add(Polyline(
        points: points,
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
      ));
    });
    print('Ruta Dibujada $_polylines');
  }

  //Funcion para Obtener la ruta
  Future<void> _getRoute() async {
    //Obtener la direccion de origen
    String origin = _originController.text;
    //Obtener la direccion de destino
    String destination = _destinationController.text;
    //Obteber la clave de la API de Google Maps
    String apiKey = 'AIzaSyCJfRC_2rutWnsTEkDI-X9-qmrX4amKDXo';
    //URL de la API de Google Maps
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';
    //Realizar la petición HTTP
    http.Response response = await http.get(Uri.parse(url));
    //Decoding de la respuesta
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      //Obtener la ruta
      List<dynamic> routes = data['routes'];
      //Obtener la información de la ruta
      Map<String, dynamic> route = routes[0];
      //Obtener la información de la polilínea
      Map<String, dynamic> polyline = route['overview_polyline'];
      //Obtener la codificación de la polilínea
      String points = polyline['points'];
      //Decodificar la polilínea
      List<LatLng> result = decodePoly(points);
      //Dibujar la ruta en el mapa
      _drawRoute(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: const LatLng(18.850486450318503, -99.20070331772618),
              zoom: 20.0,
            ),
            polylines: _polylines,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                TextField(
                  controller: _originController,
                  decoration: const InputDecoration(
                    hintText: 'Enter origin',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    hintText: 'Enter destination',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                ElevatedButton(
                  onPressed: _getRoute,
                  child: const Text('Get Route'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
