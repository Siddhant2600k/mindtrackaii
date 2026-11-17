import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/home_screen.dart';

import '../../services/firestore_service.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() =>
      _LifestyleScreenState();
}

class _LifestyleScreenState
    extends State<LifestyleScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final FirestoreService firestoreService =
      FirestoreService();

  String selectedLifestyle = 'Student';

  String selectedSleepGoal = '8 Hours';

  String selectedWorkoutHabit =
      '3-4 Times/Week';

  String selectedProductivityGoal =
      '6 Hours';

  final List<String> lifestyleList = [
    'Student',
    'Working',
    'Freelancer',
    'Other',
  ];

  final List<String> sleepGoals = [
    '6 Hours',
    '7 Hours',
    '8 Hours',
    '9 Hours',
  ];

  final List<String> workoutHabits = [
    'Never',
    '1-2 Times/Week',
    '3-4 Times/Week',
    'Daily',
  ];

  final List<String> productivityGoals = [
    '2 Hours',
    '4 Hours',
    '6 Hours',
    '8+ Hours',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0F1A),
              Color(0xFF1C1B2D),
              Color(0xFF2C2345),
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 20,
            ),

            child: SlideTransition(
              position: _slideAnimation,

              child: FadeTransition(
                opacity: _fadeAnimation,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Container(
                            height: 6,

                            decoration: BoxDecoration(
                              color:
                                  Colors.deepPurpleAccent,

                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Container(
                            height: 6,

                            decoration: BoxDecoration(
                              color:
                                  Colors.deepPurpleAccent,

                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Container(
                            height: 6,

                            decoration: BoxDecoration(
                              color:
                                  Colors.deepPurpleAccent,

                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'Lifestyle Setup',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Help MindTrack AI understand your daily habits.',

                      style: TextStyle(
                        color:
                            Colors.white.withOpacity(0.7),

                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: GlassmorphicContainer(
                        width: double.infinity,
                        height: double.infinity,

                        borderRadius: 30,

                        blur: 20,

                        alignment: Alignment.center,

                        border: 1.5,

                        linearGradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(
                                0.10),
                            Colors.white.withOpacity(
                                0.05),
                          ],
                        ),

                        borderGradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(
                                0.5),
                            Colors.white.withOpacity(
                                0.1),
                          ],
                        ),

                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                                    24),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                buildSectionTitle(
                                  'Lifestyle',
                                ),

                                const SizedBox(
                                    height: 16),

                                buildChoiceWrap(
                                  lifestyleList,
                                  selectedLifestyle,
                                  (value) {

                                    setState(() {
                                      selectedLifestyle =
                                          value;
                                    });
                                  },
                                ),

                                const SizedBox(
                                    height: 28),

                                buildSectionTitle(
                                  'Sleep Goal',
                                ),

                                const SizedBox(
                                    height: 16),

                                buildChoiceWrap(
                                  sleepGoals,
                                  selectedSleepGoal,
                                  (value) {

                                    setState(() {
                                      selectedSleepGoal =
                                          value;
                                    });
                                  },
                                ),

                                const SizedBox(
                                    height: 28),

                                buildSectionTitle(
                                  'Workout Habit',
                                ),

                                const SizedBox(
                                    height: 16),

                                buildChoiceWrap(
                                  workoutHabits,
                                  selectedWorkoutHabit,
                                  (value) {

                                    setState(() {
                                      selectedWorkoutHabit =
                                          value;
                                    });
                                  },
                                ),

                                const SizedBox(
                                    height: 28),

                                buildSectionTitle(
                                  'Daily Productivity Goal',
                                ),

                                const SizedBox(
                                    height: 16),

                                buildChoiceWrap(
                                  productivityGoals,
                                  selectedProductivityGoal,
                                  (value) {

                                    setState(() {
                                      selectedProductivityGoal =
                                          value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,

                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepPurpleAccent,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    18),
                          ),
                        ),

                        onPressed: () async {

  final user =
      FirebaseAuth
          .instance
          .currentUser;

  if (user == null) return;

  await firestoreService
      .saveLifestyleData(

    uid: user.uid,

    lifestyle:
        selectedLifestyle,

    sleepGoal:
        selectedSleepGoal,

    workoutHabit:
        selectedWorkoutHabit,

    dailyProductivityGoal:
        selectedProductivityGoal,
  );

  // =========================
  // COMPLETE ONBOARDING
  // =========================

  await FirebaseFirestore
      .instance

      .collection('users')

      .doc(user.uid)

      .set({

    'onboardingCompleted':
        true,

  }, SetOptions(merge: true));

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(
      content:
          Text("Setup Complete!"),
    ),
  );

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder: (_) =>
          const HomeScreen(),
    ),
  );
},

                        child: const Text(
                          'Finish Setup',

                          style: TextStyle(
                            fontSize: 17,
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
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {

    return Text(
      title,

      style: TextStyle(
        color: Colors.white
            .withOpacity(0.85),

        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buildChoiceWrap(
    List<String> items,
    String selectedItem,
    Function(String) onSelect,
  ) {

    return Wrap(
      spacing: 12,
      runSpacing: 12,

      children: items.map((item) {

        final bool isSelected =
            item == selectedItem;

        return GestureDetector(
          onTap: () {
            onSelect(item);
          },

          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 250),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),

            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.deepPurpleAccent
                  : Colors.white
                      .withOpacity(0.06),

              borderRadius:
                  BorderRadius.circular(18),

              border: Border.all(
                color: isSelected
                    ? Colors.deepPurpleAccent
                    : Colors.white
                        .withOpacity(0.1),
              ),
            ),

            child: Text(
              item,

              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}