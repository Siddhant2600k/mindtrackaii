import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  // =========================
  // EMAIL SIGNUP
  // =========================

  Future<User?> signUp({

    required String email,

    required String password,

  }) async {

    try {

      final credential =

          await auth
              .createUserWithEmailAndPassword(

        email: email,

        password: password,
      );

      final user =
          credential.user;

      // SAVE USER

      if (user != null) {

        await FirebaseFirestore
            .instance

            .collection('users')

            .doc(user.uid)

            .set({

          'uid': user.uid,

          'email': email,

          'name': '',

          'photo': '',

          'createdAt':
              FieldValue.serverTimestamp(),

        }, SetOptions(merge: true));
      }

      return user;

    } catch (e) {

      debugPrint(
        'Signup Error: $e',
      );

      return null;
    }
  }

  // =========================
  // EMAIL LOGIN
  // =========================

  Future<User?> login({

    required String email,

    required String password,

  }) async {

    try {

      final credential =

          await auth
              .signInWithEmailAndPassword(

        email: email,

        password: password,
      );

      return credential.user;

    } catch (e) {

      debugPrint(
        'Login Error: $e',
      );

      return null;
    }
  }

  // =========================
  // GOOGLE SIGN IN
  // =========================

  Future<User?> signInWithGoogle()
      async {

    try {

      final GoogleSignInAccount?
          googleUser =

          await GoogleSignIn()
              .signIn();

      if (googleUser == null) {

        return null;
      }

      final GoogleSignInAuthentication
          googleAuth =

          await googleUser
              .authentication;

      final credential =
          GoogleAuthProvider.credential(

        accessToken:
            googleAuth.accessToken,

        idToken:
            googleAuth.idToken,
      );

      final userCredential =

          await auth.signInWithCredential(
        credential,
      );

      final user =
          userCredential.user;

      // =========================
      // SAVE USER TO FIRESTORE
      // =========================

      if (user != null) {

        await FirebaseFirestore
            .instance

            .collection('users')

            .doc(user.uid)

            .set({

          'uid': user.uid,

          'name':
              user.displayName ?? '',

          'email':
              user.email ?? '',

          'photo':
              user.photoURL ?? '',

          'createdAt':
              FieldValue.serverTimestamp(),

        }, SetOptions(merge: true));
      }

      return user;

    } catch (e) {

      debugPrint(
        'Google Sign In Error: $e',
      );

      return null;
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {

    try {

      await GoogleSignIn()
          .signOut();

      await auth.signOut();

    } catch (e) {

      debugPrint(
        'Logout Error: $e',
      );
    }
  }
}