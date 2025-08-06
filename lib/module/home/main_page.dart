import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../equipment/equipment_page.dart';
import '../equipment/equipment_provider.dart';
import '../resources/resources_page.dart';
import '../dealers/dealers_page.dart';
import '../personal/personal_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  
  List<Widget> _getPages() {
    return [
      const EquipmentPage(),
      const ResourcesPage(),
      const DealersPage(),
      const PersonalPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.devices),
                label: 'Equipment',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Resources',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: 'Dealers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Personal',
              ),
            ],
          ),
        );
      }
}