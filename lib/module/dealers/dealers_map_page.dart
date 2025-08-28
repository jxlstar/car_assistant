import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dealers_state.dart';

class DealersMapPage extends StatefulWidget {
  final List<DealerItem> dealers;

  const DealersMapPage({super.key, required this.dealers});

  @override
  State<DealersMapPage> createState() => _DealersMapPageState();
}

class _DealersMapPageState extends State<DealersMapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    final markers = <Marker>{};
    for (final dealer in widget.dealers) {
      if (dealer.latitude != null && dealer.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(dealer.id.toString()),
            position: LatLng(dealer.latitude!, dealer.longitude!),
            infoWindow: InfoWindow(
              title: dealer.dealerName,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }
    setState(() {
      _markers = markers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_markers.isNotEmpty) {
      _moveCameraToFitMarkers();
    }
  }

  void _moveCameraToFitMarkers() {
    if (_markers.isEmpty || _mapController == null) {
      return;
    }

    if (_markers.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_markers.first.position, 14),
      );
    } else {
      final LatLngBounds bounds = _boundsFromMarkers(_markers);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // 50 is padding
      );
    }
  }

  LatLngBounds _boundsFromMarkers(Set<Marker> markers) {
    double? minLat, maxLat, minLng, maxLng;

    for (final marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      if (minLat == null || lat < minLat) minLat = lat;
      if (maxLat == null || lat > maxLat) maxLat = lat;
      if (minLng == null || lng < minLng) minLng = lng;
      if (maxLng == null || lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealers Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194), // Default position
          zoom: 5,
        ),
        markers: _markers,
      ),
    );
  }
}