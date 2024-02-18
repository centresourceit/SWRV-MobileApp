import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final socialLoginStatus = ChangeNotifierProvider.autoDispose<SocialLoginState>(
    (ref) => SocialLoginState());

class SocialLoginState extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<User?> signInWithGoogle() async {
    // Start the Google Sign-In process
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // Get the authentication token from the GoogleSignInAccount object
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      // Create a credential object using the authentication token
      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Return the user object
      return userCredential.user;
    }

    // Return null if the user cancelled the sign-in process
    return null;
  }

  Future<void> setLogToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("loginToken", token);
  }

  Future<dynamic> getLoginToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("loginToken");
  }

  Future<void> setLogPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("login", true);
  }

  Future<bool> isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLogin = prefs.getBool("login");
    if (isLogin != null) {
      if (isLogin) {
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
    return false;
  }

  Future<void> socialLogout() async {
    await googleSignIn.signOut();
  }
}
