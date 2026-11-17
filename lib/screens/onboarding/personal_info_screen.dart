import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'goals_screen.dart';
import '../../services/firestore_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() =>
      _PersonalInfoScreenState();
}

class _PersonalInfoScreenState
    extends State<PersonalInfoScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController ageController =
      TextEditingController();

  final FirestoreService firestoreService =
      FirestoreService();

  String selectedGender = 'Male';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

    nameController.dispose();
    ageController.dispose();

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

                    // PROGRESS BAR

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
                              color: Colors.white
                                  .withOpacity(0.1),

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

                    const SizedBox(height: 45),

                    const Text(
                      'Tell us about yourself',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'This helps MindTrack AI personalize your experience.',

                      style: TextStyle(
                        color:
                            Colors.white.withOpacity(0.7),

                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 45),

                    GlassmorphicContainer(
                      width: double.infinity,
                      height: 360,

                      borderRadius: 30,

                      blur: 20,

                      alignment: Alignment.center,

                      border: 1.5,

                      linearGradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.10),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),

                      borderGradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),

                      child: Padding(
                        padding:
                            const EdgeInsets.all(24),

                        child: Column(
                          children: [

                            buildTextField(
                              controller:
                                  nameController,

                              hint: 'Full Name',

                              icon:
                                  Icons.person_outline,
                            ),

                            const SizedBox(height: 22),

                            buildTextField(
                              controller:
                                  ageController,

                              hint: 'Age',

                              icon:
                                  Icons.cake_outlined,
                            ),

                            const SizedBox(height: 30),

                            Align(
                              alignment:
                                  Alignment.centerLeft,

                              child: Text(
                                'Gender',

                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.8),

                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [

                                buildGenderCard(
                                  title: 'Male',
                                ),

                                const SizedBox(width: 12),

                                buildGenderCard(
                                  title: 'Female',
                                ),

                                const SizedBox(width: 12),

                                buildGenderCard(
                                  title: 'Other',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

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
      .saveUserProfile(

    uid: user.uid,

    name:
        nameController.text
            .trim(),

    age:
        ageController.text
            .trim(),

    gender:
        selectedGender,

    email:
        user.email ?? '',
  );

  ScaffoldMessenger.of(
          context)
      .showSnackBar(

    const SnackBar(
      content:
          Text("Profile Saved!"),
    ),
  );

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder: (_) =>
          const GoalsScreen(),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {

    return TextField(
      controller: controller,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
        ),

        prefixIcon: Icon(
          icon,
          color: Colors.deepPurpleAccent,
        ),

        filled: true,

        fillColor: Colors.white.withOpacity(0.06),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildGenderCard({
    required String title,
  }) {

    final bool isSelected =
        selectedGender == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {

          setState(() {
            selectedGender = title;
          });
        },

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 300),

          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),

          decoration: BoxDecoration(
            color: isSelected
                ? Colors.deepPurpleAccent
                : Colors.white.withOpacity(0.05),

            borderRadius:
                BorderRadius.circular(18),

            border: Border.all(
              color: isSelected
                  ? Colors.deepPurpleAccent
                  : Colors.white.withOpacity(0.1),
            ),
          ),

          child: Center(
            child: Text(
              title,

              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}