import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'day_detail_screen.dart';

class CalendarScreen extends StatefulWidget {

  const CalendarScreen({
    super.key,
  });

  @override
  State<CalendarScreen> createState() =>
      _CalendarScreenState();
}

class _CalendarScreenState
    extends State<CalendarScreen> {

  DateTime focusedDay =
      DateTime.now();

  DateTime selectedDay =
      DateTime.now();

  Map<String, dynamic>
      summaries = {};

  // =========================
  // MOOD COLORS
  // =========================

  Color getMoodColor(
      String mood) {

    final lower =
        mood.toLowerCase();

    if (lower.contains('happy') ||
        lower.contains(
            'focused') ||
        lower.contains(
            'motivated')) {

      return Colors.green;
    }

    if (lower.contains('calm') ||
        lower.contains(
            'peaceful')) {

      return Colors.lightGreen;
    }

    if (lower.contains('mixed') ||
        lower.contains(
            'conflicted')) {

      return Colors
          .deepPurpleAccent;
    }

    if (lower.contains(
        'neutral')) {

      return Colors.yellow;
    }

    if (lower.contains(
            'anxious') ||
        lower.contains(
            'overwhelmed')) {

      return Colors.orange;
    }

    if (lower.contains(
            'stress') ||
        lower.contains('sad') ||
        lower.contains(
            'burnout') ||
        lower.contains(
            'drained') ||
        lower.contains(
            'grieving')) {

      return Colors.redAccent;
    }

    return Colors.grey;
  }

  // =========================
  // FORMAT DATE
  // =========================

  String formatDay(
      DateTime day) {

    return
        '${day.year}-${day.month}-${day.day}';
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
              0xFF0F0F1A),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(

          'Emotional Calendar',

          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder(

        stream:
            FirebaseFirestore
                .instance

                .collection(
                    'users')

                .doc(
                  FirebaseAuth
                      .instance
                      .currentUser!
                      .uid,
                )

                .collection(
                    'daily_summaries')

                .snapshots(),

        builder:
            (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(

              child:
                  CircularProgressIndicator(
                color: Colors
                    .deepPurpleAccent,
              ),
            );
          }

          summaries.clear();

          for (var doc
              in snapshot.data!.docs) {

            summaries[doc.id] =
                doc.data();
          }

          return SingleChildScrollView(

            padding:
                const EdgeInsets
                    .all(16),

            child: Column(

              children: [

                // =========================
                // CALENDAR
                // =========================

                Container(

                  padding:
                      const EdgeInsets
                          .all(12),

                  decoration:
                      BoxDecoration(

                    color: Colors.white
                        .withOpacity(
                            0.05),

                    borderRadius:
                        BorderRadius
                            .circular(
                                28),
                  ),

                  child:
                      TableCalendar(

                    firstDay:
                        DateTime.utc(
                            2020),

                    lastDay:
                        DateTime.utc(
                            2035),

                    focusedDay:
                        focusedDay,

                    selectedDayPredicate:
                        (day) {

                      return isSameDay(
                        selectedDay,
                        day,
                      );
                    },

                    calendarStyle:
                        CalendarStyle(

                      outsideDaysVisible:
                          false,

                      defaultTextStyle:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),

                      weekendTextStyle:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),

                      todayDecoration:
                          BoxDecoration(

                        color: Colors
                            .deepPurpleAccent,

                        shape:
                            BoxShape.circle,
                      ),

                      selectedDecoration:
                          const BoxDecoration(

                        color:
                            Colors.white,

                        shape:
                            BoxShape.circle,
                      ),

                      selectedTextStyle:
                          const TextStyle(
                        color:
                            Colors.black,
                      ),
                    ),

                    headerStyle:
                        const HeaderStyle(

                      titleCentered:
                          true,

                      titleTextStyle:
                          TextStyle(

                        color:
                            Colors.white,

                        fontSize:
                            20,

                        fontWeight:
                            FontWeight.bold,
                      ),

                      formatButtonVisible:
                          false,

                      leftChevronIcon:
                          Icon(

                        Icons
                            .chevron_left,

                        color:
                            Colors.white,
                      ),

                      rightChevronIcon:
                          Icon(

                        Icons
                            .chevron_right,

                        color:
                            Colors.white,
                      ),
                    ),

                    daysOfWeekStyle:
                        DaysOfWeekStyle(

                      weekdayStyle:
                          TextStyle(

                        color: Colors
                            .white
                            .withOpacity(
                                0.55),
                      ),

                      weekendStyle:
                          TextStyle(

                        color: Colors
                            .white
                            .withOpacity(
                                0.55),
                      ),
                    ),

                    calendarBuilders:
                        CalendarBuilders(

                      defaultBuilder:

                          (
                        context,

                        day,

                        focusedDay,
                      ) {

                        final key =
                            formatDay(
                                day);

                        if (summaries
                            .containsKey(
                                key)) {

                          final mood =
                              summaries[
                                          key]
                                      [
                                      'mood'] ??
                                  '';

                          return AnimatedContainer(

                            duration:
                                const Duration(
                                    milliseconds:
                                        300),

                            margin:
                                const EdgeInsets
                                    .all(6),

                            decoration:
                                BoxDecoration(

                              color:
                                  getMoodColor(
                                      mood),

                              shape:
                                  BoxShape
                                      .circle,

                              boxShadow: [

                                BoxShadow(

                                  color:
                                      getMoodColor(
                                              mood)
                                          .withOpacity(
                                              0.4),

                                  blurRadius:
                                      8,

                                  spreadRadius:
                                      1,
                                ),
                              ],
                            ),

                            child:
                                Center(

                              child: Text(

                                '${day.day}',

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }

                        return Center(

                          child: Text(

                            '${day.day}',

                            style:
                                TextStyle(

                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.85),
                            ),
                          ),
                        );
                      },
                    ),

                    // =========================
                    // DAY SELECT
                    // =========================

                    onDaySelected:

                        (
                      selected,

                      focused,
                    ) {

                      setState(() {

                        selectedDay =
                            selected;

                        focusedDay =
                            focused;
                      });

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>

                              DayDetailScreen(

                            selectedDate:
                                selected,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}