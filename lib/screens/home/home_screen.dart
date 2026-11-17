import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../widgets/ai_assistant_widget.dart';

import '../history/history_screen.dart';
import '../calendar/calendar_screen.dart';
import '../journal/journal_screen.dart';

import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController
      _controller;

  late Animation<double>
      _fadeAnimation;

  String latestMood =
      'Loading...';

  String latestInsight = '';

  String latestProductivity =
      '';

  String emotionalStability =
      '70';

  bool isLoading = true;

  int streakDays = 0;

  @override
  void initState() {

    super.initState();

    _controller =
        AnimationController(

      vsync: this,

      duration:
          const Duration(
              milliseconds: 1200),
    );

    _fadeAnimation =
        CurvedAnimation(

      parent: _controller,

      curve: Curves.easeIn,
    );

    _controller.forward();

    fetchLatestSummary();

    calculateStreak();
  }

  // =========================
  // FETCH SUMMARY
  // =========================

  Future<void>
      fetchLatestSummary() async {

    try {

      final user =
          FirebaseAuth
              .instance
              .currentUser;

      if (user == null) return;

      final snapshot =
          await FirebaseFirestore
              .instance

              .collection('users')
              .doc(user.uid)

              .collection(
                  'daily_summaries')

              .orderBy(
                'updatedAt',
                descending: true,
              )

              .limit(1)

              .get();

      if (snapshot.docs.isNotEmpty) {

        final data =
            snapshot.docs
                .first
                .data();

        setState(() {

          latestMood =
              data['mood'] ?? '';

          latestInsight =
              data['insight'] ??
                  '';

          latestProductivity =
              data['productivity'] ??
                  '';

          emotionalStability =
              data[
                          'emotionalStability']
                      ?.toString() ??
                  '70';

          isLoading = false;
        });

      } else {

        setState(() {

          isLoading = false;
        });
      }

    } catch (e) {

      setState(() {

        isLoading = false;
      });
    }
  }

  // =========================
  // STREAK
  // =========================

  Future<void>
      calculateStreak() async {

    try {

      final user =
          FirebaseAuth
              .instance
              .currentUser;

      if (user == null) return;

      final snapshot =
          await FirebaseFirestore
              .instance

              .collection('users')
              .doc(user.uid)

              .collection(
                  'daily_summaries')

              .get();

      streakDays =
          snapshot.docs.length;

      setState(() {});

    } catch (e) {

      debugPrint(
          'Streak Error: $e');
    }
  }

  // =========================
  // MOOD COLOR
  // =========================

  Color getMoodColor() {

    final mood =
        latestMood.toLowerCase();

    if (mood.contains('sad') ||
        mood.contains(
            'stress') ||
        mood.contains(
            'burnout')) {

      return Colors.redAccent;
    }

    if (mood.contains(
        'anxious')) {

      return Colors.orange;
    }

    if (mood.contains(
        'neutral')) {

      return Colors.yellow;
    }

    if (mood.contains(
        'calm')) {

      return Colors.lightGreen;
    }

    if (mood.contains('happy') ||
        mood.contains(
            'focused')) {

      return Colors.greenAccent;
    }

    return Colors
        .deepPurpleAccent;
  }

  // =========================
  // EMOJI
  // =========================

  String getMoodEmoji() {

    final mood =
        latestMood.toLowerCase();

    if (mood.contains('sad')) {
      return '😔';
    }

    if (mood.contains(
        'stress')) {
      return '😫';
    }

    if (mood.contains(
        'burnout')) {
      return '🥵';
    }

    if (mood.contains(
        'anxious')) {
      return '😟';
    }

    if (mood.contains(
        'neutral')) {
      return '😐';
    }

    if (mood.contains(
        'calm')) {
      return '🙂';
    }

    if (mood.contains(
        'happy')) {
      return '😄';
    }

    if (mood.contains(
        'focused')) {
      return '🧠';
    }

    return '✨';
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {

    return Stack(

      children: [

        Scaffold(

          backgroundColor:
              const Color(
                  0xFF0F0F1A),

          body: SafeArea(

            child: FadeTransition(

              opacity:
                  _fadeAnimation,

              child: isLoading

                  ? const Center(

                      child:
                          CircularProgressIndicator(
                        color: Colors
                            .deepPurpleAccent,
                      ),
                    )

                  : Padding(

                      padding:
                          const EdgeInsets
                              .all(20),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          // HEADER

                          Row(

                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children: [

                              Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(

                                    'Welcome Back 👋',

                                    style:
                                        TextStyle(

                                      color: Colors
                                          .white
                                          .withOpacity(
                                              0.7),

                                      fontSize:
                                          16,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          4),

                                  const Text(

                                    'MindTrack AI',

                                    style:
                                        TextStyle(

                                      color: Colors
                                          .white,

                                      fontSize:
                                          30,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              ),

                              Row(

                                children: [

                                  GestureDetector(

                                    onTap:
                                        () {

                                      Navigator.push(

                                        context,

                                        MaterialPageRoute(

                                          builder: (_) =>
                                              const ProfileScreen(),
                                        ),
                                      );
                                    },

                                    child:
                                        CircleAvatar(

                                      radius:
                                          22,

                                      backgroundColor:
                                          Colors.white
                                              .withOpacity(
                                                  0.08),

                                      child:
                                          const Icon(

                                        Icons.person,

                                        color: Colors
                                            .deepPurpleAccent,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      width:
                                          12),

                                  GestureDetector(

                                    onTap:
                                        () async {

                                      await FirebaseAuth
                                          .instance
                                          .signOut();

                                      Navigator.pushReplacement(

                                        context,

                                        MaterialPageRoute(

                                          builder: (_) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },

                                    child:
                                        CircleAvatar(

                                      radius:
                                          22,

                                      backgroundColor:
                                          Colors
                                              .white
                                              .withOpacity(
                                                  0.08),

                                      child:
                                          const Icon(

                                        Icons.logout,

                                        color: Colors
                                            .redAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 30),

                          // MOOD CARD

                          buildGlassCard(

                            height: 180,

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Row(

                                  children: [

                                    const Text(

                                      'Today’s Overall Mood',

                                      style:
                                          TextStyle(

                                        color:
                                            Colors.white,

                                        fontSize:
                                            18,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const Spacer(),

                                    Flexible(

                                      child:
                                          Container(

                                        padding:
                                            const EdgeInsets.symmetric(

                                          horizontal:
                                              14,

                                          vertical:
                                              8,
                                        ),

                                        decoration:
                                            BoxDecoration(

                                          color:
                                              getMoodColor(),

                                          borderRadius:
                                              BorderRadius.circular(
                                                  16),
                                        ),

                                        child:
                                            Text(

                                          '${getMoodEmoji()} $latestMood',

                                          maxLines:
                                              1,

                                          overflow:
                                              TextOverflow.ellipsis,

                                          style:
                                              const TextStyle(

                                            color:
                                                Colors.white,

                                            fontSize:
                                                13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height:
                                        24),

                                Stack(

                                  children: [

                                    Container(

                                      height:
                                          12,

                                      decoration:
                                          BoxDecoration(

                                        color: Colors
                                            .white
                                            .withOpacity(
                                                0.08),

                                        borderRadius:
                                            BorderRadius.circular(
                                                20),
                                      ),
                                    ),

                                    FractionallySizedBox(

                                      widthFactor:

                                          (double.tryParse(
                                                          emotionalStability) ??
                                                      70) /
                                                  100,

                                      child:
                                          Container(

                                        height:
                                            12,

                                        decoration:
                                            BoxDecoration(

                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),

                                          gradient:
                                              const LinearGradient(

                                            colors: [

                                              Colors.red,

                                              Colors.orange,

                                              Colors.yellow,

                                              Colors.lightGreen,

                                              Colors.green,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height:
                                        12),

                                Text(

                                  'Daily Emotional Stability $emotionalStability%',

                                  style:
                                      TextStyle(

                                    color: Colors
                                        .white
                                        .withOpacity(
                                            0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              height: 22),

                          Row(

                            children: [

                              Expanded(

                                child:
                                    buildSmallCard(

                                  title:
                                      'Days Tracked',

                                  value:
                                      '$streakDays',

                                  icon: Icons
                                      .local_fire_department,
                                ),
                              ),

                              const SizedBox(
                                  width:
                                      16),

                              Expanded(

                                child:
                                    buildSmallCard(

                                  title:
                                      'Productivity',

                                  value:
                                      latestProductivity,

                                  icon:
                                      Icons.psychology,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 22),

                          Expanded(

                            child:
                                buildGlassCard(

                              height:
                                  double.infinity,

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  const Row(

                                    children: [

                                      Icon(

                                        Icons.auto_awesome,

                                        color:
                                            Colors.deepPurpleAccent,
                                      ),

                                      SizedBox(
                                          width:
                                              10),

                                      Text(

                                        'Daily AI Insight',

                                        style:
                                            TextStyle(

                                          color:
                                              Colors.white,

                                          fontSize:
                                              18,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                      height:
                                          18),

                                  Expanded(

                                    child:
                                        SingleChildScrollView(

                                      child:
                                          Text(

                                        latestInsight,

                                        style:
                                            TextStyle(

                                          color:
                                              Colors.white.withOpacity(
                                                  0.75),

                                          height:
                                              1.7,

                                          fontSize:
                                              15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 24),

                          SizedBox(

                            width:
                                double.infinity,

                            height: 58,

                            child:
                                ElevatedButton(

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.deepPurpleAccent,

                                shape:
                                    RoundedRectangleBorder(

                                  borderRadius:
                                      BorderRadius.circular(
                                          20),
                                ),
                              ),

                              onPressed:
                                  () async {

                                await Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) =>
                                        const JournalScreen(),
                                  ),
                                );

                                fetchLatestSummary();

                                calculateStreak();
                              },

                              child:
                                  const Text(

                                'Write Journal',

                                style:
                                    TextStyle(

                                  fontSize:
                                      17,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // BOTTOM NAV

          bottomNavigationBar:
              Container(

            height: 80,

            decoration:
                BoxDecoration(

              color:
                  const Color(
                      0xFF1A1A2E),

              border: Border(

                top: BorderSide(

                  color: Colors
                      .white
                      .withOpacity(
                          0.05),
                ),
              ),
            ),

            child: Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,

              children: [

                buildNavItem(
                  Icons.home,
                  true,
                ),

                GestureDetector(

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const HistoryScreen(),
                      ),
                    );
                  },

                  child:
                      buildNavItem(

                    Icons.bar_chart,
                    false,
                  ),
                ),

                GestureDetector(

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const CalendarScreen(),
                      ),
                    );
                  },

                  child:
                      buildNavItem(

                    Icons.calendar_month,
                    false,
                  ),
                ),
              ],
            ),
          ),
        ),

        // AI ASSISTANT

        const AIAssistantWidget(),
      ],
    );
  }

  // =========================
  // GLASS CARD
  // =========================

  Widget buildGlassCard({

    required Widget child,

    required double height,
  }) {

    return GlassmorphicContainer(

      width: double.infinity,

      height: height,

      borderRadius: 28,

      blur: 20,

      alignment:
          Alignment.center,

      border: 1.5,

      linearGradient:
          LinearGradient(

        colors: [

          Colors.white
              .withOpacity(
                  0.10),

          Colors.white
              .withOpacity(
                  0.05),
        ],
      ),

      borderGradient:
          LinearGradient(

        colors: [

          Colors.white
              .withOpacity(
                  0.5),

          Colors.white
              .withOpacity(
                  0.1),
        ],
      ),

      child: Padding(

        padding:
            const EdgeInsets
                .all(22),

        child: child,
      ),
    );
  }

  // =========================
  // SMALL CARD
  // =========================

  Widget buildSmallCard({

    required String title,

    required String value,

    required IconData icon,
  }) {

    return GlassmorphicContainer(

      width: double.infinity,

      height: 140,

      borderRadius: 24,

      blur: 20,

      alignment:
          Alignment.center,

      border: 1.5,

      linearGradient:
          LinearGradient(

        colors: [

          Colors.white
              .withOpacity(
                  0.10),

          Colors.white
              .withOpacity(
                  0.05),
        ],
      ),

      borderGradient:
          LinearGradient(

        colors: [

          Colors.white
              .withOpacity(
                  0.5),

          Colors.white
              .withOpacity(
                  0.1),
        ],
      ),

      child: Padding(

        padding:
            const EdgeInsets
                .all(18),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            Icon(

              icon,

              color: Colors
                  .deepPurpleAccent,
            ),

            const Spacer(),

            Text(

              value,

              style:
                  const TextStyle(

                color:
                    Colors.white,

                fontSize: 22,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 6),

            Text(

              title,

              style:
                  TextStyle(

                color: Colors
                    .white
                    .withOpacity(
                        0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // NAV ITEM
  // =========================

  Widget buildNavItem(

    IconData icon,

    bool isActive,
  ) {

    return Icon(

      icon,

      color: isActive

          ? Colors
              .deepPurpleAccent

          : Colors.white
              .withOpacity(
                  0.5),

      size: 28,
    );
  }
}