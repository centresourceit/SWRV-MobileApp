// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/state/navigation/drawer.dart';
import 'package:swrv/state/userstate.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/view/home/search.dart';
import 'package:swrv/widgets/componets.dart';
import 'package:swrv/widgets/buttons.dart';

import '../../services/apirequest.dart';
import '../../services/notification.dart';
import '../../widgets/alerts.dart';
import '../brand/brandinfo.dart';
import '../campaings/campaigninfo.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';
import '../search/usersearch.dart';
import '../user/brandinput.dart';
import '../user/influencerinput.dart';
import '../user/myaccountcopy.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key, this.isWelcomeAlert = false});
  final bool isWelcomeAlert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());

    CusApiReq apiReq = CusApiReq();

    ValueNotifier<bool> isLoading = useState(true);

    List postImg = [
      {"image": "74.jfif", "id": 74},
      {"image": "75.jfif", "id": 75},
      {"image": "76.jfif", "id": 76},
      {"image": "77.jfif", "id": 77},
      {"image": "78.jfif", "id": 78},
      {"image": "79.jfif", "id": 79},
      {"image": "80.jfif", "id": 80},
      {"image": "81.jfif", "id": 81},
      {"image": "82.jfif", "id": 82},
      {"image": "83.jfif", "id": 83},
      {"image": "84.jfif", "id": 84},
      {"image": "85.jfif", "id": 85},
      {"image": "86.jfif", "id": 86},
      {"image": "87.jfif", "id": 87},
      {"image": "88.jfif", "id": 88},
    ];

    final width = MediaQuery.of(context).size.width;
    ValueNotifier<bool> isCompleted = useState(false);

    final userStateW = ref.watch(userState);
    final drawerIndexW = ref.watch(drawerIndex);
    final bottomIndexW = ref.watch(bottomIndex);
    ValueNotifier<bool> isBrand = useState(false);
    ValueNotifier<String> userName = useState("loading..");
    ValueNotifier<List> brandList = useState<List>([]);

    final notificationsServicesW = ref.watch(notificationsServices);

    void init() async {
      final user = await userStateW.getUserData(context);

      if (jsonDecode(user)[0]["emailVerified"] == null ||
          jsonDecode(user)[0]["emailVerified"] == "") {
        cusAlertTwo(context, ref);
      }

      final branddata =
          await apiReq.postApi(jsonEncode({}), path: "/api/search-brand");
      brandList.value = branddata[0]["data"].sublist(0, 10);

      drawerIndexW.setIndex(0);
      bottomIndexW.setIndex(0);
      if (isWelcomeAlert) {
        await apiReq.sendOTP(await userStateW.getUserId());
        await Future.delayed(const Duration(milliseconds: 400));
        welcomeAlert(context, await userStateW.getUserEmail());
      }
      final username = await userStateW.getUserName();
      userName.value = username;
      isBrand.value = await userStateW.isBrand();
      isCompleted.value = await userStateW.isProfileCompleted();

      notificationsServicesW.sustotopic("alluser");
      if (isBrand.value) {
        notificationsServicesW.sustotopic("brand");
      } else {
        notificationsServicesW.sustotopic("influencer");
      }
      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);

    return WillPopScope(
      onWillPop: () async {
        exitAlert(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: backgroundC,
        key: scaffoldKey,
        drawerEnableOpenDragGesture: false,
        drawer: CusDrawer(
          scaffoldKey: scaffoldKey,
        ),
        bottomNavigationBar: BotttomBar(
          scaffoldKey: scaffoldKey,
        ),
        body: isLoading.value
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Header(),
                        if (isCompleted.value == false) ...[
                          Container(
                            width: width,
                            margin: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: primaryC,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                    color: shadowC,
                                    blurRadius: 5,
                                    offset: Offset(0, 6))
                              ],
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Please Complete Your Profile",
                                      textScaleFactor: 1,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: whiteC,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        isCompleted.value = true;
                                      },
                                      child: const FaIcon(
                                        FontAwesomeIcons.xmark,
                                        color: whiteC,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    "Your linked social media accounts are under\nverification, you'll be not notified withen 14 hours.",
                                    textScaleFactor: 1,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: whiteC,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                CusBtn(
                                  btnColor: secondaryC,
                                  btnText: "Click here to complete",
                                  textSize: 16,
                                  btnFunction: () {
                                    if (isBrand.value) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: ((context) =>
                                              const BrandInput()),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: ((context) =>
                                              const InfluencerInput()),
                                        ),
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 20,
                        ),
                        const FittedBox(
                          child: Text(
                            "Welcome to SWRV",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: secondaryC,
                                fontSize: 32,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                        const Text(
                          "Reach the next billion",
                          textScaleFactor: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: secondaryC,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                        if (isBrand.value) ...[
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 25),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                  height: 200.0,
                                  autoPlay: true,
                                  viewportFraction: 0.5,
                                  enlargeCenterPage: true),
                              items: postImg.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) =>
                                                MyAccountCopy(
                                                  id: i["id"].toString(),
                                                  isSendMsg: false,
                                                )),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: const BoxDecoration(
                                            color: Colors.amber,
                                          ),
                                          child: Image.asset(
                                            "assets/images/inf/${i["image"]}",
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ] else ...[
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 25),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 200.0,
                                autoPlay: true,
                                autoPlayInterval:
                                    const Duration(milliseconds: 3000),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 3000),
                                viewportFraction: 0.5,
                                enlargeCenterPage: true,
                              ),
                              items: brandList.value.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BrandInfo(
                                              id: i["brandId"].toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: const BoxDecoration(
                                              color: Colors.amber),
                                          child: CachedNetworkImage(
                                            imageUrl: i["logo"],
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              "assets/images/user.png",
                                              fit: BoxFit.fill,
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        if (isBrand.value) ...[
                          const AdvanceInfSearch(
                            isTextSearch: false,
                          ),
                          const UserList(),
                          const SizedBox(
                            height: 20,
                          ),
                          const TopInflunderList(),
                        ] else ...[
                          const WelcomeBanner(),
                          const CampaingList(),
                          const SizedBox(
                            height: 30,
                          ),
                          const SponsoredPostList(),
                          const SizedBox(
                            height: 30,
                          ),
                          const TopBrandsList(),
                        ],
                        const SizedBox(
                          height: 80,
                        ),
                      ]),
                ),
              ),
      ),
    );
  }
}

class CampaingList extends HookConsumerWidget {
  const CampaingList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CusApiReq apiReq = CusApiReq();

    ValueNotifier<List> topChampaing = useState<List>([]);
    init() async {
      final branddata =
          await apiReq.postApi(jsonEncode({}), path: "/api/campaign-search");
      topChampaing.value = branddata[0]["data"].sublist(0, 6);
    }

    useEffect(() {
      init();
      return null;
    }, []);

    List<String> getPlatforms(List plat) {
      List<String> platfroms = [];
      for (int i = 0; i < plat.length; i++) {
        platfroms.add(plat[i]["platformLogoUrl"]);
      }
      return platfroms;
    }

    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FaIcon(CupertinoIcons.sparkles, color: primaryC),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "New Campaign",
                  textAlign: TextAlign.left,
                  textScaleFactor: 1,
                  style: TextStyle(
                      color: blackC, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                for (int i = 0; i < topChampaing.value.length; i++) ...[
                  HomeCard(
                    imgUrl: topChampaing.value[i]["brand"]["logo"],
                    champname: topChampaing.value[i]["campaignName"],
                    title: topChampaing.value[i]["brand"]["name"],
                    btnColor: const Color(0xfffbc98e),
                    btnText: "Learn more & apply",
                    btnFunction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChampignInfo(
                            id: topChampaing.value[i]["id"].toString(),
                          ),
                        ),
                      );
                    },
                    website: topChampaing.value[i]["brand"]["webUrl"],
                    category:
                        int.parse(topChampaing.value[i]["campaignTypeId"]),
                    // category: 1,
                    isHeart: false,
                    amount: topChampaing.value[i]["costPerPost"]
                        .toString()
                        .split(".")[0],
                    // currency: topChampaing.value[i]["currency"]["code"],
                    currency: "USD",
                    platforms: getPlatforms(topChampaing.value[i]["platforms"]),
                    networkImg: true,
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SponsoredPostList extends HookConsumerWidget {
  const SponsoredPostList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CusApiReq apiReq = CusApiReq();

    ValueNotifier<List> topChampaing = useState<List>([]);
    init() async {
      final branddata =
          await apiReq.postApi(jsonEncode({}), path: "/api/get-top-campaigns");
      topChampaing.value = branddata[0]["data"]["campaigns"];
    }

    useEffect(() {
      init();
      return null;
    }, []);

    List<String> getPlatforms(List plat) {
      List<String> platfroms = [];
      for (int i = 0; i < plat.length; i++) {
        platfroms.add(plat[i]["platformLogoUrl"]);
      }
      return platfroms;
    }

    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FaIcon(CupertinoIcons.sparkles, color: primaryC),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Sponsored Posts",
                  textAlign: TextAlign.left,
                  textScaleFactor: 1,
                  style: TextStyle(
                      color: blackC, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                for (int i = 0; i < topChampaing.value.length; i++) ...[
                  HomeCard(
                    imgUrl: topChampaing.value[i]["brand"]["logo"],
                    champname: topChampaing.value[i]["name"],
                    title: topChampaing.value[i]["brand"]["name"],
                    btnColor: const Color(0xfffbc98e),
                    btnText: "Learn more & apply",
                    btnFunction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChampignInfo(
                            id: topChampaing.value[i]["id"].toString(),
                          ),
                        ),
                      );
                    },
                    website: topChampaing.value[i]["brand"]["webUrl"],
                    category:
                        int.parse(topChampaing.value[i]["campaignTypeId"]),
                    // category: 1,
                    isHeart: false,
                    amount: topChampaing.value[i]["costPerPost"]
                        .toString()
                        .split(".")[0],
                    // currency: topChampaing.value[i]["currency"]["code"],
                    currency: "USD",
                    platforms: getPlatforms(topChampaing.value[i]["platforms"]),
                    networkImg: true,
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TopBrandsList extends HookConsumerWidget {
  const TopBrandsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CusApiReq apiReq = CusApiReq();

    ValueNotifier<List> topBarnds = useState<List>([]);
    init() async {
      final branddata =
          await apiReq.postApi(jsonEncode({}), path: "/api/get-top-brands");
      topBarnds.value = branddata[0]["data"];
    }

    useEffect(() {
      init();
      return null;
    }, []);

    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FaIcon(CupertinoIcons.star_fill, color: primaryC),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Top Brands",
                  textAlign: TextAlign.left,
                  textScaleFactor: 1,
                  style: TextStyle(
                      color: blackC, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                for (int i = 0; i < topBarnds.value.length; i++) ...[
                  BrandCard(
                    imgUrl: topBarnds.value[i]["logo"],
                    title: topBarnds.value[i]["name"],
                    btnColor: const Color(0xff80fff9),
                    btnText: "View",
                    btnFunction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BrandInfo(
                            id: topBarnds.value[i]["id"].toString(),
                          ),
                        ),
                      );
                    },
                    email: "Email: ${topBarnds.value[i]["email"]}",
                    website: topBarnds.value[i]["webUrl"],
                    networkImg: true,
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}

class WelcomeBanner extends HookConsumerWidget {
  const WelcomeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Search()),
            (route) => false);
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7941D),
          boxShadow: const [
            BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
          ],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDB60C),
                  ),
                  child: Image.asset("assets/images/homeavatar.png"),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "To earn more money?",
                      textScaleFactor: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: blackC,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Search, apply for brands campaings\nand create more great content.",
                        textAlign: TextAlign.left,
                        textScaleFactor: 1,
                        style: TextStyle(
                            color: blackC,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopInflunderList extends HookConsumerWidget {
  const TopInflunderList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CusApiReq apiReq = CusApiReq();

    ValueNotifier<List> topInf = useState<List>([]);
    init() async {
      final infdata = await apiReq.postApi(jsonEncode({"role": "10"}),
          path: "/api/user-search");

      topInf.value = infdata[0]["data"];
    }

    useEffect(() {
      init();
      return null;
    }, []);

    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                FaIcon(CupertinoIcons.star_fill, color: primaryC),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Top Influencer",
                  textAlign: TextAlign.left,
                  textScaleFactor: 1,
                  style: TextStyle(
                      color: blackC, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                for (int i = 0; i < 5; i++) ...[
                  TopInfluencerBox(
                    name: topInf.value[i]["userName"].toString().split("@")[0],
                    avatar: topInf.value[i]["pic"],
                    // score: "2000",
                    rating: double.parse(topInf.value[i]["rating"]).round(),
                    // reach: "200000",
                    // imporession: "300000",
                    dob: topInf.value[i]["dob"],
                    // currency: topInf.value[i]["currency"]["code"],
                    currency: "USD",
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TopInfluencerBox extends HookConsumerWidget {
  final String name;
  final String avatar;
  // final String score;
  final int rating;
  // final String reach;
  // final String imporession;
  final String dob;
  final String currency;
  const TopInfluencerBox({
    super.key,
    required this.name,
    required this.avatar,
    // required this.score,
    required this.rating,
    // required this.reach,
    // required this.imporession,
    required this.dob,
    required this.currency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: blackC.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: CachedNetworkImage(
                imageUrl: avatar,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                  child: CircularProgressIndicator(
                      value: downloadProgress.progress),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/images/user.png",
                  fit: BoxFit.cover,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 220,
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            textScaleFactor: 1,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (int i = 0; i < rating; i++) ...[
                              const Icon(
                                Icons.star,
                                color: primaryC,
                                size: 15,
                              ),
                            ],
                            for (int i = 0; i < 5 - rating; i++) ...[
                              const Icon(
                                Icons.star,
                                color: backgroundC,
                                size: 15,
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "3500 $currency",
                          textScaleFactor: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          dob,
                          textScaleFactor: 1,
                          style: TextStyle(
                            fontSize: 14,
                            color: blackC.withOpacity(0.75),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Center(
          //   child: Container(
          //     width: 220,
          //     margin: const EdgeInsets.symmetric(vertical: 10),
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 10,
          //       vertical: 4,
          //     ),
          //     decoration: BoxDecoration(
          //       color: backgroundC,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: IntrinsicHeight(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         mainAxisSize: MainAxisSize.max,
          //         children: [
          //           Column(
          //             children: [
          //               Text(
          //                 reach,
          //                 textScaleFactor: 1,
          //                 style: const TextStyle(
          //                   fontSize: 18,
          //                   fontWeight: FontWeight.w500,
          //                 ),
          //               ),
          //               Text(
          //                 "Reach",
          //                 textScaleFactor: 1,
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   color: blackC.withOpacity(0.75),
          //                   fontWeight: FontWeight.w400,
          //                 ),
          //               ),
          //             ],
          //           ),
          //           const VerticalDivider(
          //             color: blackC,
          //           ),
          //           Column(
          //             children: [
          //               Text(
          //                 imporession,
          //                 textScaleFactor: 1,
          //                 style: const TextStyle(
          //                   fontSize: 18,
          //                   fontWeight: FontWeight.w500,
          //                 ),
          //               ),
          //               Text(
          //                 "Imporession",
          //                 textScaleFactor: 1,
          //                 style: TextStyle(
          //                   fontSize: 14,
          //                   color: blackC.withOpacity(0.75),
          //                   fontWeight: FontWeight.w400,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Center(
          //   child: SizedBox(
          //     width: 220,
          //     child: CusBtn(
          //       btnColor: backgroundC,
          //       btnText: "Score : $score",
          //       textSize: 16,
          //       textColor: blackC,
          //       btnFunction: () {},
          //       elevation: 0,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
