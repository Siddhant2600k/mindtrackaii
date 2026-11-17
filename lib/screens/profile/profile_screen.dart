import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  bool isLoading = true;

  Map<String, dynamic> userData = {};

  int totalJournals = 0;

  String emotionalStability =
      '70';

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {

    try {

      final user =
          FirebaseAuth
              .instance
              .currentUser;

      if (user == null) return;

      final doc =
          await FirebaseFirestore
              .instance
              .collection('users')
              .doc(user.uid)
              .get();

      final journals =
          await FirebaseFirestore
              .instance
              .collection('users')
              .doc(user.uid)
              .collection('journals')
              .orderBy(
                  'createdAt',
                  descending: true)
              .get();

      String latestStability =
          '70';

      if (journals.docs.isNotEmpty) {

        final latestJournal =
            journals.docs.first.data();

        latestStability =

            latestJournal[
                    'emotionalStability']
                ?.toString() ??
            '70';
      }

      setState(() {

        userData =
            doc.data() ?? {};

        totalJournals =
            journals.docs.length;

        emotionalStability =
            latestStability;

        isLoading = false;
      });

    } catch (e) {

      debugPrint(
          'Profile Error: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(
      BuildContext context) {

    final screenHeight =
        MediaQuery.of(context)
            .size
            .height;

    return Scaffold(

      backgroundColor:
          const Color(
              0xFF0F0F1A),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        centerTitle: true,

        title: const Text(

          'Profile',

          style: TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.bold,
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

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(
                      20),

              child: Column(

                children: [

                  // HERO CARD

                  GlassmorphicContainer(

                    width:
                        double.infinity,

                    height:
                        screenHeight < 750
                            ? 360
                            : screenHeight *
                                0.40,

                    borderRadius: 32,

                    blur: 20,

                    alignment:
                        Alignment.center,

                    border: 1.5,

                    linearGradient:
                        LinearGradient(

                      begin:
                          Alignment.topLeft,

                      end:
                          Alignment.bottomRight,

                      colors: [

                        Colors.white
                            .withOpacity(
                                0.12),

                        Colors.white
                            .withOpacity(
                                0.05),
                      ],
                    ),

                    borderGradient:
                        LinearGradient(

                      colors: [

                        Colors
                            .deepPurpleAccent
                            .withOpacity(
                                0.7),

                        Colors.white
                            .withOpacity(
                                0.1),
                      ],
                    ),

                    child: Padding(

                      padding:
                          const EdgeInsets
                              .all(24),

                      child: Column(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          Container(

                            padding:
                                const EdgeInsets
                                    .all(5),

                            decoration:
                                BoxDecoration(

                              shape:
                                  BoxShape.circle,

                              gradient:
                                  const LinearGradient(

                                colors: [

                                  Colors
                                      .deepPurpleAccent,

                                  Colors.purple,
                                ],
                              ),

                              boxShadow: [

                                BoxShadow(

                                  color: Colors
                                      .deepPurpleAccent
                                      .withOpacity(
                                          0.5),

                                  blurRadius:
                                      25,
                                ),
                              ],
                            ),

                            child:
                                CircleAvatar(

                              radius: 50,

                              backgroundColor:
                                  const Color(
                                      0xFF141427),

                              backgroundImage:

                                  userData['photo'] !=
                                              null &&
                                          userData['photo']
                                              .toString()
                                              .isNotEmpty

                                      ? NetworkImage(
                                          userData['photo'],
                                        )

                                      : null,

                              child:
                                  userData['photo'] ==
                                          null

                                      ? Text(

                                          userData['name'] !=
                                                      null &&
                                                  userData['name']
                                                      .toString()
                                                      .isNotEmpty

                                              ? userData['name'][0]
                                                  .toUpperCase()

                                              : 'M',

                                          style:
                                              const TextStyle(

                                            color:
                                                Colors.white,

                                            fontSize:
                                                42,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        )

                                      : null,
                            ),
                          ),

                          const SizedBox(
                              height: 20),

                          Text(

                            userData['name'] ??
                                'MindTrack User',

                            textAlign:
                                TextAlign.center,

                            style:
                                const TextStyle(

                              color:
                                  Colors.white,

                              fontSize: 28,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 8),

                          Text(

                            userData['email'] ??
                                '',

                            style:
                                TextStyle(

                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.7),

                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          Text(

                            userData['lifestyle'] ??
                                'Student',

                            style: TextStyle(

                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.65),

                              fontSize: 14,

                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 24),

                  Wrap(

                    spacing: 12,

                    runSpacing: 12,

                    alignment:
                        WrapAlignment.center,

                    children: [

                      buildStatCard(

                        icon:
                            Icons.menu_book,

                        value:
                            '$totalJournals',

                        label:
                            'Journals',
                      ),

                      buildStatCard(

                        icon:
                            Icons.favorite,

                        value:
                            '$emotionalStability%',

                        label:
                            'Stability',
                      ),

                      buildStatCard(

                        icon:
                            Icons.local_fire_department,

                        value:
                            '${userData['streak'] ?? 0}',

                        label:
                            'Streak',
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 24),

                  buildInfoCard(

                    title:
                        'AI Personality',

                    content:
                        'Reflective thinker with strong emotional awareness and productivity-focused mindset.',
                  ),

                  const SizedBox(
                      height: 18),

                  buildGoalsCard(),

                  const SizedBox(
                      height: 24),

                  Row(

                    children: [

                      Expanded(

                        child:
                            buildActionButton(

                          icon:
                              Icons.edit,

                          title:
                              'Edit',

                          onTap: () {},
                        ),
                      ),

                      const SizedBox(
                          width: 14),

                      Expanded(

                        child:
                            buildActionButton(

                          icon:
                              Icons.settings,

                          title:
                              'Settings',

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 30),

                  SizedBox(

                    width:
                        double.infinity,

                    height: 58,

                    child:
                        ElevatedButton.icon(

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            Colors.redAccent,

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(
                                  18),
                        ),
                      ),

                      onPressed:
                          () async {

                        await FirebaseAuth
                            .instance
                            .signOut();

                        Navigator.pushAndRemoveUntil(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const LoginScreen(),
                          ),

                          (route) => false,
                        );
                      },

                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),

                      label: const Text(

                        'Logout',

                        style: TextStyle(

                          color:
                              Colors.white,

                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildStatCard({

    required IconData icon,

    required String value,

    required String label,
  }) {

    return Container(

      width: 100,

      padding:
          const EdgeInsets.symmetric(
              vertical: 16),

      decoration:
          BoxDecoration(

        borderRadius:
            BorderRadius.circular(
                24),

        color:
            Colors.white.withOpacity(
                0.05),
      ),

      child: Column(

        children: [

          Icon(

            icon,

            color:
                Colors.deepPurpleAccent,

            size: 26,
          ),

          const SizedBox(
              height: 10),

          Text(

            value,

            style:
                const TextStyle(

              color:
                  Colors.white,

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 5),

          Text(

            label,

            style:
                TextStyle(

              color: Colors
                  .white
                  .withOpacity(0.7),

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard({

    required String title,

    required String content,
  }) {

    return buildGlassCard(
      height: 130,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(

            title,

            style:
                const TextStyle(

              color:
                  Colors.white,

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 14),

          Expanded(

            child:
                SingleChildScrollView(

              child: Text(

                content,

                style:
                    TextStyle(

                  color: Colors
                      .white
                      .withOpacity(
                          0.75),

                  height: 1.6,

                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGoalsCard() {

    final goals =
        (userData['goals']
                    as List?)
                ?.cast<String>() ??
            [];

    return buildGlassCard(
      height: 190,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Text(

            'Your Goals',

            style:
                TextStyle(

              color:
                  Colors.white,

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 18),

          Expanded(

            child:
                SingleChildScrollView(

              child: Wrap(

                spacing: 10,

                runSpacing: 10,

                children:

                    goals.map((goal) {

                  return Container(

                    padding:
                        const EdgeInsets.symmetric(

                      horizontal: 14,

                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(

                      color:
                          Colors.deepPurpleAccent
                              .withOpacity(
                                  0.18),

                      borderRadius:
                          BorderRadius.circular(
                              30),
                    ),

                    child: Text(

                      goal,

                      style:
                          const TextStyle(

                        color:
                            Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGlassCard({

    required double height,

    required Widget child,
  }) {

    return GlassmorphicContainer(

      width: double.infinity,

      height: height,

      borderRadius: 26,

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
            const EdgeInsets.all(
                22),

        child: child,
      ),
    );
  }

  Widget buildActionButton({

    required IconData icon,

    required String title,

    required VoidCallback onTap,
  }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        height: 58,

        decoration:
            BoxDecoration(

          borderRadius:
              BorderRadius.circular(
                  18),

          gradient:
              const LinearGradient(

            colors: [

              Colors.deepPurpleAccent,

              Colors.purple,
            ],
          ),
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              color: Colors.white,
            ),

            const SizedBox(
                width: 10),

            Text(

              title,

              style:
                  const TextStyle(

                color:
                    Colors.white,

                fontWeight:
                    FontWeight.bold,

                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}