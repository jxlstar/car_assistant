import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../r.dart';
import '../equipment/equipment_page.dart';
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
            items:  [
              BottomNavigationBarItem(
                icon: Image.asset(R.assetsImageHomeIcon,height: 24),
                activeIcon: Image.asset(R.assetsImageHomeIconSelect, height: 24),
                label: 'Equipment',
              ),
              BottomNavigationBarItem(
                icon:Image.asset(R.assetsImageSourceIcon,height: 24),
                activeIcon: Image.asset(R.assetsImageSourceIconSelect, height: 24),
                label: 'Resources',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(R.assetsImageDealersIcon,height: 24),
                activeIcon: Image.asset(R.assetsImageDealersIconSelect, height: 24),
                label: 'Dealers',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(R.assetsImagePersonalIcon,height: 24),
                activeIcon: Image.asset(R.assetsImagePersonalIconSelect, height: 24),
                label: 'Personal',
              ),
            ],
          ),
        );
      }
}