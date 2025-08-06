import 'package:flutter/material.dart';
import 'device_detail_page.dart';

class DeviceSearchPage extends StatefulWidget {
  @override
  _DeviceSearchPageState createState() => _DeviceSearchPageState();
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> devices = [
    {
      'name': 'R-10',
      'model': 'R-10',
      'pin': 'KBCGJ99KKHGV9965',
      'hours': '134.9h',
      'image': 'assets/images/excavator_blue.png',
    },
    {
      'name': 'R-319',
      'model': 'R-319',
      'pin': 'KBCGJ99KKHGV4669',
      'hours': '192.1h',
      'image': 'assets/images/excavator_yellow.png',
    },
    {
      'name': 'RS20',
      'model': 'RS20',
      'pin': 'KBCGJ99KKHGV3482',
      'hours': '33.5h',
      'image': 'assets/images/skid_steer.png',
    },
  ];
  
  List<Map<String, dynamic>> filteredDevices = [];
  
  @override
  void initState() {
    super.initState();
    filteredDevices = devices;
    _searchController.addListener(_filterDevices);
  }
  
  void _filterDevices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredDevices = devices;
      } else {
        filteredDevices = devices.where((device) {
          return device['name'].toLowerCase().contains(query) ||
                 device['model'].toLowerCase().contains(query) ||
                 device['pin'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'R',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              suffixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredDevices.length,
        itemBuilder: (context, index) {
          final device = filteredDevices[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceDetailPage(device: device),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.construction,
                      color: index == 0 ? Colors.blue : (index == 1 ? Colors.orange : Colors.grey[600]),
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Model',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              device['model'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'PIN',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              device['pin'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Hours',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              device['hours'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}