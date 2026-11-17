import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:printing/printing.dart';

import 'package:screenshot/screenshot.dart';

class ReportScreen extends StatefulWidget {

  final int days;

  const ReportScreen({

    super.key,

    required this.days,
  });

  @override
  State<ReportScreen> createState() =>
      _ReportScreenState();
}

class _ReportScreenState
    extends State<ReportScreen> {

  bool isLoading = true;

  List summaries = [];

  double avgStability = 0;

  double avgBurnout = 0;

  int happy = 0;
  int stressed = 0;
  int mixed = 0;
  int calm = 0;

  String aiSummary = '';

  String strongestDay = '';
  String weakestDay = '';

  // =========================
  // CHARTS
  // =========================

  List<FlSpot> emotionalSpots = [];

  List<FlSpot> burnoutSpots = [];

  final ScreenshotController
      emotionalChartController =
      ScreenshotController();

  final ScreenshotController
      burnoutChartController =
      ScreenshotController();

  Uint8List? emotionalChartImage;

  Uint8List? burnoutChartImage;

  @override
  void initState() {
    super.initState();

    generateReport();
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

  // =========================
  // GENERATE REPORT
  // =========================

  Future<void> generateReport() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance

            .collection('users')
            .doc(user.uid)
            .collection('daily_summaries')

            .get();

    final now = DateTime.now();

    summaries =
        snapshot.docs.where((doc) {

      final data =
          doc.data();

      final dateString =
          data['date'];

      if (dateString == null) {

        return false;
      }

      try {

        final parts =
            dateString.split('-');

        final entryDate =
            DateTime(

          int.parse(parts[0]),

          int.parse(parts[1]),

          int.parse(parts[2]),
        );

        final difference =
            now
                .difference(
                    entryDate)
                .inDays;

        return difference >= 0 &&
            difference <
                widget.days;

      } catch (e) {

        return false;
      }

    }).toList();

    summaries.sort(

      (a, b) {

        return a['date']
            .compareTo(
                b['date']);
      },
    );

    if (summaries.isEmpty) {

      setState(() {

        isLoading = false;
      });

      return;
    }

    double totalStability = 0;
    double totalBurnout = 0;

    double highest = -1;
    double lowest = 999;

    emotionalSpots.clear();

    burnoutSpots.clear();

    for (int i = 0;
        i < summaries.length;
        i++) {

      final data =
          summaries[i].data();

      final stability =
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
          stability,
        ),
      );

      burnoutSpots.add(

        FlSpot(
          i.toDouble(),
          burnout,
        ),
      );

      totalStability +=
          stability;

      totalBurnout += burnout;

      if (stability > highest) {

        highest = stability;

        strongestDay =
            data['date'];
      }

      if (stability < lowest) {

        lowest = stability;

        weakestDay =
            data['date'];
      }

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

    avgStability =
        totalStability /
            summaries.length;

    avgBurnout =
        totalBurnout /
            summaries.length;

    aiSummary = '''

Over the past ${widget.days} days, your emotional patterns reveal meaningful fluctuations in stability, stress, and productivity.

Your average emotional stability remained at ${avgStability.toStringAsFixed(1)}%, while burnout risk averaged ${avgBurnout.toStringAsFixed(1)}%.

The strongest emotional day occurred on ${formatDate(strongestDay)}, while emotional fatigue appeared strongest around ${formatDate(weakestDay)}.

Your emotional landscape indicates periods of resilience mixed with moments of stress accumulation. Maintaining recovery routines, emotional expression, and balanced workload management may help improve long-term emotional consistency.

''';

    setState(() {

      isLoading = false;
    });

    await captureCharts();
  }

  // =========================
  // CAPTURE CHARTS
  // =========================

  Future<void> captureCharts() async {

    try {

      await Future.delayed(
        const Duration(seconds: 2),
      );

      emotionalChartImage =

          await emotionalChartController
              .capture(
        delay:
            const Duration(milliseconds: 500),
      );

      burnoutChartImage =

          await burnoutChartController
              .capture(
        delay:
            const Duration(milliseconds: 500),
      );

      debugPrint(
          'Charts captured successfully');

    } catch (e) {

      debugPrint(
        'Chart Capture Error: $e',
      );
    }
  }

  // =========================
  // PDF GENERATION
  // =========================

  Future<Uint8List> generatePdf() async {

    final pdf = pw.Document();

    final emotionalImage =

        emotionalChartImage != null

            ? pw.MemoryImage(
                emotionalChartImage!,
              )

            : null;

    final burnoutImage =

        burnoutChartImage != null

            ? pw.MemoryImage(
                burnoutChartImage!,
              )

            : null;

    pdf.addPage(

      pw.MultiPage(

        pageFormat:
            PdfPageFormat.a4,

        build: (context) {

          return [

            // =========================
            // COVER
            // =========================

            pw.Center(

              child: pw.Column(
                children: [

                  pw.SizedBox(
                      height: 40),

                  pw.Text(

                    'MindTrack AI',

                    style: pw.TextStyle(

                      fontSize: 34,

                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(

                    'Emotional Intelligence Report',

                    style: pw.TextStyle(

                      fontSize: 20,
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  pw.Container(

                    padding:
                        const pw.EdgeInsets
                            .all(16),

                    decoration:
                        pw.BoxDecoration(

                      color:
                          PdfColors.deepPurple,
                    ),

                    child: pw.Text(

                      '${widget.days}-Day Analysis',

                      style:
                          const pw.TextStyle(

                        color:
                            PdfColors.white,

                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 40),

            // =========================
            // DASHBOARD
            // =========================

            pw.Text(

              'Emotional Dashboard',

              style: pw.TextStyle(

                fontSize: 24,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Container(

              padding:
                  const pw.EdgeInsets
                      .all(20),

              decoration:
                  pw.BoxDecoration(

                border: pw.Border.all(),

                borderRadius:
                    pw.BorderRadius.circular(
                        14),
              ),

              child: pw.Column(
                children: [

                  buildPdfMetric(
                    'Average Emotional Stability',
                    '${avgStability.toStringAsFixed(1)}%',
                  ),

                  buildPdfMetric(
                    'Average Burnout Risk',
                    '${avgBurnout.toStringAsFixed(1)}%',
                  ),

                  buildPdfMetric(
                    'Strongest Emotional Day',
                    formatDate(
                        strongestDay),
                  ),

                  buildPdfMetric(
                    'Weakest Emotional Day',
                    formatDate(
                        weakestDay),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 40),

            // =========================
            // EMOTIONAL CHART
            // =========================

            pw.Text(

              'Emotional Stability Trend',

              style: pw.TextStyle(

                fontSize: 22,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            if (emotionalImage != null)

              pw.Container(

                height: 240,

                child: pw.Image(
                  emotionalImage,
                  fit: pw.BoxFit.contain,
                ),
              ),

            pw.SizedBox(height: 40),

            // =========================
            // BURNOUT CHART
            // =========================

            pw.Text(

              'Burnout Trend',

              style: pw.TextStyle(

                fontSize: 22,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            if (burnoutImage != null)

              pw.Container(

                height: 240,

                child: pw.Image(
                  burnoutImage,
                  fit: pw.BoxFit.contain,
                ),
              ),

            pw.SizedBox(height: 40),

            // =========================
            // MOOD DISTRIBUTION
            // =========================

            pw.Text(

              'Mood Distribution',

              style: pw.TextStyle(

                fontSize: 22,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            buildPdfMetric(
              'Happy Days',
              '$happy',
            ),

            buildPdfMetric(
              'Stress Days',
              '$stressed',
            ),

            buildPdfMetric(
              'Mixed Days',
              '$mixed',
            ),

            buildPdfMetric(
              'Calm Days',
              '$calm',
            ),

            pw.SizedBox(height: 40),

            // =========================
            // AI REFLECTION
            // =========================

            pw.Text(

              'AI Emotional Reflection',

              style: pw.TextStyle(

                fontSize: 24,

                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text(

              aiSummary,

              style: const pw.TextStyle(

                fontSize: 15,

                lineSpacing: 6,
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // =========================
  // PDF METRIC
  // =========================

  pw.Widget buildPdfMetric(
    String title,
    String value,
  ) {

    return pw.Padding(

      padding:
          const pw.EdgeInsets.only(
              bottom: 14),

      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment
                .spaceBetween,

        children: [

          pw.Text(title),

          pw.Text(

            value,

            style: pw.TextStyle(

              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0F0F1A),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: Text(

          '${widget.days}-Day AI Report',

          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: isLoading

          ? const Center(

              child:
                  CircularProgressIndicator(
                color:
                    Colors.deepPurpleAccent,
              ),
            )

          : summaries.isEmpty

              ? const Center(

                  child: Text(

                    'No report data found.',

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )

              : SingleChildScrollView(

                  padding:
                      const EdgeInsets
                          .all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      // =========================
                      // HEADER
                      // =========================

                      Container(

                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .all(24),

                        decoration:
                            BoxDecoration(

                          gradient:
                              const LinearGradient(

                            colors: [

                              Colors
                                  .deepPurpleAccent,

                              Colors.purple,
                            ],
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      28),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(

                              '${widget.days}-Day Emotional Report',

                              style:
                                  const TextStyle(

                                color:
                                    Colors.white,

                                fontSize: 30,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            Text(

                              'AI-powered emotional intelligence analysis.',

                              style:
                                  TextStyle(

                                color: Colors
                                    .white
                                    .withOpacity(
                                        0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =========================
                      // METRICS
                      // =========================

                      buildMetricCard(),

                      const SizedBox(height: 30),

                      // =========================
                      // EMOTIONAL CHART
                      // =========================

                      buildChartCard(

                        title:
                            'Emotional Stability',

                        child: Screenshot(

                          controller:
                              emotionalChartController,

                          child: Container(

                            color:
                                const Color(
                                    0xFF121212),

                            height: 260,

                            padding:
                                const EdgeInsets
                                    .all(20),

                            child: LineChart(

                              LineChartData(

                                minY: 0,
                                maxY: 100,

                                borderData:
                                    FlBorderData(
                                        show:
                                            false),

                                titlesData:
                                    FlTitlesData(
                                        show:
                                            false),

                                gridData:
                                    FlGridData(
                                        show:
                                            true),

                                lineBarsData: [

                                  LineChartBarData(

                                    spots:
                                        emotionalSpots,

                                    isCurved:
                                        true,

                                    color:
                                        Colors
                                            .greenAccent,

                                    barWidth:
                                        5,

                                    dotData:
                                        FlDotData(
                                      show:
                                          true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =========================
                      // BURNOUT CHART
                      // =========================

                      buildChartCard(

                        title:
                            'Burnout Trend',

                        child: Screenshot(

                          controller:
                              burnoutChartController,

                          child: Container(

                            color:
                                const Color(
                                    0xFF121212),

                            height: 260,

                            padding:
                                const EdgeInsets
                                    .all(20),

                            child: LineChart(

                              LineChartData(

                                minY: 0,
                                maxY: 100,

                                borderData:
                                    FlBorderData(
                                        show:
                                            false),

                                titlesData:
                                    FlTitlesData(
                                        show:
                                            false),

                                gridData:
                                    FlGridData(
                                        show:
                                            true),

                                lineBarsData: [

                                  LineChartBarData(

                                    spots:
                                        burnoutSpots,

                                    isCurved:
                                        true,

                                    color:
                                        Colors
                                            .redAccent,

                                    barWidth:
                                        5,

                                    dotData:
                                        FlDotData(
                                      show:
                                          true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =========================
                      // AI REFLECTION
                      // =========================

                      Container(

                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .all(24),

                        decoration:
                            BoxDecoration(

                          color: Colors
                              .white
                              .withOpacity(
                                  0.05),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      28),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const Row(
                              children: [

                                Icon(
                                  Icons.auto_awesome,

                                  color: Colors
                                      .deepPurpleAccent,
                                ),

                                SizedBox(
                                    width: 10),

                                Text(

                                  'AI Emotional Reflection',

                                  style:
                                      TextStyle(

                                    color: Colors
                                        .white,

                                    fontSize:
                                        22,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 20),

                            Text(

                              aiSummary,

                              style:
                                  TextStyle(

                                color: Colors
                                    .white
                                    .withOpacity(
                                        0.82),

                                height: 1.8,

                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // =========================
                      // DOWNLOAD BUTTON
                      // =========================

                      SizedBox(

                        width:
                            double.infinity,

                        height: 60,

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
                                          20),
                            ),
                          ),

                          onPressed: () async {

                            await captureCharts();

                            final pdfData =
                                await generatePdf();

                            await Printing
                                .layoutPdf(

                              onLayout:
                                  (format) async =>
                                      pdfData,
                            );
                          },

                          icon: const Icon(
                            Icons.download,
                          ),

                          label: const Text(

                            'Download Premium PDF Report',

                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  // =========================
  // METRIC CARD
  // =========================

  Widget buildMetricCard() {

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(28),
      ),

      child: Column(
        children: [

          buildMetric(
            'Average Emotional Stability',
            '${avgStability.toStringAsFixed(1)}%',
          ),

          buildMetric(
            'Average Burnout Risk',
            '${avgBurnout.toStringAsFixed(1)}%',
          ),

          buildMetric(
            'Strongest Emotional Day',
            formatDate(strongestDay),
          ),

          buildMetric(
            'Weakest Emotional Day',
            formatDate(weakestDay),
          ),
        ],
      ),
    );
  }

  // =========================
  // CHART CARD
  // =========================

  Widget buildChartCard({

    required String title,

    required Widget child,
  }) {

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            Colors.white.withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(28),
      ),

      child: Column(
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

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  // =========================
  // METRIC TILE
  // =========================

  Widget buildMetric(

    String title,

    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
              bottom: 18),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [

          Text(

            title,

            style: TextStyle(

              color: Colors.white
                  .withOpacity(0.7),

              fontSize: 16,
            ),
          ),

          Text(

            value,

            style: const TextStyle(

              color: Colors.white,

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}