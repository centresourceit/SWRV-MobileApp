// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:swrv/utils/utilsmethods.dart';
import 'package:swrv/view/home/home.dart';

import '../services/notification.dart';
import '../state/loginstate.dart';
import '../state/socialloginstate.dart';
import '../widgets/alerts.dart';
import 'register.dart';

class Login extends HookConsumerWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey =
        useMemoized(() => GlobalKey<FormState>());
    ValueNotifier<bool> isLoading = useState(true);
    TextEditingController email = useTextEditingController();
    TextEditingController password = useTextEditingController();
    TextEditingController resetpass = useTextEditingController();

    final loginStateW = ref.watch(loginStatus);
    final socialLoginStateW = ref.watch(socialLoginStatus);

    double width = MediaQuery.of(context).size.width;
    final notificationsServicesW = ref.watch(notificationsServices);

    void init() async {
      await notificationsServicesW.initialiseNotifications();

      // EasyGeofencing.startGeofenceService(
      //   pointedLatitude: "20.417221",
      //   pointedLongitude: "72.838639",
      //   radiusMeter: "250.0",
      //   eventPeriodInSeconds: 5,
      // );
      // EasyGeofencing.startGeofenceService(
      //   pointedLatitude: "34.2165157",
      //   pointedLongitude: "71.9437819",
      //   radiusMeter: "250.0",
      //   eventPeriodInSeconds: 5,
      // );

      // StreamSubscription<GeofenceStatus> geofenceStatusStream =
      //     EasyGeofencing.getGeofenceStream()!.listen((GeofenceStatus status) {

      // });

      if (await socialLoginStateW.getLoginToken() != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
      bool isLogin = await loginStateW.isLogin();
      if (isLogin) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
      isLoading.value = false;
    }

    useEffect(() {
      init();
      return;
    }, []);

    return WillPopScope(
      onWillPop: () async {
        exitAlert(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff3f4f6),
        body: SafeArea(
          child: isLoading.value
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : SingleChildScrollView(
                  child: SizedBox(
                    width: width,
                    child: Center(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Transform.translate(
                              offset: const Offset(0, 80),
                              child: Center(
                                child: SizedBox(
                                  height: 150,
                                  child: FittedBox(
                                    child: Text(
                                      "WELCOME",
                                      style: GoogleFonts.londrinaShadow(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: width / 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(25),
                              padding: const EdgeInsets.all(35),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10)
                                ],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        "Log in",
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        "Email",
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == "" ||
                                                value == null ||
                                                value.isEmpty) {
                                              return "This field can't be empty";
                                            } else if (!validateEmail(value)) {
                                              return "Enter a valid email";
                                            }
                                            return null;
                                          },
                                          controller: email,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: const Color(0xfff3f4f6),
                                            hintText: "example@email.com",
                                            hintStyle: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.5)),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 16),
                                      child: Text(
                                        "Password",
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == "" ||
                                                value == null ||
                                                value.isEmpty) {
                                              return "Fill the password";
                                            }
                                            return null;
                                          },
                                          controller: password,
                                          obscureText: loginStateW.isPassword
                                              ? false
                                              : true,
                                          decoration: InputDecoration(
                                            suffixIcon: GestureDetector(
                                              onTap: () {
                                                loginStateW.togglePassword();
                                              },
                                              child: Icon(
                                                loginStateW.isPassword
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xfff3f4f6),
                                            hintText: "8 characters",
                                            hintStyle: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.5)),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize:
                                                    const Size.fromHeight(40),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                elevation: 0,
                                                backgroundColor: Colors.pink,
                                              ),
                                              onPressed: () async {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  isLoading.value = true;
                                                  final res =
                                                      await loginStateW.login(
                                                    context,
                                                    email.text,
                                                    password.text,
                                                  );
                                                  if (res) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const HomePage(),
                                                      ),
                                                    );
                                                  }
                                                  isLoading.value = false;
                                                }
                                              },
                                              child: const Text(
                                                "Login",
                                                textAlign: TextAlign.center,
                                                textScaleFactor: 1,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          // InkWell(
                                          //   onTap: () async {
                                          //     comingalert(context);
                                          //   },
                                          //   child: SizedBox(
                                          //     width: 40,
                                          //     height: 40,
                                          //     child: Image.asset(
                                          //         "assets/images/facebook.png"),
                                          //   ),
                                          // ),
                                          // const SizedBox(
                                          //   width: 10,
                                          // ),
                                          InkWell(
                                            onTap: () async {
                                              try {
                                                final data =
                                                    await socialLoginStateW
                                                        .signInWithGoogle();
                                                var pass =
                                                    "${data!.displayName.toString().trim().split(' ').join('').toLowerCase().trim()}SWRV123@#";
                                                final res = await loginStateW
                                                    .socialLogin(
                                                  context,
                                                  data.email!,
                                                  pass,
                                                );
                                                if (res) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const HomePage(),
                                                    ),
                                                  );
                                                } else {
                                                  socialLoginStateW
                                                      .socialLogout();
                                                }
                                              } catch (e) {
                                                log(e.toString());
                                              }
                                            },
                                            child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Image.asset(
                                                  "assets/images/google.png"),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Checkbox(
                                            value: loginStateW.isChecked,
                                            onChanged: (value) {
                                              loginStateW.toggleCheck();
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            loginStateW.toggleCheck();
                                          },
                                          child: const Text(
                                            'Keep me Logged in.',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "CAN'T LOGIN",
                                          textScaleFactor: 1,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            resetPassAlert(
                                              context,
                                              resetpass,
                                              ref,
                                            );
                                          },
                                          child: const Text(
                                            "RESTORE PASSWORD",
                                            textScaleFactor: 1,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 5),
                                      child: Text("Don't have an account?"),
                                    ),
                                    Container(
                                      width: 145,
                                      padding: const EdgeInsets.only(),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          backgroundColor:
                                              const Color(0xff03125e),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Register(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Join",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(),
                                        ),
                                      ),
                                    ),
                                    // ElevatedButton(
                                    //     onPressed: () {
                                    //       ref
                                    //           .watch(notificationsServices)
                                    //           .sendNotification(
                                    //             "title",
                                    //             "this is body",
                                    //           );
                                    //     },
                                    //     child: const Text("send")),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
