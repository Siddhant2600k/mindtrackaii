import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../../services/gemini_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() =>
      _AICoachScreenState();
}

class _AICoachScreenState
    extends State<AICoachScreen> {

  final GeminiService geminiService =
      GeminiService();

  final TextEditingController
      messageController =
      TextEditingController();

  List<Map<String, String>> messages =
      [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    addWelcomeMessage();
  }

  // =========================
  // WELCOME MESSAGE
  // =========================

  void addWelcomeMessage() {

    messages.add({

      'role': 'ai',

      'text':
          'Hello 👋 I am your AI Emotional Coach.\n\nI can analyze your emotional trends, burnout patterns, stress levels, and journaling history to help guide and support you.',
    });
  }

  // =========================
  // BUILD EMOTIONAL CONTEXT
  // =========================

  Future<String> buildContext() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {

      return '';
    }

    final snapshot =
        await FirebaseFirestore.instance

            .collection('users')
            .doc(user.uid)
            .collection('daily_summaries')

            .orderBy(
              'updatedAt',
              descending: true,
            )

            .limit(7)

            .get();

    String context = '';

    for (var doc in snapshot.docs) {

      final data = doc.data();

      context += '''

Date: ${data['date']}

Mood: ${data['mood']}

Emotional Stability:
${data['emotionalStability']}

Stress Level:
${data['stressLevel']}

Productivity:
${data['productivity']}

Burnout Risk:
${data['burnoutRisk']}

Insight:
${data['insight']}

''';
    }

    return context;
  }

  // =========================
  // SEND MESSAGE
  // =========================

  Future<void> sendMessage() async {

    if (messageController.text
        .trim()
        .isEmpty) {

      return;
    }

    final userMessage =
        messageController.text.trim();

    setState(() {

      messages.add({

        'role': 'user',

        'text': userMessage,
      });

      isLoading = true;
    });

    messageController.clear();

    try {

      final emotionalContext =
          await buildContext();

      final fullPrompt = '''

You are an emotionally intelligent AI therapist and emotional coach.

You help users understand:
- stress
- burnout
- emotional patterns
- productivity fluctuations
- recovery patterns

You already know this user's recent emotional data:

$emotionalContext

Now respond to this user message with empathy, intelligence, emotional awareness, practical emotional guidance, and supportive coaching.

User Message:
$userMessage

''';

      final response =
          await geminiService
              .generateSimpleResponse(
                  fullPrompt);

      setState(() {

        messages.add({

          'role': 'ai',

          'text': response,
        });

        isLoading = false;
      });

    } catch (e) {

      setState(() {

        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
              Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFF0F0F1A),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Row(
          children: [

            CircleAvatar(

              backgroundColor:
                  Colors.deepPurpleAccent,

              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
              ),
            ),

            SizedBox(width: 14),

            Text(

              'AI Emotional Coach',

              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          // CHAT

          Expanded(

            child: ListView.builder(

              padding:
                  const EdgeInsets.all(
                      20),

              itemCount:
                  messages.length,

              itemBuilder:
                  (context, index) {

                final message =
                    messages[index];

                final isUser =
                    message['role'] ==
                        'user';

                return Align(

                  alignment: isUser

                      ? Alignment
                          .centerRight

                      : Alignment
                          .centerLeft,

                  child: Container(

                    margin:
                        const EdgeInsets
                            .only(
                                bottom:
                                    18),

                    padding:
                        const EdgeInsets
                            .all(18),

                    constraints:
                        const BoxConstraints(
                      maxWidth: 320,
                    ),

                    decoration:
                        BoxDecoration(

                      color: isUser

                          ? Colors
                              .deepPurpleAccent

                          : Colors.white
                              .withOpacity(
                                  0.07),

                      borderRadius:
                          BorderRadius
                              .circular(
                                  22),
                    ),

                    child: Text(

                      message['text']
                          ?? '',

                      style:
                          const TextStyle(

                        color:
                            Colors.white,

                        height: 1.6,

                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)

            Padding(

              padding:
                  const EdgeInsets.only(
                      bottom: 16),

              child:
                  CircularProgressIndicator(
                color:
                    Colors.deepPurpleAccent,
              ),
            ),

          // INPUT

          SafeArea(

            child: Container(

              padding:
                  const EdgeInsets.all(
                      16),

              decoration: BoxDecoration(

                color: Colors.white
                    .withOpacity(0.04),

                border: Border(

                  top: BorderSide(

                    color: Colors.white
                        .withOpacity(
                            0.06),
                  ),
                ),
              ),

              child: Row(
                children: [

                  Expanded(

                    child: TextField(

                      controller:
                          messageController,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),

                      maxLines: null,

                      decoration:
                          InputDecoration(

                        hintText:
                            'Talk to your AI coach...',

                        hintStyle:
                            TextStyle(

                          color: Colors
                              .white
                              .withOpacity(
                                  0.45),
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
                  ),

                  const SizedBox(width: 12),

                  GestureDetector(

                    onTap: sendMessage,

                    child: Container(

                      width: 58,
                      height: 58,

                      decoration:
                          const BoxDecoration(

                        color:
                            Colors
                                .deepPurpleAccent,

                        shape:
                            BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}