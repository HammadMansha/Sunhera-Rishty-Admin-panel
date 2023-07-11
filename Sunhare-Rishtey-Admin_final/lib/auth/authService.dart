import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sunhare_rishtey_new_admin/Screens/loadingScreen.dart';
import 'loginScreen.dart';

class AuthService {
  checkAuth() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LoadingScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Future<bool> signinWithEmail(String email, String password) {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then(
      (value) {
        return true;
      },
    ).catchError(
      (e) {
        Fluttertoast.showToast(msg: 'Something went wrong');
        return false;
      },
    );
  }
}
