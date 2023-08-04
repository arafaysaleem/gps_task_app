import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_task_app/google_map_view_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final viewModel = GoogleMapViewModel();
  late final Future<LatLng> _mapLoadedFuture;

  @override
  void initState() {
    super.initState();
    _mapLoadedFuture = viewModel.loadCurrentUserCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _mapLoadedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return snapshot.hasError
              ? Center(
                  child: Text(
                    snapshot.error.toString(),
                  ),
                )
              : GoogleMapWidget(
                  currentUserLocation: snapshot.data as LatLng,
                  onMapCreated: (controller) {
                    viewModel.controller.complete(controller);
                  },
                );
        },
      ),
    );
  }
}

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({
    required this.onMapCreated,
    required this.currentUserLocation,
    super.key,
  });

  final void Function(GoogleMapController) onMapCreated;
  final LatLng currentUserLocation;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: currentUserLocation,
        zoom: 18,
      ),
      onMapCreated: onMapCreated,
      markers: {
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentUserLocation,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => MarkerCoordinatesDialog(
                latitude: currentUserLocation.latitude,
                longitude: currentUserLocation.longitude,
              ),
            );
          },
        ),
      },
    );
  }
}

class MarkerCoordinatesDialog extends StatelessWidget {
  const MarkerCoordinatesDialog({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude, longitude;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("User's Current Location"),
      content: Text(
        'Latitude: $latitude, Longitude: $longitude',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
