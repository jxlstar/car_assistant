import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapDetailPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  final String deviceName;
  
  const MapDetailPage({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.deviceName,
  }) : super(key: key);

  @override
  State<MapDetailPage> createState() => _MapDetailPageState();
}

class _MapDetailPageState extends State<MapDetailPage> {
  GoogleMapController? _mapController;
  Location location = Location();
  Set<Marker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }
  
  void _initializeMarkers() {
    _markers.add(
      Marker(
        markerId: MarkerId('device_location'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.deviceName,
          snippet: widget.locationName,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '设备位置',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.blue),
            onPressed: _goToDeviceLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Google地图区域
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 15.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),
          ),
          // 底部信息卡片
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '设备位置信息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildInfoRow('设备名称', widget.deviceName),
                _buildInfoRow('位置', widget.locationName),
                _buildInfoRow('经度', widget.longitude.toStringAsFixed(6)),
                _buildInfoRow('纬度', widget.latitude.toStringAsFixed(6)),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openInMaps,
                        icon: Icon(Icons.navigation, size: 18),
                        label: Text('导航'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _shareLocation,
                        icon: Icon(Icons.share, size: 18),
                        label: Text('分享位置'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToDeviceLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 18.0,
          ),
        ),
      );
    }
  }

  void _openInMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    _showMessage('打开Google地图导航');
  }

  void _shareLocation() {
    _showMessage('分享设备位置: ${widget.latitude}, ${widget.longitude}');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}