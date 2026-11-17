import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:image_picker/image_picker.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../services/firestore_service.dart';
import '../../services/gemini_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() =>
      _JournalScreenState();
}

class _JournalScreenState
    extends State<JournalScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _fadeAnimation;

  final TextEditingController
      journalController =
      TextEditingController();

  final FirestoreService firestoreService =
      FirestoreService();

  final GeminiService geminiService =
      GeminiService();

  File? selectedImage;

  String aiInsight = '';

  String mood = '';

  String emotionalStability = '';

  String stressLevel = '';

  String productivity = '';

  String burnoutRisk = '';

  String insight = '';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  // OCR IMAGE PICKER

  Future<void> pickImageAndExtractText() async {

    try {

      final picker = ImagePicker();

      final pickedFile =
          await picker.pickImage(

        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      selectedImage =
          File(pickedFile.path);

      setState(() {});

      final inputImage =
          InputImage.fromFile(
              selectedImage!);

      final textRecognizer =
          TextRecognizer();

      final recognizedText =
          await textRecognizer
              .processImage(
                  inputImage);

      journalController.text =
          recognizedText.text;

      textRecognizer.close();

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'OCR failed: $e',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {

    _controller.dispose();

    journalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0F0F1A),

      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // HEADER

                Row(
                  children: [

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Daily Journal',

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  'Multiple entries in the same day are combined into one daily emotional analysis.',

                  style: TextStyle(
                    color:
                        Colors.white.withOpacity(0.7),

                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // OCR BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton.icon(

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
                        pickImageAndExtractText,

                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                    ),

                    label: const Text(
                      'Upload Image',

                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // IMAGE PREVIEW

                if (selectedImage != null)

                  Container(

                    margin:
                        const EdgeInsets.only(
                            bottom: 20),

                    height: 180,

                    width: double.infinity,

                    decoration: BoxDecoration(

                      borderRadius:
                          BorderRadius.circular(
                              24),

                      image: DecorationImage(

                        image:
                            FileImage(selectedImage!),

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // JOURNAL INPUT

                GlassmorphicContainer(

                  width: double.infinity,

                  height: 320,

                  borderRadius: 30,

                  blur: 20,

                  alignment:
                      Alignment.center,

                  border: 1.5,

                  linearGradient:
                      LinearGradient(

                    colors: [

                      Colors.white
                          .withOpacity(0.10),

                      Colors.white
                          .withOpacity(0.05),
                    ],
                  ),

                  borderGradient:
                      LinearGradient(

                    colors: [

                      Colors.white
                          .withOpacity(0.5),

                      Colors.white
                          .withOpacity(0.1),
                    ],
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                            22),

                    child: TextField(

                      controller:
                          journalController,

                      maxLines: null,

                      expands: true,

                      style:
                          const TextStyle(

                        color: Colors.white,

                        fontSize: 16,

                        height: 1.7,
                      ),

                      decoration:
                          InputDecoration(

                        hintText:
                            'Write about your day...',

                        hintStyle:
                            TextStyle(

                          color: Colors.white
                              .withOpacity(0.45),

                          height: 1.6,
                        ),

                        border:
                            InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // AI ANALYSIS CARD

                if (aiInsight.isNotEmpty)

                  Container(

                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(20),

                    decoration: BoxDecoration(

                      color: Colors.white
                          .withOpacity(0.06),

                      borderRadius:
                          BorderRadius.circular(
                              22),

                      border: Border.all(

                        color:
                            Colors
                                .deepPurpleAccent
                                .withOpacity(
                                    0.25),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Row(
                          children: [

                            Icon(
                              Icons.auto_awesome,

                              color: Colors
                                  .deepPurpleAccent,
                            ),

                            SizedBox(width: 10),

                            Text(
                              'Daily AI Analysis',

                              style: TextStyle(
                                color:
                                    Colors.white,

                                fontSize: 18,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 18),

                        Text(
                          aiInsight,

                          style: TextStyle(

                            color: Colors.white
                                .withOpacity(
                                    0.82),

                            fontSize: 15,

                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // SAVE BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(

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

                    onPressed: isLoading

                        ? null

                        : () async {

                            final user =
                                FirebaseAuth
                                    .instance
                                    .currentUser;

                            if (user == null) return;

                            if (journalController
                                .text
                                .trim()
                                .isEmpty) {

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    'Write something first.',
                                  ),
                                ),
                              );

                              return;
                            }

                            setState(() {

                              isLoading = true;
                            });

                            final journalText =
                                journalController
                                    .text
                                    .trim();

                            final now =
                                DateTime.now();

                            final todayId =
                                '${now.year}-${now.month}-${now.day}';

                            // FETCH TODAY ENTRIES

                            final todaySnapshot =
                                await FirebaseFirestore
                                    .instance

                                    .collection(
                                        'users')
                                    .doc(user.uid)
                                    .collection(
                                        'journals')

                                    .where(
                                      'dayId',
                                      isEqualTo:
                                          todayId,
                                    )

                                    .get();

                            String combinedText =
                                journalText;

                            for (var doc
                                in todaySnapshot
                                    .docs) {

                              combinedText +=

                                  '\n\n${doc['text']}';
                            }

                            // ANALYZE WHOLE DAY

                            final result =
                                await geminiService
                                    .analyzeJournal(
                                        combinedText);

                            debugPrint(
  'AI RESULT: $result',
);

mood =
    result['mood']
            ?.toString()
            .trim() ??
        'Neutral';

emotionalStability =
    result['emotionalStability']
            ?.toString()
            .trim() ??
        '50';

stressLevel =
    result['stressLevel']
            ?.toString()
            .trim() ??
        'Medium';

productivity =
    result['productivity']
            ?.toString()
            .trim() ??
        'Medium';

burnoutRisk =
    result['burnoutRisk']
            ?.toString()
            .trim() ??
        '50';

insight =
    result['insight']
            ?.toString()
            .trim() ??
        'Take care of yourself.';

                            // SAVE DAILY SUMMARY

                            await firestoreService
                                .saveDailySummary(

                              uid: user.uid,

                              dayId: todayId,

                              combinedText:
                                  combinedText,

                              mood: mood,

                              emotionalStability:
                                  emotionalStability,

                              stressLevel:
                                  stressLevel,

                              productivity:
                                  productivity,

                              burnoutRisk:
                                  burnoutRisk,

                              insight: insight,
                            );

                            aiInsight = '''

Overall Daily Mood: $mood

Emotional Stability:
$emotionalStability%

Stress Level:
$stressLevel

Productivity:
$productivity

Burnout Risk:
$burnoutRisk%

Daily Insight:
$insight

''';

                            setState(() {

                              isLoading = false;
                            });

                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(

                              const SnackBar(

                                content: Text(
                                  'Daily emotional state updated!',
                                ),
                              ),
                            );

                            journalController
                                .clear();
                          },

                    child: isLoading

                        ? const SizedBox(

                            height: 24,
                            width: 24,

                            child:
                                CircularProgressIndicator(

                              color:
                                  Colors.white,

                              strokeWidth: 2.5,
                            ),
                          )

                        : const Text(

                            'Update Daily Analysis',

                            style: TextStyle(

                              fontSize: 17,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}