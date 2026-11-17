import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../services/firestore_service.dart';
import '../../services/gemini_service.dart';

class DayDetailScreen
    extends StatefulWidget {

  final DateTime selectedDate;

  const DayDetailScreen({

    super.key,

    required this.selectedDate,
  });

  @override
  State<DayDetailScreen> createState() =>
      _DayDetailScreenState();
}

class _DayDetailScreenState
    extends State<DayDetailScreen> {

  final FirestoreService
      firestoreService =
      FirestoreService();

  final GeminiService
      geminiService =
      GeminiService();

  final TextEditingController
      addController =
      TextEditingController();

  bool isLoading = true;

  Map<String, dynamic>? summary;

  List<QueryDocumentSnapshot>
      journals = [];

  File? selectedImage;

  @override
  void initState() {

    super.initState();

    fetchDayData();
  }

  String get dayId {

    return
        '${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}';
  }

  // =========================
  // OCR
  // =========================

  Future<void>
      pickImageAndExtractText()
  async {

    try {

      final picker =
          ImagePicker();

      final pickedFile =
          await picker.pickImage(

        source:
            ImageSource.gallery,
      );

      if (pickedFile == null) {
        return;
      }

      selectedImage =
          File(pickedFile.path);

      final inputImage =
          InputImage.fromFile(
              selectedImage!);

      final textRecognizer =
          TextRecognizer();

      final recognizedText =
          await textRecognizer
              .processImage(
                  inputImage);

      addController.text =
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

  // =========================
  // FETCH DATA
  // =========================

  Future<void>
      fetchDayData() async {

    final user =
        FirebaseAuth
            .instance
            .currentUser;

    if (user == null) return;

    setState(() {

      isLoading = true;
    });

    final summaryDoc =
        await firestoreService
            .getDailySummary(

      uid: user.uid,

      dayId: dayId,
    );

    final journalSnapshot =
        await firestoreService
            .getDayJournals(

      uid: user.uid,

      dayId: dayId,
    );

    setState(() {

      if (summaryDoc.exists) {

        summary =
            summaryDoc.data()
                as Map<String,
                    dynamic>;
      }

      journals =
          journalSnapshot.docs;

      isLoading = false;
    });
  }

  // =========================
  // RECALCULATE AI
  // =========================

  Future<void>
      recalculateDailyAI()
  async {

    final user =
        FirebaseAuth
            .instance
            .currentUser;

    if (user == null) return;

    final snapshot =
        await firestoreService
            .getDayJournals(

      uid: user.uid,

      dayId: dayId,
    );

    String combinedText =
        '';

    for (var doc
        in snapshot.docs) {

      final data =
          doc.data()
              as Map<String,
                  dynamic>;

      combinedText +=
          '\n\n${data['text']}';
    }

    combinedText =
        combinedText.trim();

    if (combinedText.isEmpty) {
      return;
    }

    final result =
        await geminiService
            .analyzeJournal(
                combinedText);

    await firestoreService
        .saveDailySummary(

      uid: user.uid,

      dayId: dayId,

      combinedText:
          combinedText,

      mood:
          result['mood']
              .toString(),

      emotionalStability:
          result[
                  'emotionalStability']
              .toString(),

      stressLevel:
          result[
                  'stressLevel']
              .toString(),

      productivity:
          result[
                  'productivity']
              .toString(),

      burnoutRisk:
          result[
                  'burnoutRisk']
              .toString(),

      insight:
          result['insight']
              .toString(),
    );

    await fetchDayData();

    setState(() {});
  }

  // =========================
  // EDIT JOURNAL
  // =========================

  Future<void> editJournal(

    String journalId,

    String oldText,
  ) async {

    final controller =
        TextEditingController(
      text: oldText,
    );

    await showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor:
              const Color(
                  0xFF1A1A2E),

          title: const Text(

            'Edit Journal',

            style: TextStyle(
              color:
                  Colors.white,
            ),
          ),

          content: TextField(

            controller:
                controller,

            maxLines: 8,

            style:
                const TextStyle(
              color:
                  Colors.white,
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                    context);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(

              onPressed:
                  () async {

                final user =
                    FirebaseAuth
                        .instance
                        .currentUser;

                if (user == null) {
                  return;
                }

                await firestoreService
                    .updateJournal(

                  uid: user.uid,

                  journalId:
                      journalId,

                  newText:
                      controller.text
                          .trim(),
                );

                Navigator.pop(
                    context);

                await recalculateDailyAI();
              },

              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // ADD ENTRY
  // =========================

  Future<void>
      addRetroactiveEntry()
  async {

    final user =
        FirebaseAuth
            .instance
            .currentUser;

    if (user == null) return;

    if (addController.text
        .trim()
        .isEmpty) {

      return;
    }

    await firestoreService
        .saveJournal(

      uid: user.uid,

      text:
          addController.text
              .trim(),

      mood: '',

      emotionalStability:
          '',

      stressLevel: '',

      productivity: '',

      burnoutRisk: '',

      insight: '',

      customDayId: dayId,
    );

    addController.clear();

    await recalculateDailyAI();
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

        title: Text(

          dayId,

          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: isLoading

          ? const Center(

              child:
                  CircularProgressIndicator(
                color: Colors
                    .deepPurpleAccent,
              ),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets
                      .all(20),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  // SUMMARY

                  if (summary != null)

                    Container(

                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(20),

                      decoration:
                          BoxDecoration(

                        color: Colors
                            .white
                            .withOpacity(
                                0.05),

                        borderRadius:
                            BorderRadius
                                .circular(
                                    24),
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(

                            summary![
                                    'mood'] ??
                                '',

                            style:
                                const TextStyle(

                              color:
                                  Colors.white,

                              fontSize:
                                  28,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                              height: 12),

                          Text(

                            'Emotional Stability: ${summary!['emotionalStability']}%',

                            style:
                                TextStyle(

                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.75),
                            ),
                          ),

                          const SizedBox(
                              height: 18),

                          Text(

                            summary![
                                    'insight'] ??
                                '',

                            style:
                                TextStyle(

                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.82),

                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(
                      height: 30),

                  // JOURNALS

                  const Text(

                    'All Entries',

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 18),

                  ...journals.map(

                    (doc) {

                      final data =
                          doc.data()
                              as Map<String,
                                  dynamic>;

                      return Container(

                        margin:
                            const EdgeInsets
                                .only(
                                    bottom:
                                        16),

                        padding:
                            const EdgeInsets
                                .all(18),

                        decoration:
                            BoxDecoration(

                          color: Colors
                              .white
                              .withOpacity(
                                  0.05),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      20),
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(

                              data['text']
                                      ??
                                  '',

                              style:
                                  TextStyle(

                                color: Colors
                                    .white
                                    .withOpacity(
                                        0.85),

                                height: 1.6,
                              ),
                            ),

                            const SizedBox(
                                height: 18),

                            Align(

                              alignment:
                                  Alignment
                                      .centerRight,

                              child:
                                  ElevatedButton(

                                onPressed:
                                    () {

                                  editJournal(

                                    doc.id,

                                    data[
                                        'text'],
                                  );
                                },

                                child:
                                    const Text(
                                  'Edit',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                      height: 30),

                  // OCR BUTTON

                  SizedBox(

                    width:
                        double.infinity,

                    height: 54,

                    child:
                        ElevatedButton
                            .icon(

                      style:
                          ElevatedButton
                              .styleFrom(

                        backgroundColor:
                            Colors
                                .deepPurpleAccent,

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      18),
                        ),
                      ),

                      onPressed:
                          pickImageAndExtractText,

                      icon:
                          const Icon(

                        Icons.image,

                        color:
                            Colors.white,
                      ),

                      label:
                          const Text(
                        'Upload Journal Image',
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  // INPUT

                  TextField(

                    controller:
                        addController,

                    maxLines: 6,

                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),

                    decoration:
                        InputDecoration(

                      hintText:
                          'Write retroactive journal...',

                      hintStyle:
                          TextStyle(

                        color: Colors
                            .white
                            .withOpacity(
                                0.4),
                      ),

                      filled: true,

                      fillColor:
                          Colors.white
                              .withOpacity(
                                  0.05),

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius
                                .circular(
                                    20),

                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  // SAVE BUTTON

                  SizedBox(

                    width:
                        double.infinity,

                    height: 56,

                    child:
                        ElevatedButton(

                      style:
                          ElevatedButton
                              .styleFrom(

                        backgroundColor:
                            Colors
                                .deepPurpleAccent,

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      18),
                        ),
                      ),

                      onPressed:
                          addRetroactiveEntry,

                      child: const Text(

                        'Save Entry',

                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}