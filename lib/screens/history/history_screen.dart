import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../reports/report_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState
    extends State<HistoryScreen> {

  int selectedDays = 7;

  // =========================
  // PRODUCTIVITY SCORE
  // =========================

  int productivityToNumber(
      String value) {

    value =
        value.toLowerCase();

    if (value.contains('high')) {
      return 90;
    }

    if (value.contains('medium')) {
      return 60;
    }

    if (value.contains('low')) {
      return 30;
    }

    return 50;
  }

  // =========================
  // STRESS SCORE
  // =========================

  int stressToNumber(
      String value) {

    value =
        value.toLowerCase();

    if (value.contains('high')) {
      return 90;
    }

    if (value.contains('medium')) {
      return 60;
    }

    if (value.contains('low')) {
      return 30;
    }

    return 50;
  }

  // =========================
  // FORMAT DATE
  // =========================

  String formatDate(
      String? dayId) {

    if (dayId == null ||
        dayId.isEmpty) {

      return '';
    }

    try {

      final parts =
          dayId.split('-');

      final date = DateTime(

        int.parse(parts[0]),

        int.parse(parts[1]),

        int.parse(parts[2]),
      );

      return DateFormat(
        'dd MMM yyyy',
      ).format(date);

    } catch (e) {

      return dayId;
    }
  }

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(

      backgroundColor:
          const Color(0xFF0F0F1A),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(
          'Emotional Analytics',

          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder(

        stream: FirebaseFirestore.instance

            .collection('users')
            .doc(user!.uid)
            .collection('daily_summaries')

            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(

              child:
                  CircularProgressIndicator(
                color:
                    Colors.deepPurpleAccent,
              ),
            );
          }

          List summaries =
              snapshot.data!.docs;

          if (summaries.isEmpty) {

            return const Center(

              child: Text(
                'No analytics yet.',

                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            );
          }

          // =========================
          // SORT BY REAL DATE
          // =========================

          summaries.sort(

            (a, b) {

              final dateA =
                  a['date']
                      .toString();

              final dateB =
                  b['date']
                      .toString();

              return dateA.compareTo(
                  dateB);
            },
          );

          // =========================
          // FILTER BY REAL DAYS
          // =========================

          final now = DateTime.now();

          summaries =
              summaries.where((doc) {

            final data =
                doc.data()
                    as Map<String,
                        dynamic>;

            final dateString =
                data['date'];

            if (dateString ==
                null) {

              return false;
            }

            try {

              final parts =
                  dateString
                      .split('-');

              final entryDate =
                  DateTime(

                int.parse(parts[0]),

                int.parse(parts[1]),

                int.parse(parts[2]),
              );

              final normalizedNow =
                  DateTime(

                now.year,
                now.month,
                now.day,
              );

              final normalizedEntry =
                  DateTime(

                entryDate.year,
                entryDate.month,
                entryDate.day,
              );

              final difference =
                  normalizedNow
                      .difference(
                          normalizedEntry)
                      .inDays;

              return difference >= 0 &&
                  difference <
                      selectedDays;

            } catch (e) {

              return false;
            }

          }).toList();

          // RE-SORT AFTER FILTER

          summaries.sort(

            (a, b) {

              final dateA =
                  a['date']
                      .toString();

              final dateB =
                  b['date']
                      .toString();

              return dateA.compareTo(
                  dateB);
            },
          );

          // =========================
          // CHART DATA
          // =========================

          List<FlSpot> emotionalSpots =
              [];

          List<FlSpot> burnoutSpots =
              [];

          List<BarChartGroupData>
              productivityBars = [];

          List<BarChartGroupData>
              stressBars = [];

          int happy = 0;
          int stressed = 0;
          int mixed = 0;
          int calm = 0;

          for (int i = 0;
              i < summaries.length;
              i++) {

            final data =
                summaries[i].data();

            final emotional =
                double.tryParse(
                      data[
                              'emotionalStability']
                          .toString(),
                    ) ??
                    0;

            final burnout =
                double.tryParse(
                      data['burnoutRisk']
                          .toString(),
                    ) ??
                    0;

            emotionalSpots.add(

              FlSpot(
                i.toDouble(),
                emotional,
              ),
            );

            burnoutSpots.add(

              FlSpot(
                i.toDouble(),
                burnout,
              ),
            );

            final productivity =
                productivityToNumber(

              data['productivity']
                      ?.toString() ??
                  '',
            );

            final stress =
                stressToNumber(

              data['stressLevel']
                      ?.toString() ??
                  '',
            );

            productivityBars.add(

              BarChartGroupData(
                x: i,

                barRods: [

                  BarChartRodData(
                    toY:
                        productivity.toDouble(),

                    width: 16,

                    color:
                        Colors.greenAccent,

                    borderRadius:
                        BorderRadius.circular(
                            6),
                  ),
                ],
              ),
            );

            stressBars.add(

              BarChartGroupData(
                x: i,

                barRods: [

                  BarChartRodData(
                    toY:
                        stress.toDouble(),

                    width: 16,

                    color:
                        Colors.orangeAccent,

                    borderRadius:
                        BorderRadius.circular(
                            6),
                  ),
                ],
              ),
            );

            final mood =
                data['mood']
                    .toString()
                    .toLowerCase();

            if (mood.contains('happy')) {

              happy++;

            } else if (

                mood.contains('stress') ||
                mood.contains('sad') ||
                mood.contains('burnout')) {

              stressed++;

            } else if (

                mood.contains('mixed') ||
                mood.contains('conflicted')) {

              mixed++;

            } else {

              calm++;
            }
          }

          return SingleChildScrollView(

            padding:
                const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                // =========================
                // REPORT BUTTONS
                // =========================

                Container(

                  padding:
                      const EdgeInsets.all(
                          20),

                  decoration: BoxDecoration(

                    color:
                        Colors.white
                            .withOpacity(
                                0.05),

                    borderRadius:
                        BorderRadius.circular(
                            24),
                  ),

                  child: Column(
                    children: [

                      SizedBox(

                        width:
                            double.infinity,

                        height: 56,

                        child:
                            ElevatedButton.icon(

                          style:
                              ElevatedButton
                                  .styleFrom(

                            backgroundColor:
                                Colors
                                    .deepPurpleAccent,

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          18),
                            ),
                          ),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const ReportScreen(
                                  days: 7,
                                ),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.description,
                          ),

                          label: const Text(
                            'Generate 7-Day AI Report',
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 16),

                      SizedBox(

                        width:
                            double.infinity,

                        height: 56,

                        child:
                            ElevatedButton.icon(

                          style:
                              ElevatedButton
                                  .styleFrom(

                            backgroundColor:
                                Colors
                                    .deepPurpleAccent,

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          18),
                            ),
                          ),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const ReportScreen(
                                  days: 30,
                                ),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.auto_graph,
                          ),

                          label: const Text(
                            'Generate 30-Day AI Report',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // FILTER BUTTONS

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    buildFilterButton(7),

                    buildFilterButton(30),

                    buildFilterButton(60),

                    buildFilterButton(90),
                  ],
                ),

                const SizedBox(height: 35),

                // EMOTIONAL STABILITY

                buildTitle(
                  'Emotional Stability',
                  'Overall emotional balance.',
                ),

                const SizedBox(height: 18),

                buildLineChart(

                  emotionalSpots,

                  summaries,

                  Colors.greenAccent,

                  'Stability',
                ),

                const SizedBox(height: 35),

                // BURNOUT

                buildTitle(
                  'Burnout Trend',
                  'Emotional exhaustion over time.',
                ),

                const SizedBox(height: 18),

                buildLineChart(

                  burnoutSpots,

                  summaries,

                  Colors.redAccent,

                  'Burnout',
                ),

                const SizedBox(height: 35),

                // PRODUCTIVITY

                buildTitle(
                  'Productivity Levels',
                  'Daily productivity intensity.',
                ),

                const SizedBox(height: 18),

                buildBarChart(

                  productivityBars,

                  summaries,

                  Colors.greenAccent,

                  'Productivity',
                ),

                const SizedBox(height: 35),

                // STRESS

                buildTitle(
                  'Stress Levels',
                  'Daily stress fluctuations.',
                ),

                const SizedBox(height: 18),

                buildBarChart(

                  stressBars,

                  summaries,

                  Colors.orangeAccent,

                  'Stress',
                ),

                const SizedBox(height: 35),

                // PIE CHART

                buildTitle(
                  'Mood Distribution',
                  'Overall emotional patterns.',
                ),

                const SizedBox(height: 18),

                buildPieChart(
                  happy,
                  stressed,
                  mixed,
                  calm,
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================
  // FILTER BUTTON
  // =========================

  Widget buildFilterButton(
      int days) {

    final selected =
        selectedDays == days;

    return GestureDetector(

      onTap: () {

        setState(() {

          selectedDays = days;
        });
      },

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: selected

              ? Colors.deepPurpleAccent

              : Colors.white
                  .withOpacity(0.05),

          borderRadius:
              BorderRadius.circular(
                  16),
        ),

        child: Text(
          '${days}D',

          style: TextStyle(

            color: Colors.white,

            fontWeight: selected

                ? FontWeight.bold

                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // =========================
  // TITLES
  // =========================

  Widget buildTitle(
    String title,
    String subtitle,
  ) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          subtitle,

          style: TextStyle(
            color: Colors.white
                .withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // =========================
  // LINE CHART
  // =========================

  Widget buildLineChart(

    List<FlSpot> spots,

    List summaries,

    Color color,

    String label,
  ) {

    return Container(

      height: 280,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(28),
      ),

      child: LineChart(

        LineChartData(

          minY: 0,
          maxY: 100,

          borderData:
              FlBorderData(show: false),

          titlesData:
              FlTitlesData(show: false),

          lineTouchData:
              LineTouchData(

            touchTooltipData:
                LineTouchTooltipData(

              getTooltipItems:
                  (touchedSpots) {

                return touchedSpots.map(

                  (spot) {

                    final data =
                        summaries[
                                spot.x
                                    .toInt()]
                            .data();

                    return LineTooltipItem(

                      '${formatDate(data['date'])}\n$label: ${spot.y.toInt()}%',

                      const TextStyle(
                        color:
                            Colors.white,
                      ),
                    );
                  },
                ).toList();
              },
            ),
          ),

          gridData: FlGridData(

            show: true,

            drawVerticalLine: false,

            getDrawingHorizontalLine:
                (value) {

              return FlLine(

                color: Colors.white
                    .withOpacity(0.08),
              );
            },
          ),

          lineBarsData: [

            LineChartBarData(

              spots: spots,

              isCurved: true,

              color: color,

              barWidth: 5,

              dotData:
                  FlDotData(show: true),

              belowBarData:
                  BarAreaData(

                show: true,

                gradient:
                    LinearGradient(

                  colors: [

                    color.withOpacity(0.35),

                    color.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // BAR CHART
  // =========================

  Widget buildBarChart(

    List<BarChartGroupData> bars,

    List summaries,

    Color color,

    String label,
  ) {

    return Container(

      height: 280,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(28),
      ),

      child: BarChart(

        BarChartData(

          maxY: 100,

          borderData:
              FlBorderData(show: false),

          titlesData:
              FlTitlesData(show: false),

          barTouchData:
              BarTouchData(

            touchTooltipData:
                BarTouchTooltipData(

              getTooltipItem:

                  (group,
                      groupIndex,
                      rod,
                      rodIndex) {

                final data =
                    summaries[
                            group.x]
                        .data();

                return BarTooltipItem(

                  '${formatDate(data['date'])}\n$label: ${rod.toY.toInt()}%',

                  const TextStyle(
                    color:
                        Colors.white,
                  ),
                );
              },
            ),
          ),

          gridData: FlGridData(

            show: true,

            drawVerticalLine: false,

            getDrawingHorizontalLine:
                (value) {

              return FlLine(

                color: Colors.white
                    .withOpacity(0.08),
              );
            },
          ),

          barGroups: bars,
        ),
      ),
    );
  }

  // =========================
  // PIE CHART
  // =========================

  Widget buildPieChart(
    int happy,
    int stressed,
    int mixed,
    int calm,
  ) {

    return Container(

      height: 320,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(28),
      ),

      child: PieChart(

        PieChartData(

          sectionsSpace: 4,

          centerSpaceRadius: 55,

          pieTouchData:
              PieTouchData(
            enabled: true,
          ),

          sections: [

            PieChartSectionData(

              value:
                  happy.toDouble(),

              color: Colors.green,

              title: 'Happy',

              radius: 70,

              titleStyle:
                  const TextStyle(
                color: Colors.white,
              ),
            ),

            PieChartSectionData(

              value:
                  stressed.toDouble(),

              color: Colors.redAccent,

              title: 'Stress',

              radius: 70,

              titleStyle:
                  const TextStyle(
                color: Colors.white,
              ),
            ),

            PieChartSectionData(

              value:
                  mixed.toDouble(),

              color:
                  Colors.deepPurpleAccent,

              title: 'Mixed',

              radius: 70,

              titleStyle:
                  const TextStyle(
                color: Colors.white,
              ),
            ),

            PieChartSectionData(

              value:
                  calm.toDouble(),

              color: Colors.lightGreen,

              title: 'Calm',

              radius: 70,

              titleStyle:
                  const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}