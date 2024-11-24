import 'package:docfiy/db/models/statistic.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Map<String, int> groupStatisticsByDay(List<Statistic> statistics) {
  Map<String, int> data = {};

  for (var stat in statistics) {
    var day = DateFormat("yyyy-MM-dd").format(DateTime.parse(stat.startAt));

    if (data.containsKey(day)) {
      data[day] = data[day]! + 1;
    } else {
      data[day] = 1;
    }
  }
  return data;
}

class BarStatistic extends StatelessWidget {
  final Map<String, int> data;

  const BarStatistic({required this.data});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    List<String> dates = data.keys.toList();

    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[dates[i]]!.toDouble()));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
        barGroups: dates.asMap().entries.map((ent) {
          int index = ent.key;
          String day = ent.value;
          int count = data[day]!;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: Colors.blue,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return SideTitleWidget(
                      child: Text(dates[index]),
                      axisSide: meta.axisSide); // Показываем дни на оси X
                }
                return SideTitleWidget(
                    child: Text(""), axisSide: meta.axisSide);
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
      ),
    );
  }
}