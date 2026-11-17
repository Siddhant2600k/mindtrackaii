import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart'
    as http;

class AIAssistantService {

  // =========================
  // GEMINI API KEY
  // =========================

  final String apiKey =
      'AIzaSyBDurj6w-_QvHlHb0yF7IHkoOXZ9gL045Q';

  // =========================
  // MAIN AI CHAT METHOD
  // =========================

  Future<String> askAI(
    String userMessage,
  ) async {

    try {

      final user =
          FirebaseAuth
              .instance
              .currentUser;

      if (user == null) {

        return 'User not logged in.';
      }

      // =========================
      // FETCH USER PROFILE
      // =========================

      final userDoc =

          await FirebaseFirestore
              .instance
              .collection('users')
              .doc(user.uid)
              .get();

      final userData =
          userDoc.data() ?? {};

      // =========================
      // DATE DETECTION
      // =========================

      final lowerMessage =
          userMessage.toLowerCase();

      final dateRegex = RegExp(

        r'(\d{1,2})\s+(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{4})',

        caseSensitive: false,
      );

      String emotionalContext =
          '';

      final match =
          dateRegex.firstMatch(
              lowerMessage);

      // =========================
      // IF USER ASKED ABOUT DATE
      // =========================

      if (match != null) {

        final day =
            match.group(1)!;

        final monthName =
            match.group(2)!;

        final year =
            match.group(3)!;

        final monthMap = {

          'january': 1,
          'february': 2,
          'march': 3,
          'april': 4,
          'may': 5,
          'june': 6,
          'july': 7,
          'august': 8,
          'september': 9,
          'october': 10,
          'november': 11,
          'december': 12,
        };

        final month =
            monthMap[
                monthName.toLowerCase()]!;

        final dayId =
            '$year-$month-${int.parse(day)}';

        final snapshot =

            await FirebaseFirestore
                .instance
                .collection('users')
                .doc(user.uid)
                .collection(
                    'daily_summaries')
                .where(
                  'date',
                  isEqualTo: dayId,
                )
                .get();

        if (snapshot.docs.isEmpty) {

          return
              'No emotional records were found for $day $monthName $year.';
        }

        for (var doc
            in snapshot.docs) {

          final data =
              doc.data();

          emotionalContext += '''

Date:
${data['date'] ?? ''}

Mood:
${data['mood'] ?? ''}

Emotional Stability:
${data['emotionalStability'] ?? ''}

Stress Level:
${data['stressLevel'] ?? ''}

Productivity:
${data['productivity'] ?? ''}

Burnout Risk:
${data['burnoutRisk'] ?? ''}

Insight:
${data['insight'] ?? ''}

Daily Summary:
${data['combinedText'] ?? ''}

--------------------
''';
        }

      }

      // =========================
      // OTHERWISE FETCH RECENT
      // =========================

      else {

        final summariesSnapshot =

            await FirebaseFirestore
                .instance
                .collection('users')
                .doc(user.uid)
                .collection(
                    'daily_summaries')
                .orderBy(
                  'updatedAt',
                  descending: true,
                )
                .limit(7)
                .get();

        for (var doc
            in summariesSnapshot.docs) {

          final data =
              doc.data();

          emotionalContext += '''

Date:
${data['date'] ?? ''}

Mood:
${data['mood'] ?? ''}

Emotional Stability:
${data['emotionalStability'] ?? ''}

Stress Level:
${data['stressLevel'] ?? ''}

Productivity:
${data['productivity'] ?? ''}

Burnout Risk:
${data['burnoutRisk'] ?? ''}

Insight:
${data['insight'] ?? ''}

Daily Summary:
${data['combinedText'] ?? ''}

--------------------
''';
        }
      }

      // =========================
      // AI PROMPT
      // =========================

      final prompt = '''

You are MindTrack AI.

You are a highly intelligent emotional wellness AI assistant and emotional coach.

You help users understand:
- emotional patterns
- burnout
- stress
- productivity fluctuations
- recovery patterns
- emotional wellbeing

You must:
- sound emotionally intelligent
- sound human
- sound warm
- avoid robotic replies
- avoid overly long replies
- give practical emotional guidance
- give emotional insight
- sound premium and supportive

USER PROFILE:

Name:
${userData['name'] ?? ''}

Lifestyle:
${userData['lifestyle'] ?? ''}

Goals:
${userData['goals'] ?? ''}

USER EMOTIONAL HISTORY:
$emotionalContext

USER MESSAGE:
$userMessage

Respond naturally as MindTrack AI.
''';

      // =========================
      // GEMINI REQUEST
      // =========================

      final response =
          await http.post(

        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=$apiKey',
        ),

        headers: {

          'Content-Type':
              'application/json',
        },

        body: jsonEncode({

          "contents": [

            {

              "parts": [

                {
                  "text": prompt,
                }
              ]
            }
          ]
        }),
      );

      final data =
          jsonDecode(response.body);

      // =========================
      // SAFETY CHECK
      // =========================

      if (data['candidates'] ==
              null ||
          data['candidates']
              .isEmpty) {

        return
            'MindTrack AI could not generate a response.';
      }

      final aiResponse =

          data['candidates'][0]
                  ['content']['parts'][0]
              ['text'];

      return aiResponse ??
          'No response generated.';

    } catch (e) {

      return
          'MindTrack AI is temporarily unavailable.';
    }
  }

  // =========================
  // DAILY INSIGHT
  // =========================

  Future<String>
      generateDailyInsight()
  async {

    try {

      return await askAI(
        '''
Give a short emotional wellness insight based on the user's recent emotional patterns.

Keep it:
- short
- emotionally intelligent
- motivating
- practical
- human sounding
''',
      );

    } catch (e) {

      return
          'Take care of your emotional wellness today.';
    }
  }
}