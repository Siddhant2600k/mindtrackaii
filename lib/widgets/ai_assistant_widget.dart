import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../services/ai_assistant_service.dart';

class AIAssistantWidget extends StatefulWidget {
  const AIAssistantWidget({super.key});

  @override
  State<AIAssistantWidget> createState() =>
      _AIAssistantWidgetState();
}

class _AIAssistantWidgetState
    extends State<AIAssistantWidget>
    with SingleTickerProviderStateMixin {

  final AIAssistantService aiService =
      AIAssistantService();

  final TextEditingController controller =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  bool isOpen = false;

  bool isExpanded = false;

  bool isLoading = false;

  String dailyInsight =
      'Loading AI insight...';

  List<Map<String, String>> messages =
      [];

  late AnimationController glowController;

  @override
  void initState() {

    super.initState();

    loadDailyInsight();

    glowController =
        AnimationController(

      vsync: this,

      duration:
          const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> loadDailyInsight()
  async {

    final insight =
        await aiService
            .generateDailyInsight();

    if (!mounted) return;

    setState(() {

      dailyInsight = insight;
    });
  }

  Future<void> sendMessage() async {

    final text =
        controller.text.trim();

    if (text.isEmpty) return;

    if (!isExpanded) {

      setState(() {

        isExpanded = true;
      });
    }

    setState(() {

      messages.add({

        'role': 'user',

        'message': text,
      });

      isLoading = true;
    });

    controller.clear();

    scrollToBottom();

    final response =
        await aiService.askAI(text);

    if (!mounted) return;

    setState(() {

      messages.add({

        'role': 'ai',

        'message': response,
      });

      isLoading = false;
    });

    scrollToBottom();
  }

  void scrollToBottom() {

    Timer(
      const Duration(milliseconds: 300),
      () {

        if (scrollController
            .hasClients) {

          scrollController.animateTo(

            scrollController
                .position
                .maxScrollExtent,

            duration:
                const Duration(
                    milliseconds: 300),

            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {

    glowController.dispose();

    controller.dispose();

    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight =
        MediaQuery.of(context)
            .size
            .height;

    return Stack(

      children: [

        // =========================
        // AI PANEL
        // =========================

        if (isOpen)

          Positioned(

            left: 16,

            right: 16,

            bottom: 100,

            child: Material(

              color: Colors.transparent,

              child: AnimatedContainer(

                duration:
                    const Duration(
                        milliseconds: 350),

                curve: Curves.easeOut,

                child:
                    GlassmorphicContainer(

                  width:
                      double.infinity,

                  height:

                      isExpanded

                          ? screenHeight *
                              0.72

                          : 330,

                  borderRadius: 28,

                  blur: 20,

                  alignment:
                      Alignment.center,

                  border: 1.5,

                  linearGradient:
                      LinearGradient(

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
                              0.6),

                      Colors.white
                          .withOpacity(
                              0.1),
                    ],
                  ),

                  child: Column(

                    children: [

                      // HEADER

                      Padding(

                        padding:
                            const EdgeInsets
                                .all(18),

                        child: Row(

                          children: [

                            Container(

                              padding:
                                  const EdgeInsets
                                      .all(10),

                              decoration:
                                  BoxDecoration(

                                shape:
                                    BoxShape.circle,

                                gradient:
                                    const LinearGradient(

                                  colors: [

                                    Colors
                                        .deepPurpleAccent,

                                    Colors
                                        .purple,
                                  ],
                                ),
                              ),

                              child:
                                  const Icon(

                                Icons.auto_awesome,

                                color:
                                    Colors.white,
                              ),
                            ),

                            const SizedBox(
                                width: 12),

                            const Expanded(

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(

                                    'MindTrack AI',

                                    style:
                                        TextStyle(

                                      color:
                                          Colors.white,

                                      fontSize: 16,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(
                                      height: 3),

                                  Text(

                                    'Emotional Wellness Assistant',

                                    style:
                                        TextStyle(

                                      color:
                                          Colors.white70,

                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(

                              onPressed: () {

                                setState(() {

                                  isOpen = false;

                                  isExpanded = false;
                                });
                              },

                              icon: const Icon(

                                Icons.close,

                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // INSIGHT

                      if (messages.isEmpty) ...[

  Container(

    margin:
        const EdgeInsets
            .symmetric(
                horizontal: 16),

    padding:
        const EdgeInsets
            .all(16),

    decoration:
        BoxDecoration(

      borderRadius:
          BorderRadius.circular(
              22),

      color: Colors
          .deepPurpleAccent
          .withOpacity(0.15),
    ),

    child: Column(

      crossAxisAlignment:
          CrossAxisAlignment
              .start,

      children: [

        const Text(

          '✨ Daily Insight',

          style: TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
            height: 10),

        Text(

          dailyInsight,

          maxLines:
              isExpanded
                  ? 6
                  : 3,

          overflow:
              TextOverflow
                  .ellipsis,

          style: TextStyle(

            color: Colors
                .white
                .withOpacity(
                    0.85),

            height: 1.5,

            fontSize: 13,
          ),
        ),
      ],
    ),
  ),

  const SizedBox(
      height: 12),
],

                      // CHAT

                      Expanded(

                        child:
                            ListView.builder(

                          controller:
                              scrollController,

                          padding:
                              const EdgeInsets
                                  .all(16),

                          itemCount:
                              messages.length,

                          itemBuilder:
                              (_, index) {

                            final message =
                                messages[index];

                            final isUser =

                                message['role'] ==
                                    'user';

                            return Align(

                              alignment:

                                  isUser

                                      ? Alignment
                                          .centerRight

                                      : Alignment
                                          .centerLeft,

                              child: Container(

                                margin:
                                    const EdgeInsets
                                        .only(
                                            bottom: 12),

                                padding:
                                    const EdgeInsets
                                        .all(14),

                                constraints:
                                    const BoxConstraints(
                                  maxWidth: 260,
                                ),

                                decoration:
                                    BoxDecoration(

                                  borderRadius:
                                      BorderRadius.circular(
                                          18),

                                  color:

                                      isUser

                                          ? Colors
                                              .deepPurpleAccent

                                          : Colors
                                              .white
                                              .withOpacity(
                                                  0.08),
                                ),

                                child: Text(

                                  message[
                                          'message'] ??
                                      '',

                                  style:
                                      const TextStyle(

                                    color:
                                        Colors.white,

                                    height: 1.5,

                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      if (isLoading)

                        const Padding(

                          padding:
                              EdgeInsets.only(
                                  bottom: 10),

                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.deepPurpleAccent,
                          ),
                        ),

                      // INPUT

                      Padding(

                        padding:
                            const EdgeInsets
                                .fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16),

                        child: Row(

                          children: [

                            Expanded(

                              child: TextField(

                                controller:
                                    controller,

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                ),

                                decoration:
                                    InputDecoration(

                                  hintText:
                                      'Ask MindTrack AI...',

                                  hintStyle:
                                      TextStyle(

                                    color: Colors
                                        .white
                                        .withOpacity(
                                            0.5),
                                  ),

                                  filled: true,

                                  fillColor:
                                      Colors.white
                                          .withOpacity(
                                              0.05),

                                  contentPadding:
                                      const EdgeInsets.symmetric(

                                    horizontal: 18,

                                    vertical: 14,
                                  ),

                                  border:
                                      OutlineInputBorder(

                                    borderRadius:
                                        BorderRadius.circular(
                                            18),

                                    borderSide:
                                        BorderSide.none,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                width: 12),

                            GestureDetector(

                              onTap:
                                  sendMessage,

                              child: Container(

                                padding:
                                    const EdgeInsets
                                        .all(14),

                                decoration:
                                    const BoxDecoration(

                                  shape:
                                      BoxShape.circle,

                                  gradient:
                                      LinearGradient(

                                    colors: [

                                      Colors
                                          .deepPurpleAccent,

                                      Colors.purple,
                                    ],
                                  ),
                                ),

                                child: const Icon(

                                  Icons.send,

                                  color:
                                      Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // =========================
        // FLOATING BUTTON
        // =========================

        // =========================
// FLOATING BUTTON
// =========================

    if (!isOpen)

    Positioned(

        right: 14,

        bottom: 88,

        child: GestureDetector(

            onTap: () {

              setState(() {

                isOpen = !isOpen;
              });
            },

            child: AnimatedBuilder(

              animation: glowController,

              builder: (_, child) {

                return Transform.scale(

                  scale:
                      1 +
                      (glowController.value *
                          0.08),

                  child: child,
                );
              },

              child: Container(

                width: 68,

                height: 68,

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
                          .withOpacity(0.6),

                      blurRadius: 30,

                      spreadRadius: 4,
                    ),
                  ],
                ),

                child: const Icon(

                  Icons.auto_awesome,

                  color: Colors.white,

                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}