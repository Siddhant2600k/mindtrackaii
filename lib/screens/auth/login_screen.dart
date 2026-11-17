import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../services/auth_service.dart';

import '../home/home_screen.dart';

import '../onboarding/personal_info_screen.dart';

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<Offset>
      _slideAnimation;

  late Animation<double>
      _fadeAnimation;

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool isLoading = false;

  @override
  void initState() {

    super.initState();

    _controller =
        AnimationController(

      vsync: this,

      duration:
          const Duration(
              milliseconds: 1400),
    );

    _slideAnimation =
        Tween<Offset>(

      begin:
          const Offset(0, 0.15),

      end:
          Offset.zero,

    ).animate(

      CurvedAnimation(

        parent: _controller,

        curve:
            Curves.easeOutCubic,
      ),
    );

    _fadeAnimation =
        CurvedAnimation(

      parent: _controller,

      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {

    _controller.dispose();

    emailController.dispose();

    passwordController.dispose();

    super.dispose();
  }

  // =========================
  // LOGIN
  // =========================

  Future<void> login() async {

    setState(() {

      isLoading = true;
    });

    final user =
        await authService.login(

      email:
          emailController.text.trim(),

      password:
          passwordController.text.trim(),
    );

    setState(() {

      isLoading = false;
    });

    if (user != null) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
              const HomeScreen(),
        ),
      );
    }
  }

  // =========================
  // GOOGLE LOGIN
  // =========================

  Future<void> googleLogin()
      async {

    setState(() {

      isLoading = true;
    });

    final user =
        await authService
            .signInWithGoogle();

    setState(() {

      isLoading = false;
    });

    if (user == null) return;

    final userDoc =

        await FirebaseFirestore
            .instance

            .collection('users')

            .doc(user.uid)

            .get();

    final data =
        userDoc.data();

    final onboardingCompleted =

        data?[
                'onboardingCompleted']
            ?? false;

    if (onboardingCompleted) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
              const HomeScreen(),
        ),
      );

    } else {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
              const PersonalInfoScreen(),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      body: Container(

        width: double.infinity,

        decoration:
            const BoxDecoration(

          gradient:
              LinearGradient(

            colors: [

              Color(0xFF0F0F1A),

              Color(0xFF1C1B2D),

              Color(0xFF2C2345),
            ],

            begin:
                Alignment.topLeft,

            end: Alignment
                .bottomRight,
          ),
        ),

        child: SafeArea(

          child: Center(

            child: Padding(

              padding:
                  const EdgeInsets.symmetric(

                horizontal: 20,

                vertical: 20,
              ),

              child: SlideTransition(

                position:
                    _slideAnimation,

                child: FadeTransition(

                  opacity:
                      _fadeAnimation,

                  child:
                      GlassmorphicContainer(

                    width:
                        double.infinity,

                    height:
                        MediaQuery.of(context)
                                .size
                                .height *
                            0.72,

                    borderRadius:
                        30,

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

                    child:
                        SingleChildScrollView(

                      child: Padding(

                        padding:
                            const EdgeInsets.all(
                                24),

                        child: Column(

                          children: [

                            const SizedBox(
                                height: 10),

                            const Icon(

                              Icons.auto_awesome,

                              color:
                                  Colors.deepPurpleAccent,

                              size: 60,
                            ),

                            const SizedBox(
                                height: 18),

                            const Text(

                              'Welcome Back',

                              style:
                                  TextStyle(

                                color:
                                    Colors.white,

                                fontSize:
                                    30,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                                height: 8),

                            Text(

                              'Track your emotions & growth',

                              style:
                                  TextStyle(

                                color: Colors
                                    .white
                                    .withOpacity(
                                        0.7),
                              ),
                            ),

                            const SizedBox(
                                height: 32),

                            buildTextField(

                              controller:
                                  emailController,

                              hint:
                                  'Email',

                              icon:
                                  Icons.email_outlined,
                            ),

                            const SizedBox(
                                height: 18),

                            buildTextField(

                              controller:
                                  passwordController,

                              hint:
                                  'Password',

                              icon:
                                  Icons.lock_outline,

                              obscureText:
                                  true,
                            ),

                            const SizedBox(
                                height: 28),

                            buildLoginButton(),

                            const SizedBox(
                                height: 14),

                            buildGoogleButton(),

                            const SizedBox(
                                height: 18),

                            Row(

                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [

                                Text(

                                  "Don't have account? ",

                                  style:
                                      TextStyle(

                                    color: Colors
                                        .white
                                        .withOpacity(
                                            0.7),
                                  ),
                                ),

                                GestureDetector(

                                  onTap: () {

                                    Navigator.push(

                                      context,

                                      MaterialPageRoute(

                                        builder: (_) =>
                                            const SignupScreen(),
                                      ),
                                    );
                                  },

                                  child:
                                      const Text(

                                    'Sign Up',

                                    style:
                                        TextStyle(

                                      color: Colors
                                          .deepPurpleAccent,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({

    required TextEditingController
        controller,

    required String hint,

    required IconData icon,

    bool obscureText = false,
  }) {

    return TextField(

      controller: controller,

      obscureText: obscureText,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(

        hintText: hint,

        hintStyle: TextStyle(

          color: Colors.white
              .withOpacity(0.5),
        ),

        prefixIcon: Icon(

          icon,

          color:
              Colors.deepPurpleAccent,
        ),

        filled: true,

        fillColor:
            Colors.white.withOpacity(
                0.06),

        border: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(18),

          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  Widget buildLoginButton() {

    return SizedBox(

      width: double.infinity,

      height: 50,

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

        onPressed:
            isLoading ? null : login,

        child: isLoading

            ? const CircularProgressIndicator(
                color: Colors.white,
              )

            : const Text(
                'Login',
              ),
      ),
    );
  }

  Widget buildGoogleButton() {

    return SizedBox(

      width: double.infinity,

      height: 50,

      child:
          OutlinedButton.icon(

        style:
            OutlinedButton.styleFrom(

          side: BorderSide(

            color: Colors.white
                .withOpacity(0.15),
          ),

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
                    18),
          ),
        ),

        onPressed:
            isLoading
                ? null
                : googleLogin,

        icon: const Icon(

          Icons.g_mobiledata,

          color: Colors.white,

          size: 34,
        ),

        label: const Text(

          'Continue with Google',

          style: TextStyle(

            color: Colors.white,
          ),
        ),
      ),
    );
  }
}