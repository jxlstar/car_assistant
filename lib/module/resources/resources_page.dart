import 'package:flutter/material.dart';

class BreadcrumbItem {
  final String title;
  final bool isSelected;

  BreadcrumbItem({required this.title, this.isSelected = false});
}

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: resourceItems.length,
        itemBuilder: (context, index) {
          return _buildResourceItem(context, resourceItems[index]);
        },
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context, ResourceItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            item.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResourceSecondLevelPage(
                firstLevelTitle: item.title,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumb(List<BreadcrumbItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: items[i].isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                items[i].title,
                style: TextStyle(
                  color: items[i].isSelected ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: items[i].isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ),]]
      ),
    );
  }
}

class ResourceItem {
  final String title;
  final IconData icon;
  final Color color;

  ResourceItem({required this.title, required this.icon, required this.color});
}

final List<ResourceItem> resourceItems = [
  ResourceItem(title: 'Brooms', icon: Icons.cleaning_services, color: Colors.grey),
  ResourceItem(title: 'Demolition', icon: Icons.construction, color: Colors.orange),
  ResourceItem(title: 'Bale Grabbers & Spears', icon: Icons.agriculture, color: Colors.green),
  ResourceItem(title: 'Grading & Scraping', icon: Icons.landscape, color: Colors.brown),
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
  ResourceItem(title: 'Brooms', icon: Icons.cleaning_services, color: Colors.grey),
  ResourceItem(title: 'Attachments', icon: Icons.build, color: Colors.blue),
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
  ResourceItem(title: 'Bale Grabbers & Spears', icon: Icons.agriculture, color: Colors.green),
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
];

final List<ResourceItem> secondLevelItems = [
  ResourceItem(title: 'Attachments', icon: Icons.build, color: Colors.blue),
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
  ResourceItem(title: 'Brooms', icon: Icons.cleaning_services, color: Colors.grey),
  ResourceItem(title: 'Demolition', icon: Icons.construction, color: Colors.orange),
  ResourceItem(title: 'Bale Grabbers & Spears', icon: Icons.agriculture, color: Colors.green),
  ResourceItem(title: 'Grading & Scraping', icon: Icons.landscape, color: Colors.brown),
];

final List<ResourceItem> thirdLevelItems = [
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
  ResourceItem(title: 'Brooms', icon: Icons.cleaning_services, color: Colors.grey),
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
  ResourceItem(title: 'Bale Grabbers & Spears', icon: Icons.agriculture, color: Colors.green),
  ResourceItem(title: 'Great Plains', icon: Icons.grass, color: Colors.lightGreen),
];

class ResourceSecondLevelPage extends StatelessWidget {
  final String firstLevelTitle;

  const ResourceSecondLevelPage({super.key, required this.firstLevelTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBreadcrumb([
            BreadcrumbItem(title: firstLevelTitle, isSelected: false),
          ]),
          Expanded(
            child: ListView.builder(
              itemCount: secondLevelItems.length,
              itemBuilder: (context, index) {
                return _buildResourceItem(context, secondLevelItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context, ResourceItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            item.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResourceThirdLevelPage(
                firstLevelTitle: firstLevelTitle,
                secondLevelTitle: item.title,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumb(List<BreadcrumbItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: items[i].isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                items[i].title,
                style: TextStyle(
                  color: items[i].isSelected ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: items[i].isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ),
          ],
        ],
      ),
    );
  }
}

class ResourceThirdLevelPage extends StatelessWidget {
  final String firstLevelTitle;
  final String secondLevelTitle;

  const ResourceThirdLevelPage({
    super.key,
    required this.firstLevelTitle,
    required this.secondLevelTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBreadcrumb([
            BreadcrumbItem(title: firstLevelTitle, isSelected: false),
            BreadcrumbItem(title: secondLevelTitle, isSelected: true),
          ]),
          Expanded(
            child: ListView.builder(
              itemCount: thirdLevelItems.length,
              itemBuilder: (context, index) {
                return _buildResourceItem(context, thirdLevelItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context, ResourceItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            item.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResourceFourthLevelPage(
                firstLevelTitle: firstLevelTitle,
                secondLevelTitle: secondLevelTitle,
                thirdLevelTitle: item.title,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumb(List<BreadcrumbItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: items[i].isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                items[i].title,
                style: TextStyle(
                  color: items[i].isSelected ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: items[i].isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ),
          ]
        ],
      ),
    );
  }
}

class ResourceFourthLevelPage extends StatelessWidget {
  final String firstLevelTitle;
  final String secondLevelTitle;
  final String thirdLevelTitle;

  const ResourceFourthLevelPage({
    super.key,
    required this.firstLevelTitle,
    required this.secondLevelTitle,
    required this.thirdLevelTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBreadcrumb([
            BreadcrumbItem(title: firstLevelTitle, isSelected: false),
            BreadcrumbItem(title: secondLevelTitle, isSelected: false),
            BreadcrumbItem(title: thirdLevelTitle, isSelected: true),
          ]),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'S317',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Equipment model',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard('Warranty Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard('Fault code query'),
                  const SizedBox(height: 12),
                  _buildInfoCard('Documents and manuals'),
                  const SizedBox(height: 12),
                  _buildInfoCard('Maintenance plan'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(List<BreadcrumbItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: items[i].isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                items[i].title,
                style: TextStyle(
                  color: items[i].isSelected ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: items[i].isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ),
          ]
        ],
      ),
    );
  }
}