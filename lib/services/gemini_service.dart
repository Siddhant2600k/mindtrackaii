import 'dart:convert';

import 'package:http/http.dart'
    as http;

class GeminiService {

  // =========================
  // GEMINI API KEY
  // =========================

  final String apiKey =
      'AIzaSyBDurj6w-_QvHlHb0yF7IHkoOXZ9gL045Q';

  // =========================
  // MODEL URL
  // =========================

  final String modelUrl =

'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent';

  // =========================
  // ANALYZE JOURNAL
  // =========================

  Future<Map<String, dynamic>>
      analyzeJournal(
    String text,
  ) async {

    try {

      final response =
          await http.post(

        Uri.parse(
          '$modelUrl?key=$apiKey',
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

                  "text":

'''
Analyze this combined daily journal.

Return ONLY VALID RAW JSON.

DO NOT add markdown.
DO NOT add explanation.
DO NOT add backticks.

JSON FORMAT:

{
  "mood": "",
  "emotionalStability": "",
  "stressLevel": "",
  "productivity": "",
  "burnoutRisk": "",
  "insight": ""
}

RULES:

- emotionalStability = 20-95
- burnoutRisk = 5-90
- insight must be short
- mood must be max 3 words

Journal:
$text
'''
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

        return _fallbackResult();
      }

      String rawText =

          data['candidates'][0]
                  ['content']['parts'][0]
              ['text'];

      // =========================
      // CLEAN RESPONSE
      // =========================

      rawText = rawText

          .replaceAll(
              '```json', '')

          .replaceAll(
              '```', '')

          .trim();

      // =========================
      // EXTRACT JSON ONLY
      // =========================

      final start =
          rawText.indexOf('{');

      final end =
          rawText.lastIndexOf('}');

      if (start == -1 ||
          end == -1) {

        return _fallbackResult();
      }

      final jsonString =
          rawText.substring(
        start,
        end + 1,
      );

      final result =
          jsonDecode(jsonString);

      // =========================
      // SAFE FIELDS
      // =========================

      final mood =
          result['mood']
                  ?.toString()
                  .trim() ??
              'Neutral';

      final stress =
          result['stressLevel']
                  ?.toString()
                  .trim() ??
              'Medium';

      final productivity =
          result['productivity']
                  ?.toString()
                  .trim() ??
              'Medium';

      final insight =
          result['insight']
                  ?.toString()
                  .trim() ??
              'Keep taking care of yourself.';

      int emotional =
          int.tryParse(

                result[
                        'emotionalStability']
                    .toString(),
              ) ??
              50;

      emotional =
          emotional.clamp(
              20,
              95);

      int burnout =
          int.tryParse(

                result[
                        'burnoutRisk']
                    .toString(),
              ) ??
              50;

      burnout =
          burnout.clamp(
              5,
              90);

      return {

        "mood": mood,

        "emotionalStability":
            emotional.toString(),

        "stressLevel":
            stress,

        "productivity":
            productivity,

        "burnoutRisk":
            burnout.toString(),

        "insight":
            insight,
      };

    } catch (e) {

      return _fallbackResult();
    }
  }

  // =========================
  // FALLBACK
  // =========================

  Map<String, dynamic>
      _fallbackResult() {

    return {

      "mood": "Neutral",

      "emotionalStability":
          "50",

      "stressLevel":
          "Medium",

      "productivity":
          "Medium",

      "burnoutRisk":
          "50",

      "insight":
          "Take care of your emotional wellness.",
    };
  }

  // =========================
  // SIMPLE AI RESPONSE
  // =========================

  Future<String>
      generateSimpleResponse(
    String prompt,
  ) async {

    try {

      final response =
          await http.post(

        Uri.parse(
          '$modelUrl?key=$apiKey',
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

      if (data['candidates'] ==
              null ||
          data['candidates']
              .isEmpty) {

        return
            'No AI response generated.';
      }

      return

          data['candidates'][0]
                  ['content']['parts'][0]
              ['text'] ??

              'No response generated.';

    } catch (e) {

      return
          'AI coach error.';
    }
  }
}