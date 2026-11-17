import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {

  bool notificationsEnabled =
      true;

  bool aiInsightsEnabled =
      true;

  bool animationsEnabled =
      true;

  bool darkMode =
      true;

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {

    await FirebaseAuth
        .instance
        .signOut();

    if (!mounted) return;

    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
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

        centerTitle: true,

        title: const Text(

          'Settings',

          style: TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child:
            SingleChildScrollView(

          padding:
              const EdgeInsets
                  .all(20),

          child: Column(

            children: [

              // =========================
              // ACCOUNT
              // =========================

              buildSectionTitle(
                  'Account'),

              const SizedBox(
                  height: 14),

              buildSettingsCard(

                icon:
                    Icons.person_rounded,

                title:
                    'Edit Profile',

                subtitle:
                    'Update your personal information',

                onTap: () {},
              ),

              buildSettingsCard(

                icon:
                    Icons.email_rounded,

                title:
                    'Change Email',

                subtitle:
                    'Manage your account email',

                onTap: () {},
              ),

              buildSettingsCard(

                icon:
                    Icons.lock_rounded,

                title:
                    'Change Password',

                subtitle:
                    'Secure your account',

                onTap: () {},
              ),

              const SizedBox(
                  height: 28),

              // =========================
              // AI & WELLNESS
              // =========================

              buildSectionTitle(
                  'AI & Wellness'),

              const SizedBox(
                  height: 14),

              buildSwitchCard(

                icon:
                    Icons.notifications_active_rounded,

                title:
                    'Daily Notifications',

                subtitle:
                    'Receive wellness reminders',

                value:
                    notificationsEnabled,

                onChanged:
                    (value) {

                  setState(() {

                    notificationsEnabled =
                        value;
                  });
                },
              ),

              buildSwitchCard(

                icon:
                    Icons.auto_awesome_rounded,

                title:
                    'AI Insights',

                subtitle:
                    'Enable smart emotional insights',

                value:
                    aiInsightsEnabled,

                onChanged:
                    (value) {

                  setState(() {

                    aiInsightsEnabled =
                        value;
                  });
                },
              ),

              const SizedBox(
                  height: 28),

              // =========================
              // APPEARANCE
              // =========================

              buildSectionTitle(
                  'Appearance'),

              const SizedBox(
                  height: 14),

              buildSwitchCard(

                icon:
                    Icons.dark_mode_rounded,

                title:
                    'Dark Mode',

                subtitle:
                    'Use dark futuristic theme',

                value:
                    darkMode,

                onChanged:
                    (value) {

                  setState(() {

                    darkMode =
                        value;
                  });
                },
              ),

              buildSwitchCard(

                icon:
                    Icons.animation_rounded,

                title:
                    'Animations',

                subtitle:
                    'Enable smooth UI animations',

                value:
                    animationsEnabled,

                onChanged:
                    (value) {

                  setState(() {

                    animationsEnabled =
                        value;
                  });
                },
              ),

              const SizedBox(
                  height: 28),

              // =========================
              // PRIVACY
              // =========================

              buildSectionTitle(
                  'Privacy'),

              const SizedBox(
                  height: 14),

              buildSettingsCard(

                icon:
                    Icons.delete_forever_rounded,

                title:
                    'Delete All Journals',

                subtitle:
                    'Permanently remove journal history',

                iconColor:
                    Colors.redAccent,

                onTap: () {},
              ),

              buildSettingsCard(

                icon:
                    Icons.download_rounded,

                title:
                    'Export Data',

                subtitle:
                    'Download your wellness data',

                onTap: () {},
              ),

              const SizedBox(
                  height: 28),

              // =========================
              // ABOUT
              // =========================

              buildSectionTitle(
                  'About'),

              const SizedBox(
                  height: 14),

              buildSettingsCard(

                icon:
                    Icons.info_rounded,

                title:
                    'About MindTrack AI',

                subtitle:
                    'Version 1.0.0',

                onTap: () {},
              ),

              buildSettingsCard(

                icon:
                    Icons.support_agent_rounded,

                title:
                    'Support',

                subtitle:
                    'Contact support team',

                onTap: () {},
              ),

              const SizedBox(
                  height: 36),

              // =========================
              // LOGOUT BUTTON
              // =========================

              SizedBox(

                width:
                    double.infinity,

                height: 58,

                child:
                    ElevatedButton.icon(

                  style:
                      ElevatedButton
                          .styleFrom(

                    backgroundColor:
                        Colors.redAccent,

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius
                              .circular(
                                  18),
                    ),
                  ),

                  onPressed:
                      logout,

                  icon:
                      const Icon(

                    Icons.logout_rounded,

                    color:
                        Colors.white,
                  ),

                  label:
                      const Text(

                    'Logout',

                    style: TextStyle(

                      fontSize: 16,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget buildSectionTitle(
      String title) {

    return Align(

      alignment:
          Alignment.centerLeft,

      child: Text(

        title,

        style: const TextStyle(

          color: Colors.white,

          fontSize: 20,

          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // =========================
  // SETTINGS CARD
  // =========================

  Widget buildSettingsCard({

    required IconData icon,

    required String title,

    required String subtitle,

    required VoidCallback onTap,

    Color iconColor =
        Colors.deepPurpleAccent,

  }) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 14),

      decoration:
          BoxDecoration(

        color: Colors.white
            .withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(
                22),

        border: Border.all(

          color: Colors.white
              .withOpacity(0.08),
        ),

        boxShadow: [

          BoxShadow(

            color: Colors.black
                .withOpacity(0.25),

            blurRadius: 18,

            offset:
                const Offset(0, 8),
          ),
        ],
      ),

      child: ListTile(

        contentPadding:
            const EdgeInsets.symmetric(

          horizontal: 18,

          vertical: 10,
        ),

        leading: Container(

          width: 48,

          height: 48,

          decoration:
              BoxDecoration(

            color:
                iconColor.withOpacity(
                    0.15),

            borderRadius:
                BorderRadius.circular(
                    16),
          ),

          child: Icon(

            icon,

            color: iconColor,
          ),
        ),

        title: Text(

          title,

          style: const TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.w600,
          ),
        ),

        subtitle: Padding(

          padding:
              const EdgeInsets.only(
                  top: 4),

          child: Text(

            subtitle,

            style: TextStyle(

              color: Colors.white
                  .withOpacity(0.6),
            ),
          ),
        ),

        trailing: const Icon(

          Icons.arrow_forward_ios_rounded,

          color: Colors.white54,

          size: 18,
        ),

        onTap: onTap,
      ),
    );
  }

  // =========================
  // SWITCH CARD
  // =========================

  Widget buildSwitchCard({

    required IconData icon,

    required String title,

    required String subtitle,

    required bool value,

    required Function(bool)
        onChanged,

  }) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 14),

      decoration:
          BoxDecoration(

        color: Colors.white
            .withOpacity(0.05),

        borderRadius:
            BorderRadius.circular(
                22),

        border: Border.all(

          color: Colors.white
              .withOpacity(0.08),
        ),

        boxShadow: [

          BoxShadow(

            color: Colors.black
                .withOpacity(0.25),

            blurRadius: 18,

            offset:
                const Offset(0, 8),
          ),
        ],
      ),

      child: SwitchListTile(

        contentPadding:
            const EdgeInsets.symmetric(

          horizontal: 18,

          vertical: 8,
        ),

        value: value,

        onChanged: onChanged,

        activeColor:
            Colors.deepPurpleAccent,

        secondary: Container(

          width: 48,

          height: 48,

          decoration:
              BoxDecoration(

            color: Colors
                .deepPurpleAccent
                .withOpacity(0.15),

            borderRadius:
                BorderRadius.circular(
                    16),
          ),

          child: Icon(

            icon,

            color:
                Colors.deepPurpleAccent,
          ),
        ),

        title: Text(

          title,

          style: const TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.w600,
          ),
        ),

        subtitle: Text(

          subtitle,

          style: TextStyle(

            color: Colors.white
                .withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}