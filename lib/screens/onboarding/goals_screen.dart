import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'lifestyle_screen.dart';
import '../../services/firestore_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() =>
      _GoalsScreenState();
}

class _GoalsScreenState
    extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final FirestoreService firestoreService =
      FirestoreService();

  List<String> selectedEmotionGoals = [];

  List<String> selectedProductivityGoals = [];

  List<String> selectedMainFocus = [];

  final List<String> emotionGoals = [
    'Reduce Stress',
    'Improve Happiness',
    'Stop Overthinking',
    'Control Anxiety',
  ];

  final List<String> productivityGoals = [
    'Improve Focus',
    'Build Discipline',
    'Stop Procrastination',
    'Better Routine',
  ];

  final List<String> mainFocusList = [
    'Mental Health',
    'Productivity',
    'Self Growth',
    'Work-Life Balance',
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
                              color: Colors.white
                                  .withOpacity(0.1),

                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'Your Goals & Intentions',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Select all that match your priorities.',

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
                                  'Emotional Goals',
                                ),

                                const SizedBox(
                                    height: 16),

                                buildChoiceWrap(
                                  emotionGoals,
                                  selectedEmotionGoals,
                                ),

                                const SizedBox(
                                    height: 28),

                                buildSectionTitle(
                                  'Productivity Goals',
                                ),

                                const SizedBox(
                                    height: 16),

                                buildChoiceWrap(
                                  productivityGoals,
                                  selectedProductivityGoals,
                                ),

                                const SizedBox(
                                    height: 28),

                                buildSectionTitle(
                                  'Main Focus',
                                ),

                                const SizedBox(
                                    height: 16),

                                buildChoiceWrap(
                                  mainFocusList,
                                  selectedMainFocus,
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

  final allGoals = [

    ...selectedEmotionGoals,

    ...selectedProductivityGoals,

    ...selectedMainFocus,
  ];

  await firestoreService
      .saveUserGoals(

    uid: user.uid,

    goals: allGoals,
  );

  ScaffoldMessenger.of(
          context)
      .showSnackBar(

    const SnackBar(
      content:
          Text("Goals Saved!"),
    ),
  );

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder: (_) =>
          const LifestyleScreen(),
    ),
  );
},

                        child: const Text(
                          'Continue',

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
    List<String> selectedItems,
  ) {

    return Wrap(
      spacing: 12,
      runSpacing: 12,

      children: items.map((item) {

        final bool isSelected =
            selectedItems.contains(item);

        return GestureDetector(
          onTap: () {

            setState(() {

              if (isSelected) {

                selectedItems.remove(item);

              } else {

                selectedItems.add(item);
              }
            });
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