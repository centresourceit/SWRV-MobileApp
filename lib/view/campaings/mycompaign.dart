// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swrv/utils/utilsmethods.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/widgets/alerts.dart';
import 'package:swrv/widgets/buttons.dart';
import 'package:swrv/widgets/componets.dart';

import '../../services/apirequest.dart';
import '../../state/userstate.dart';
import '../../utils/alerts.dart';
import '../home/home.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';
import 'campaigninfo.dart';
import 'createchamp/selectecategory.dart';

class MyCampaings extends HookConsumerWidget {
  const MyCampaings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());
    final width = MediaQuery.of(context).size.width;
    final userStateW = ref.watch(userState);
    ValueNotifier<bool> isLoading = useState(true);
    ValueNotifier<bool> isBrand = useState(false);
    CusApiReq apiReq = CusApiReq();

    ValueNotifier<List> champ = useState([]);

    void init() async {
      final userid = await userStateW.getUserId();
      final req = {"id": userid};
      dynamic data =
          await apiReq.postApi(jsonEncode(req), path: "/api/get-my-campaigns");
      champ.value = data[0]["data"]["campaigns"];
      isBrand.value = await userStateW.isBrand();
      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);

    List platformUrls(List plt) {
      List data = [];
      for (int j = 0; j < plt.length; j++) {
        data.add(plt[j]["platformLogoUrl"]);
      }
      return data;
    }

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isBrand.value
          ? Transform.translate(
              offset: const Offset(0, -20),
              child: FloatingActionButton.extended(
                tooltip: "Create a new campaign",
                onPressed: () async {
                  final res = await userStateW.isProfileCompleted();

                  if (res) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateCampaignsPage(),
                      ),
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                      (route) => false,
                    );
                    erroralert(
                      context,
                      "Uncomplete Profile",
                      "Please Complete your profile first",
                    );
                  }
                },
                backgroundColor: primaryC,
                icon: const Icon(Icons.add),
                label: const Text(
                  "Create Campaign",
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : null,
      body: isLoading.value
          ? const Padding(
              padding: EdgeInsets.all(
                20,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Header(),
                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 20),
                      child: Text(
                        "My campaign",
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: blackC),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 10),
                      child: Text(
                        "Here you can manage all the\ncampaigns that you are participating in.",
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackC),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (isBrand.value) ...[
                      if (champ.value.isEmpty) ...[
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 20),
                            width: width,
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: whiteC,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: shadowC,
                                  blurRadius: 5,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const WarningAlart(
                              message: "You have no campaign right now",
                            )),
                      ] else ...[
                        Container(
                          width: width,
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                  color: shadowC,
                                  blurRadius: 5,
                                  offset: Offset(0, 6))
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    for (int i = 0;
                                        i < champ.value.length;
                                        i++) ...[
                                      HomeCard(
                                        imgUrl: champ.value[i]["brand"]["logo"],
                                        title: champ.value[i]["name"],
                                        champname: champ.value[i]
                                            ["campaignName"],
                                        btnColor: const Color(0xfffbc98e),
                                        btnText: "View",
                                        btnFunction: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChampignInfo(
                                                id: champ.value[i]["id"],
                                              ),
                                            ),
                                          );
                                        },
                                        website:
                                            "Min Eligible Rating : ${champ.value[i]["minEligibleRating"].toString().split('.')[0]}",
                                        category: champ.value[i]
                                            ["campaignTypeId"],
                                        isHeart: false,
                                        amount: champ.value[i]["totalBudget"]
                                            .toString()
                                            .split('.')[0],
                                        // currency:
                                        //     "${champ.value[i]["currency"]["code"]}",
                                        currency: "USD",
                                        platforms: platformUrls(
                                            champ.value[i]["platforms"]),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      const UserCampaigns(),
                      const UserInviteRequest()
                    ],
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class UserInviteRequest extends HookConsumerWidget {
  const UserInviteRequest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateW = ref.watch(userState);
    ValueNotifier<bool> isLoading = useState(true);
    CusApiReq apiReq = CusApiReq();
    ValueNotifier<List> campRequest = useState<List>([]);

    void init() async {
      final req = {
        "search": {
          "status": "1",
          "influencer": await userStateW.getUserId(),
          "toUser": await userStateW.getUserId()
        },
      };

      dynamic data =
          await apiReq.postApi2(jsonEncode(req), path: "/api/search-invite");
      campRequest.value = data[0]["data"];
      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);
    final width = MediaQuery.of(context).size.width;
    return isLoading.value
        ? const Padding(
            padding: EdgeInsets.all(
              20,
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            width: width,
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: whiteC,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: shadowC,
                  blurRadius: 5,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (campRequest.value.isEmpty) ...[
                    const WarningAlart(
                      message: "You have no campaign request pending",
                    )
                  ] else ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              for (int i = 0;
                                  i < campRequest.value.length;
                                  i++) ...[
                                Container(
                                  width: 280,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: whiteC,
                                    boxShadow: [
                                      BoxShadow(
                                          color: blackC.withOpacity(0.2),
                                          blurRadius: 5)
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              width: 60,
                                              height: 60,
                                              child: CachedNetworkImage(
                                                imageUrl: campRequest.value[i]
                                                    ["brand"]["logo"],
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress,
                                                  ),
                                                ),
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
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                longtext(
                                                    campRequest.value[i]
                                                            ["brand"]["name"]
                                                        .toString(),
                                                    18),
                                                textScaleFactor: 1,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.openSans(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: blackC,
                                                ),
                                              ),
                                              Text(
                                                longtext(
                                                    campRequest.value[i]
                                                        ["influencer"]["email"],
                                                    20),
                                                textScaleFactor: 1,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: blackC,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      const Divider(),
                                      Text(
                                        "Message:",
                                        textScaleFactor: 1,
                                        style: GoogleFonts.openSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: blackC),
                                      ),
                                      Text(
                                        campRequest.value[i]["inviteMessage"],
                                        textScaleFactor: 1,
                                        style: GoogleFonts.openSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: blackC),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 125,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xff60D560)),
                                              onPressed: () async {
                                                final req = {
                                                  "id": campRequest.value[i]
                                                      ["id"],
                                                  "status": "3"
                                                };

                                                await apiReq.postApi2(
                                                    jsonEncode(req),
                                                    path: "/api/update-invite");
                                                init();
                                              },
                                              child: Text(
                                                "Accept",
                                                textScaleFactor: 1,
                                                style: GoogleFonts.openSans(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: 125,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xfff9a2a2),
                                              ),
                                              onPressed: () async {
                                                final req = {
                                                  "id": campRequest.value[i]
                                                      ["id"],
                                                  "status": "5",
                                                  "rejectReason": ""
                                                };

                                                await apiReq.postApi2(
                                                    jsonEncode(req),
                                                    path: "/api/update-invite");
                                                init();
                                              },
                                              child: Text(
                                                "Reject",
                                                textScaleFactor: 1,
                                                style: GoogleFonts.openSans(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 260,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xff01FFF4)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChampignInfo(
                                                  id: campRequest.value[i]
                                                      ["campaignId"],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "View",
                                            textScaleFactor: 1,
                                            style: GoogleFonts.openSans(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
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
                      ],
                    ),
                  ]
                ],
              ),
            ),
          );
  }
}

class UserCampaigns extends HookConsumerWidget {
  const UserCampaigns({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final userStateW = ref.watch(userState);
    ValueNotifier<bool> isLoading = useState(true);
    CusApiReq apiReq = CusApiReq();
    ValueNotifier<List> userCamp = useState([]);
    ValueNotifier<bool> isActive = useState<bool>(true);

    void init() async {
      isLoading.value = true;
      final req = {
        "search": {
          "status": "3",
          "influencer": await userStateW.getUserId(),
        }
      };
      dynamic data =
          await apiReq.postApi2(jsonEncode(req), path: "/api/search-invite");

      if (isActive.value) {
        List<dynamic> filteredData = data[0]["data"].where((val) {
          if (val["campaign"]["endAt"] == "0") return false;
          DateTime endAt =
              DateFormat("yyyy-MM-dd HH:mm:ss").parse(val["campaign"]["endAt"]);
          return endAt.isAfter(DateTime.now());
        }).toList();
        userCamp.value = filteredData;
      } else {
        List<dynamic> filteredData = data[0]["data"].where((val) {
          if (val["campaign"]["endAt"] == "0") return false;
          DateTime endAt =
              DateFormat("yyyy-MM-dd HH:mm:ss").parse(val["campaign"]["endAt"]);
          return endAt.isBefore(DateTime.now());
        }).toList();
        userCamp.value = filteredData;
      }

      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, [isActive.value]);

    return isLoading.value
        ? const Padding(
            padding: EdgeInsets.all(
              20,
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          backgroundColor:
                              isActive.value ? const Color(0xff01fff4) : whiteC,
                        ),
                        onPressed: () {
                          isActive.value = true;
                        },
                        child: Text(
                          "Active Campaign",
                          textAlign: TextAlign.center,
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: isActive.value
                                  ? blackC
                                  : blackC.withOpacity(0.65),
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor:
                              isActive.value ? whiteC : const Color(0xff01fff4),
                        ),
                        onPressed: () {
                          isActive.value = false;
                        },
                        child: Text(
                          "Finished campaign",
                          textAlign: TextAlign.center,
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: isActive.value
                                ? blackC.withOpacity(0.65)
                                : blackC,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                width: width,
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: whiteC,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: shadowC,
                      blurRadius: 5,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (userCamp.value.isEmpty) ...[
                        const WarningAlart(
                          message: "You have no requests pending.",
                        )
                      ] else ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  for (int i = 0;
                                      i < userCamp.value.length;
                                      i++) ...[
                                    Container(
                                      width: 240,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: whiteC,
                                        boxShadow: [
                                          BoxShadow(
                                              color: blackC.withOpacity(0.2),
                                              blurRadius: 5)
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  child: SizedBox(
                                                      width: 60,
                                                      height: 60,
                                                      child: CachedNetworkImage(
                                                        imageUrl: userCamp
                                                                .value[i]
                                                            ["brand"]["logo"],
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                    downloadProgress) =>
                                                                Center(
                                                          child: CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          "assets/images/user.png",
                                                          fit: BoxFit.cover,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    longtext(
                                                      userCamp.value[i]["brand"]
                                                          ["name"],
                                                      15,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                    textScaleFactor: 1,
                                                    style: GoogleFonts.openSans(
                                                      color: blackC,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 12,
                                          ),
                                          Text(
                                            longtext(
                                                userCamp.value[i]["campaign"]
                                                    ["name"],
                                                15),
                                            textScaleFactor: 1,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: blackC,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            longtext(
                                                userCamp.value[i]["brand"]
                                                    ["email"],
                                                30),
                                            textScaleFactor: 1,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: blackC,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          CusBtn(
                                            btnColor: const Color(0xff80fff9),
                                            btnText: "View",
                                            textSize: 18,
                                            btnFunction: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChampignInfo(
                                                    id: userCamp.value[i]
                                                        ["campaign"]["id"],
                                                  ),
                                                ),
                                              );
                                            },
                                            textColor: blackC,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
