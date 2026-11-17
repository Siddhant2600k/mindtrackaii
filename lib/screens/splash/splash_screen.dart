import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

import '../home/home_screen.dart';

import '../../widgets/loaders/dot_loader.dart';

class SplashScreen
    extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController
      _controller;

  late Animation<double>
      _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(

      vsync: this,

      duration:
          const Duration(seconds: 2),
    );

    _fadeAnimation =
        Tween<double>(

      begin: 0,
      end: 1,

    ).animate(

      CurvedAnimation(

        parent: _controller,

        curve:
            Curves.easeInOut,
      ),
    );

    _controller.forward();

    checkLogin();
  }

  // =========================
  // CHECK LOGIN
  // =========================

  Future<void> checkLogin()
      async {

    await Future.delayed(
      const Duration(seconds: 4),
    );

    final user =
        FirebaseAuth
            .instance
            .currentUser;

    Widget nextScreen;

    if (user != null) {

      nextScreen =
          const HomeScreen();

    } else {

      nextScreen =
          const LoginScreen();
    }

    Navigator.pushReplacement(

      context,

      PageRouteBuilder(

        transitionDuration:
            const Duration(
                milliseconds: 1200),

        pageBuilder:
            (_, __, ___) =>
                nextScreen,

        transitionsBuilder:
            (_, animation,
                __, child) {

          return FadeTransition(

            opacity:
                animation,

            child:
                SlideTransition(

              position:
                  Tween<Offset>(

                begin:
                    const Offset(
                        0, 0.08),

                end:
                    Offset.zero,

              ).animate(

                CurvedAnimation(

                  parent:
                      animation,

                  curve: Curves
                      .easeOutCubic,
                ),
              ),

              child: child,
            ),
          );
        },
      ),
    );
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

        decoration:
            const BoxDecoration(

          gradient:
              LinearGradient(

            colors: [

              Color(0xFF0F0F1A),

              Color(0xFF1C1B2D),

              Color(0xFF2B2344),
            ],

            begin:
                Alignment.topLeft,

            end: Alignment
                .bottomRight,
          ),
        ),

        child: Center(

          child: FadeTransition(

            opacity:
                _fadeAnimation,

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment
                      .center,

              children: [

                Container(

                  padding:
                      const EdgeInsets
                          .all(24),

                  decoration:
                      BoxDecoration(

                    shape:
                        BoxShape.circle,

                    color: Colors
                        .white
                        .withOpacity(
                            0.05),

                    border: Border.all(

                      color: Colors
                          .deepPurpleAccent
                          .withOpacity(
                              0.3),
                    ),
                  ),

                  child:
                      const Icon(

                    Icons.auto_awesome,

                    size: 80,

                    color:
                        Colors
                            .deepPurpleAccent,
                  ),
                ),

                const SizedBox(
                    height: 28),

                const Text(

                  'MindTrack AI',

                  style: TextStyle(

                    color:
                        Colors.white,

                    fontSize: 34,

                    fontWeight:
                        FontWeight.bold,

                    letterSpacing:
                        1.2,
                  ),
                ),

                const SizedBox(
                    height: 12),

                Text(

                  'Understand yourself better',

                  style: TextStyle(

                    color: Colors
                        .white
                        .withOpacity(
                            0.7),

                    fontSize: 16,

                    letterSpacing:
                        0.4,
                  ),
                ),

                const SizedBox(
                    height: 50),

                const DotLoader(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}