// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swrv/services/apirequest.dart';
import 'package:swrv/state/userstate.dart';
import 'package:swrv/utils/alerts.dart';

Future<User?> signInWithFacebook() async {
  final LoginResult loginResult = await FacebookAuth.instance.login();

  if (loginResult.accessToken != null) {
    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);

    return userCredential.user;
  }
  return null;
}

//login state start here
final loginStatus =
    ChangeNotifierProvider.autoDispose<LoginState>((ref) => LoginState());

class LoginState extends ChangeNotifier {
  bool isChecked = false;
  bool isPassword = false;

  CusApiReq apiReq = CusApiReq();

  UserState userState = UserState();

  void toggleCheck() {
    isChecked = !isChecked;
    notifyListeners();
  }

  void togglePassword() {
    isPassword = !isPassword;
    notifyListeners();
  }

  Future<bool> login(
      BuildContext context, String email, String password) async {
    if (email == "") {
      erroralert(
        context,
        "Empty Field",
        "Please fill the email",
      );
    } else if (password == "") {
      erroralert(context, "Empty Field", "Please fill the password");
    } else {
      final req = {"email": email, "password": password};

      List data = await apiReq.postApi(jsonEncode(req), path: "/api/login");

      if (data[0] == false) {
        erroralert(
          context,
          "Error",
          data[1].toString(),
        );
      } else if (data[0]["status"] == false) {
        erroralert(
          context,
          "Error",
          data[0]["message"],
        );
      } else {
        final isuserset = await userState.setNewUserData(
            context, data[0]["data"]["id"].toString());

        if (isuserset) {
          if (isChecked) {
            await setLogPref();
          }
          notifyListeners();
          return true;
        } else {
          erroralert(context, "Error", "unable to set new user");
        }
      }
    }
    notifyListeners();
    return false;
  }

  Future<bool> socialLogin(
      BuildContext context, String email, String password) async {
    final req = {"email": email, "password": password};

    List data = await apiReq.postApi(jsonEncode(req), path: "/api/login");

    if (data[0] == false) {
      erroralert(
        context,
        "Error",
        data[1].toString(),
      );
    } else if (data[0]["status"] == false) {
      erroralert(
        context,
        "Error",
        data[0]["message"],
      );
    } else {
      final isuserset = await userState.setNewUserData(
          context, data[0]["data"]["id"].toString());

      if (isuserset) {
        await setLogPref();
        notifyListeners();
        return true;
      } else {
        erroralert(context, "Error", "unable to set new user");
      }
    }

    notifyListeners();
    return false;
  }

  Future<bool> forgetPass(BuildContext context, String email) async {
    final req = {"user": email};

    List data = await apiReq.postApi(jsonEncode(req),
        path: "/api/send-forgot-password");
    if (data[0] == false) {
      erroralert(
        context,
        "Error",
        data[1].toString(),
      );
    } else if (data[0]["status"] == false) {
      erroralert(
        context,
        "Error",
        data[0]["message"],
      );
    } else {
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<void> setLogPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("login", true);
    notifyListeners();
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
}
