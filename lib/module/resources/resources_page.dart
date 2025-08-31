import 'package:car_assistant/module/resources/resources_logic.dart';
import 'package:car_assistant/module/resources/resources_state.dart';
import 'package:car_assistant/r.dart';
import 'package:car_assistant/utils/colors_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../equipment/fault_code_query/fault_code_query_page.dart';
import '../pdf/pdf_viewer_page.dart';

class BreadcrumbItem {
  final String title;
  final bool isSelected;

  BreadcrumbItem({required this.title, this.isSelected = false});
}

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {

  late final ResourcesLogic logic;
  late final ResourcesState state;

  @override
  void initState() {
    super.initState();
    logic = Get.put(ResourcesLogic());
    logic.loadAllResources();
    state = logic.state;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResourcesLogic>(
        init: logic,
        builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsUtil.hexColor('F1F5F8'),
          appBar: AppBar(
            title: const Text('Resources'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          body: _buildContent(),
        );
      }
    );
  }

  Widget _buildContent() {
    // Loading state
    if (state.isLoading && state.allBrands.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (state.errorMessage != null) {
      return _buildErrorState();
    }

    // Empty data state
    if (state.allBrands.isEmpty) {
      return _buildEmptyState();
    }

    // Normal data list
    return RefreshIndicator(
      onRefresh: () => logic.refreshCurrentData(),
      child: ListView.builder(
        itemCount: state.allBrands.length,
        itemBuilder: (context, index) {
          return _buildResourceItem(context, state.allBrands[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Resource Data',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No brand resources available\nPlease try again later or contact administrator',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => logic.refreshCurrentData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Failed',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'Network error, please try again later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => logic.refreshCurrentData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        leading: Image.network(item.imageUrl ?? '', height: 40,),
        // leading: Image.asset(R.assetsImageWaji, height: 40,),
        title: Text(
          item.name ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          logic.showDeviceTypes(item.id, item.name ?? '');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResourceSecondLevelPage(
                firstLevelTitle: item.name ?? '',
                logic: logic,
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

class ResourceSecondLevelPage extends StatefulWidget {
  final String firstLevelTitle;
  final ResourcesLogic logic;

  const ResourceSecondLevelPage({super.key, required this.firstLevelTitle, required this.logic});

  @override
  State<ResourceSecondLevelPage> createState() => _ResourceSecondLevelPageState();
}

class _ResourceSecondLevelPageState extends State<ResourceSecondLevelPage> {
  late final ResourcesLogic logic;
  late final ResourcesState state;

  @override
  void initState() {
    super.initState();
    logic = widget.logic;
    state = logic.state;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtil.hexColor('F1F5F8'),
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBreadcrumb([
            BreadcrumbItem(title: widget.firstLevelTitle, isSelected: false),
          ]),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // 空数据状态
    if (state.secondData.isEmpty) {
      return _buildEmptyState();
    }

    // 正常数据列表
    return ListView.builder(
      itemCount: state.secondData.length,
      itemBuilder: (context, index) {
        return _buildResourceItem(context, state.secondData[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Device Types',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No device types available for this brand\nPlease go back and select another brand',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Brand List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        leading: Image.network(item.imageUrl ?? '', height: 40,),
        // leading: Image.asset(R.assetsImageWaji, height: 40,),
        title: Text(
          item.name ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          logic.showModels(item.id, item.name ?? '');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResourceThirdLevelPage(
                firstLevelTitle: widget.firstLevelTitle,
                secondLevelTitle: item.name ?? '',
                logic: logic,
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

class ResourceThirdLevelPage extends StatefulWidget {
  final String firstLevelTitle;
  final String secondLevelTitle;
  final ResourcesLogic logic;

  const ResourceThirdLevelPage({
    super.key,
    required this.firstLevelTitle,
    required this.secondLevelTitle,
    required this.logic,
  });

  @override
  State<ResourceThirdLevelPage> createState() => _ResourceThirdLevelPageState();
}

class _ResourceThirdLevelPageState extends State<ResourceThirdLevelPage> {
  late final ResourcesLogic logic;
  late final ResourcesState state;

  @override
  void initState() {
    super.initState();
    logic = widget.logic;
    state = logic.state;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBreadcrumb([
            BreadcrumbItem(title: widget.firstLevelTitle, isSelected: false),
            BreadcrumbItem(title: widget.secondLevelTitle, isSelected: true),
          ]),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // 空数据状态
    if (state.threeData.isEmpty) {
      return _buildEmptyState();
    }
    // 正常数据列表
    return Container(
      color: ColorsUtil.hexColor('F1F5F8'),
      child: ListView.builder(
        itemCount: state.threeData.length,
        itemBuilder: (context, index) {
          return _buildResourceItem(context, state.threeData[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.precision_manufacturing_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Device Models',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No models available for this device type\nPlease go back and select another device type',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Device Types'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ),
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: Image.network(item.imageUrl ?? '', height: 40,),
          // leading: Image.asset(R.assetsImageWaji),
          title: Text(
            item.name ?? '',
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
                  firstLevelTitle: widget.firstLevelTitle,
                  secondLevelTitle: widget.secondLevelTitle,
                  thirdLevelTitle: item.name ?? '',
                  item: item,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(List<BreadcrumbItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
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

class ResourceFourthLevelPage extends StatefulWidget {
  final String firstLevelTitle;
  final String secondLevelTitle;
  final String thirdLevelTitle;
  final ResourceItem item;

  const ResourceFourthLevelPage({
    super.key,
    required this.firstLevelTitle,
    required this.secondLevelTitle,
    required this.thirdLevelTitle,
    required this.item
  });

  @override
  State<ResourceFourthLevelPage> createState() => _ResourceFourthLevelPageState();
}

class _ResourceFourthLevelPageState extends State<ResourceFourthLevelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBreadcrumb([
            BreadcrumbItem(title: widget.firstLevelTitle, isSelected: false),
            BreadcrumbItem(title: widget.secondLevelTitle, isSelected: false),
            BreadcrumbItem(title: widget.thirdLevelTitle, isSelected: true),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Image.network(widget.item.imageUrl ?? '', height: 80,),
                    // child: Image.asset(R.assetsImageWaji, height: 80,),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.name ?? '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
    return GestureDetector(
      onTap: (){
        if (title == 'Fault code query') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FaultCodeQueryPage(),
            ),
          );
        }
        if (title == 'Machine maintenance') {


          if (widget.item.maintenanceManuals != null && widget.item.maintenanceManuals!.isNotEmpty) {
            // 取第一个PDF文件
            final pdfUrl = widget.item.maintenanceManuals!.first;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerPage(
                  pdfUrl: pdfUrl,
                  title: 'Machine Maintenance Manual',
                ),
              ),
            );
          } else {
            // 显示没有可用文档的提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No maintenance manual available'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        if (title == 'Documents and manuals') {
          if (widget.item.operationManuals != null && widget.item.operationManuals!.isNotEmpty) {
            // 取第一个PDF文件
            final pdfUrl = widget.item.operationManuals!.first;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerPage(
                  pdfUrl: pdfUrl,
                  title: 'Operation Manual',
                ),
              ),
            );
          } else {
            // 显示没有可用文档的提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No operation manual available'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      },
      child: Container(
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
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(List<BreadcrumbItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
                  overflow: TextOverflow.clip,
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
      ),
    );
  }
}