import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/state/referstate.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/widgets/buttons.dart';

import '../../services/apirequest.dart';
import '../../state/userstate.dart';
import '../../widgets/componets.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';

class InvitePage extends HookConsumerWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());
    final GlobalKey<FormState> formKey =
        useMemoized(() => GlobalKey<FormState>());

    TextEditingController name = useTextEditingController();
    TextEditingController email = useTextEditingController();
    TextEditingController contact = useTextEditingController();
    final userStateW = ref.watch(userState);

    final width = MediaQuery.of(context).size.width;
    final referStateW = ref.watch(referStatus);

    ValueNotifier<List> userdata = useState([
      {
        "img": "assets/images/1.jpg",
        "name": "Rajesh",
        "email": "rajesh@gmail.com",
      },
      {
        "img": "assets/images/2.jpg",
        "name": "Rakesh",
        "email": "rakesh@gmail.com",
      },
      {
        "img": "assets/images/3.jpg",
        "name": "Rohit",
        "email": "rohit@gmail.com",
      },
      {
        "img": "assets/images/4.jpg",
        "name": "Soniya",
        "email": "soniya@gmail.com",
      },
      {
        "img": "assets/images/5.jpg",
        "name": "Sujal",
        "email": "sujal@gmail.com",
      },
      {
        "img": "assets/images/6.jpg",
        "name": "Sonali",
        "email": "sonali@gmail.com",
      },
    ]);

    ValueNotifier<List> referelStatus = useState<List>([]);

    void init() async {
      CusApiReq apiReq = CusApiReq();
      String id = await userStateW.getUserId();
      List refferres =
          await apiReq.postApi(jsonEncode({}), path: "/api/user-referrals/$id");
      if (refferres[0]["status"]) {
        referelStatus.value = refferres[0]["data"][0]["refferrals"];
      }
    }

    useEffect(() {
      init();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: backgroundC,
      key: scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: CusDrawer(
        scaffoldKey: scaffoldKey,
      ),
      bottomNavigationBar: BotttomBar(
        scaffoldKey: scaffoldKey,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Header(),
                Container(
                  width: width,
                  margin: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: shadowC, blurRadius: 5, offset: Offset(0, 6))
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/cashgirl.png",
                  ),
                ),
                Container(
                  width: width,
                  margin: const EdgeInsets.all(25),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    color: whiteC,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: shadowC, blurRadius: 5, offset: Offset(0, 6))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Refer an influencer or brand",
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.openSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: blackC),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "Name",
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.85),
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
                            controller: name,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "") {
                                return 'Please enter the name.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              referStateW.setName(value);
                            },
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xfff3f4f6),
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
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "Email",
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.85),
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
                            controller: email,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "") {
                                return 'Please enter the email.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              referStateW.setEmail(value);
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xfff3f4f6),
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
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "Contact number",
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.85),
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
                            controller: contact,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "") {
                                return 'Please enter the contact number.';
                              } else if (value.length != 10) {
                                return 'Please enter 10 digit contact number.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              referStateW.setContact(value);
                            },
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xfff3f4f6),
                              counterText: "",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CusBtn(
                        btnColor: const Color(0xff01FFF4),
                        btnText: "Invite",
                        textSize: 18,
                        btnFunction: () async {
                          if (formKey.currentState!.validate()) {
                            await referStateW.sendRefer(context);
                            name.clear();
                            email.clear();
                            contact.clear();
                          }
                        },
                        textColor: secondaryC,
                        elevation: 0,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: width,
                  margin: const EdgeInsets.all(25),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    color: whiteC,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: shadowC, blurRadius: 5, offset: Offset(0, 6))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Referral status",
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: secondaryC,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (referelStatus.value.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: backgroundC,
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    SizedBox(
                                      width: 140,
                                      child: Text(
                                        "Name",
                                        textScaleFactor: 1,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: blackC,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 240,
                                      child: Text(
                                        "Email",
                                        textScaleFactor: 1,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: blackC,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        "Contact",
                                        textScaleFactor: 1,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: blackC,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        "Status",
                                        textScaleFactor: 1,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: blackC,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              for (int i = 0;
                                  i < referelStatus.value.length;
                                  i++) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CachedNetworkImage(
                                            imageUrl: referelStatus.value[i]
                                                ["pic"],
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              "assets/images/user.png",
                                              fit: BoxFit.cover,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          referelStatus.value[i]["userName"]
                                              .split("@")[0],
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: blackC,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 240,
                                        child: Text(
                                          referelStatus.value[i]["email"],
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: blackC,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          referelStatus.value[i]["contact"],
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: blackC,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          referelStatus.value[i]["status"]
                                              ["isVerified"],
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: blackC,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          "Your have not been referred by anyone yet",
                          textScaleFactor: 1,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
