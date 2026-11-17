import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
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
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),

              child: SlideTransition(
                position: _slideAnimation,

                child: FadeTransition(
                  opacity: _fadeAnimation,

                  child: GlassmorphicContainer(
                    width: double.infinity,

                    height:
                        MediaQuery.of(context)
                                .size
                                .height *
                            0.78,

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

                    child: SingleChildScrollView(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [

                            Container(
                              padding:
                                  const EdgeInsets.all(16),

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                color: Colors.white
                                    .withOpacity(0.08),
                              ),

                              child: const Icon(
                                Icons.person_add_alt_1,
                                size: 50,
                                color:
                                    Colors.deepPurpleAccent,
                              ),
                            ),

                            const SizedBox(height: 18),

                            const Text(
                              'Create Account',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Begin your emotional growth journey',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 28),

                            buildTextField(
                              controller:
                                  nameController,

                              hint: 'Full Name',

                              icon:
                                  Icons.person_outline,
                            ),

                            const SizedBox(height: 16),

                            buildTextField(
                              controller:
                                  emailController,

                              hint: 'Email',

                              icon:
                                  Icons.email_outlined,
                            ),

                            const SizedBox(height: 16),

                            buildTextField(
                              controller:
                                  passwordController,

                              hint: 'Password',

                              icon:
                                  Icons.lock_outline,

                              obscureText: true,
                            ),

                            const SizedBox(height: 16),

                            buildTextField(
                              controller:
                                  confirmPasswordController,

                              hint: 'Confirm Password',

                              icon:
                                  Icons.lock_reset_outlined,

                              obscureText: true,
                            ),

                            const SizedBox(height: 24),

                            buildSignupButton(),

                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [

                                Text(
                                  "Already have account? ",

                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.7),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },

                                  child: const Text(
                                    'Login',

                                    style: TextStyle(
                                      color:
                                          Colors.deepPurpleAccent,
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
    required TextEditingController controller,
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

  Widget buildSignupButton() {

    return SizedBox(
      width: double.infinity,
      height: 50,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.deepPurpleAccent,

          elevation: 10,

          shadowColor:
              Colors.deepPurpleAccent
                  .withOpacity(0.4),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),

        onPressed: () async {

          if (passwordController.text !=
              confirmPasswordController.text) {

            ScaffoldMessenger.of(context)
                .showSnackBar(

              const SnackBar(
                content:
                    Text("Passwords do not match"),
              ),
            );

            return;
          }

          final user =
              await authService.signUp(

            email:
                emailController.text.trim(),

            password:
                passwordController.text.trim(),
          );

          if (user != null) {

            ScaffoldMessenger.of(context)
                .showSnackBar(

              const SnackBar(
                content:
                    Text("Account Created!"),
              ),
            );

          } else {

            ScaffoldMessenger.of(context)
                .showSnackBar(

              const SnackBar(
                content:
                    Text("Signup Failed"),
              ),
            );
          }
        },

        child: const Text(
          'Create Account',

          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}