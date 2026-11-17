import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // =========================
  // SAVE USER PROFILE
  // =========================

  Future<void> saveUserProfile({

    required String uid,

    required String name,

    required String age,

    required String gender,

    required String email,

  }) async {

    await firestore

        .collection('users')
        .doc(uid)

        .set({

      'name': name,

      'age': age,

      'gender': gender,

      'email': email,

    }, SetOptions(merge: true));
  }

  // =========================
  // SAVE USER GOALS
  // =========================

  Future<void> saveUserGoals({

    required String uid,

    required List<String> goals,

  }) async {

    await firestore

        .collection('users')
        .doc(uid)

        .set({

      'goals': goals,

    }, SetOptions(merge: true));
  }

  // =========================
  // SAVE LIFESTYLE DATA
  // =========================

  Future<void> saveLifestyleData({

    required String uid,

    required String lifestyle,

    required String sleepGoal,

    required String workoutHabit,

    required String dailyProductivityGoal,

  }) async {

    await firestore

        .collection('users')
        .doc(uid)

        .set({

      'lifestyle':
          lifestyle,

      'sleepGoal':
          sleepGoal,

      'workoutHabit':
          workoutHabit,

      'dailyProductivityGoal':
          dailyProductivityGoal,

    }, SetOptions(merge: true));
  }

  // =========================
  // SAVE JOURNAL
  // =========================

  Future<void> saveJournal({

    required String uid,

    required String text,

    required String mood,

    required String emotionalStability,

    required String stressLevel,

    required String productivity,

    required String burnoutRisk,

    required String insight,

    String? customDayId,

  }) async {

    final now = DateTime.now();

    final todayId = customDayId ??

        '${now.year}-${now.month}-${now.day}';

    // =========================
    // SAVE RAW JOURNAL
    // =========================

    await firestore

        .collection('users')
        .doc(uid)
        .collection('journals')

        .add({

      'text': text,

      'journal': text,

      'mood': mood,

      'emotionalStability':
          emotionalStability,

      'stressLevel': stressLevel,

      'productivity': productivity,

      'burnoutRisk': burnoutRisk,

      'insight': insight,

      'createdAt':
          FieldValue.serverTimestamp(),

      'dayId': todayId,
    });

    // =========================
    // FETCH ALL JOURNALS
    // =========================

    final snapshot =

        await firestore

            .collection('users')
            .doc(uid)
            .collection('journals')

            .where(
              'dayId',
              isEqualTo: todayId,
            )

            .get();

    String combinedText = '';

    for (var doc
        in snapshot.docs) {

      final data =
          doc.data();

      combinedText +=
          '${data['journal'] ?? data['text'] ?? ''}\n\n';
    }

    // =========================
    // SAVE DAILY SUMMARY
    // =========================

    await saveDailySummary(

      uid: uid,

      dayId: todayId,

      combinedText:
          combinedText.trim(),

      mood: mood,

      emotionalStability:
          emotionalStability,

      stressLevel:
          stressLevel,

      productivity:
          productivity,

      burnoutRisk:
          burnoutRisk,

      insight:
          insight,
    );
  }

  // =========================
  // SAVE DAILY SUMMARY
  // =========================

  Future<void> saveDailySummary({

    required String uid,

    required String dayId,

    required String combinedText,

    required String mood,

    required String emotionalStability,

    required String stressLevel,

    required String productivity,

    required String burnoutRisk,

    required String insight,

  }) async {

    await firestore

        .collection('users')
        .doc(uid)
        .collection('daily_summaries')
        .doc(dayId)

        .set({

      'date': dayId,

      'combinedText':
          combinedText,

      'mood': mood,

      'emotionalStability':
          emotionalStability,

      'stressLevel':
          stressLevel,

      'productivity':
          productivity,

      'burnoutRisk':
          burnoutRisk,

      'insight': insight,

      'updatedAt':
          FieldValue.serverTimestamp(),

    }, SetOptions(merge: true));
  }

  // =========================
  // UPDATE JOURNAL
  // =========================

  Future<void> updateJournal({

    required String uid,

    required String journalId,

    required String newText,

  }) async {

    await firestore

        .collection('users')
        .doc(uid)
        .collection('journals')
        .doc(journalId)

        .update({

      'text': newText,

      'journal': newText,
    });
  }

  // =========================
  // DELETE JOURNAL
  // =========================

  Future<void> deleteJournal({

    required String uid,

    required String journalId,

  }) async {

    await firestore

        .collection('users')
        .doc(uid)
        .collection('journals')
        .doc(journalId)

        .delete();
  }

  // =========================
  // GET DAY JOURNALS
  // =========================

  Future<QuerySnapshot>
      getDayJournals({

    required String uid,

    required String dayId,

  }) async {

    return await firestore

        .collection('users')
        .doc(uid)
        .collection('journals')

        .where(
          'dayId',
          isEqualTo: dayId,
        )

        .get();
  }

  // =========================
  // GET DAILY SUMMARY
  // =========================

  Future<DocumentSnapshot>
      getDailySummary({

    required String uid,

    required String dayId,

  }) async {

    return await firestore

        .collection('users')
        .doc(uid)
        .collection('daily_summaries')
        .doc(dayId)

        .get();
  }
}