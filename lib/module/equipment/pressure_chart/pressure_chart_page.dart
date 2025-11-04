import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../utils/colors_util.dart';
import '../equipment_state.dart';
import 'dart:math' as math;

class PressureChartPage extends StatelessWidget {
  final String title;
  final List<LatestReport> latestReports;
  final bool isSystemPressure; // true表示系统压力，false表示先导压力

  const PressureChartPage({
    super.key,
    required this.title,
    required this.latestReports,
    required this.isSystemPressure,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtil.hexColor('F1F5F8'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPressureChart(),
              SizedBox(height: 20),
              _buildStatistics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPressureChart() {
    // 过滤有效数据
    final validReports = latestReports.where((report) {
      final pressureValue =
          isSystemPressure ? report.systemStatus : report.pilotStatus;
      return pressureValue != null;
    }).toList();

    if (validReports.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
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
        child: Center(
          child: Text(
            'No pressure data available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // 创建折线图数据点，每分钟一个点
    // 修改数据点创建逻辑，限制为10个点
    List<FlSpot> spots = [];
    // 只取最近10个数据点，如果不足10个则使用全部
    final displayCount = validReports.length > 10 ? 10 : validReports.length;
    final startIndex = validReports.length > 10 ? validReports.length - 10 : 0;

    for (int i = 0; i < displayCount; i++) {
      final reportIndex = startIndex + i;
      final pressureValue = isSystemPressure
          ? validReports[reportIndex].systemStatus!
          : validReports[reportIndex].pilotStatus!;
      // 转换为MPa单位（除以100）
      final pressureMPa = pressureValue / 100.0;
      spots.add(FlSpot(i.toDouble(), pressureMPa));
    }

    // 计算Y轴最大值
    final maxPressureValue =
        spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final yAxisMax = maxPressureValue > 2.0 ? (maxPressureValue * 1.2) : 2.0;

    // 修改图表配置
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: yAxisMax / 6,
                  // 从0到最大值均分6份 horizontalInterval: 0.5, // 每0.5MPa画一条网格线
                  verticalInterval: 1,
                  // 垂直网格线每1分钟一条
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1, // 改为1分钟间隔
                      getTitlesWidget: (double value, TitleMeta meta) {
                        // 只显示1-10的点
                        if (value >= 0 && value <= 9) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${(value + 1).toInt()}', // 显示1-10
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yAxisMax / 6,
                      // 从0到最大值均分6份interval: 0.5, // 每0.5MPa显示一个标签
                      reservedSize: 60,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        // 根据Y轴最大值动态显示刻度
                        final step = yAxisMax / 6;
                        final intervals =
                            List.generate(7, (index) => index * step);
                        for (final interval in intervals) {
                          if ((value - interval).abs() < 0.001 &&
                              interval <= yAxisMax) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Transform.rotate(
                                angle: -math.pi / 2,  // 旋转-90度（-π/2）
                                child: Text(
                                  // System Pressure 显示整数
                                  // Pilot Pressure: 大于等于10显示整数，小于10显示2位小数
                                  isSystemPressure 
                                      ? value.toStringAsFixed(0)
                                      : (value >= 10 
                                          ? value.toStringAsFixed(0)
                                          : value.toStringAsFixed(2)),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: 9,
                // 固定显示10个点（0-9）
                minY: 0,
                maxY: yAxisMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.lightBlue,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.3),
                          Colors.blue.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'X：Minute\nY：MPa',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                'Points: ${displayCount}min',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final validReports = latestReports.where((report) {
      final pressureValue =
          isSystemPressure ? report.systemStatus : report.pilotStatus;
      return pressureValue != null;
    }).toList();

    if (validReports.isEmpty) {
      return SizedBox.shrink();
    }

    final pressureValues = validReports.map((report) {
      final pressureValue =
          isSystemPressure ? report.systemStatus! : report.pilotStatus!;
      return pressureValue / 100.0; // 转换为MPa
    }).toList();

    final maxPressure = pressureValues.reduce((a, b) => a > b ? a : b);
    final minPressure = pressureValues.reduce((a, b) => a < b ? a : b);
    final avgPressure =
        pressureValues.reduce((a, b) => a + b) / pressureValues.length;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'Max', '${maxPressure.toStringAsFixed(2)} MPa', Colors.red),
              _buildStatItem(
                  'Min', '${minPressure.toStringAsFixed(2)} MPa', Colors.blue),
              _buildStatItem(
                  'Avg', '${avgPressure.toStringAsFixed(2)} MPa', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
