// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:swrv/database/models/favoritebrand.dart';
import 'package:swrv/services/apirequest.dart';
import 'package:swrv/state/userstate.dart';
import 'package:swrv/utils/alerts.dart';
import 'package:swrv/utils/utilsmethods.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/widgets/alerts.dart';

import '../../database/database.dart';
import '../../widgets/componets.dart';
import '../campaings/campaigninfo.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';

class BrandInfo extends HookConsumerWidget {
  final String id;
  const BrandInfo({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());
    final width = MediaQuery.of(context).size.width;

    CusApiReq apiReq = CusApiReq();
    final branddata = useState<List>([]);
    ValueNotifier<bool> isLoading = useState<bool>(true);
    ValueNotifier<List> favList = useState<List>([]);
    ValueNotifier<bool> isFav = useState<bool>(false);

    ValueNotifier<int> rating = useState<int>(0);
    ValueNotifier<int> connection = useState<int>(0);
    ValueNotifier<int> completed = useState<int>(0);

    ValueNotifier<bool> isAvailableCamp = useState<bool>(true);

    void init() async {
      final getfav =
          await isarDB.favoriteBrands.filter().brandidEqualTo(id).findAll();
      favList.value = getfav;

      if (favList.value.isEmpty) {
        isFav.value = false;
      } else {
        isFav.value = true;
      }

      final req = {
        "id": id,
      };

      List data =
          await apiReq.postApi2(jsonEncode(req), path: "/api/get-brand");
      if (data[0]["status"] == true) {
        branddata.value = [data[0]["data"]];
      } else {
        erroralert(context, "Error", "No Data found");
      }

      List brandconnection = await apiReq.postApi(jsonEncode({"brandId": id}),
          path: "/api/get-brand-connection");
      if (brandconnection[0]["status"] == true) {
        connection.value =
            int.parse(brandconnection[0]["data"]["influencer_count"]);
      }

      List brandcompleted = await apiReq.postApi(jsonEncode({"brandId": id}),
          path: "/api/get-brand-com-cam");
      if (brandcompleted[0]["status"] == true) {
        completed.value =
            int.parse(brandcompleted[0]["data"]["completed_campaign"]);
      }

      List brandrating = await apiReq.postApi2(
          jsonEncode({
            "search": {
              "type": "3",
              "brand": id,
            }
          }),
          path: "/api/search-review");

      if (brandrating[0]["status"] == true) {
        double myrate = 0;
        for (int i = 0; i < brandrating[0]["data"].length; i++) {
          myrate += double.parse(brandrating[0]["data"][i]["rating1"]) +
              double.parse(brandrating[0]["data"][i]["rating2"]) +
              double.parse(brandrating[0]["data"][i]["rating3"]);
        }
        rating.value = ((myrate / brandrating[0]["data"].length) / 3).round();
      }
      isLoading.value = false;
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
        child: isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
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
                        color: whiteC,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: shadowC,
                            blurRadius: 5,
                            offset: Offset(0, 6),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CachedNetworkImage(
                                    imageUrl: branddata.value[0]["logo"],
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      longtext(branddata.value[0]["name"], 15),
                                      textAlign: TextAlign.left,
                                      textScaleFactor: 1,
                                      style: const TextStyle(
                                          color: blackC,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      branddata.value[0]["email"],
                                      textAlign: TextAlign.left,
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          color: blackC.withOpacity(0.65),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "Brand Code : ${branddata.value[0]["code"]}",
                                      textAlign: TextAlign.left,
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          color: blackC.withOpacity(0.55),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  isFav.value = !isFav.value;
                                  if (favList.value.isEmpty) {
                                    final newFav = FavoriteBrand()
                                      ..brandid = id
                                      ..name = branddata.value[0]["name"]
                                      ..img = branddata.value[0]["logo"];
                                    await isarDB.writeTxn(() async {
                                      await isarDB.favoriteBrands.put(newFav);
                                    });
                                  } else {
                                    await isarDB.writeTxn(() async {
                                      await isarDB.favoriteBrands
                                          .delete(favList.value[0].id);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.favorite,
                                  size: 30,
                                  color: isFav.value ? Colors.red : Colors.grey,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Wrap(
                            children: [
                              BrandTabs(
                                title: "Rating",
                                value: rating.value,
                                icon: Icons.star,
                              ),
                              BrandTabs(
                                title: "Connections",
                                value: connection.value,
                                icon: Icons.handshake,
                              ),
                              BrandTabs(
                                title: "Campaigns Completed",
                                value: completed.value,
                                icon: Icons.connected_tv_outlined,
                              )
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Brand info",
                              textScaleFactor: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryC),
                            ),
                          ),
                          Text(
                            branddata.value[0]["info"],
                            textScaleFactor: 1,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: blackC),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: whiteC,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: shadowC,
                            blurRadius: 5,
                            offset: Offset(0, 6),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAvailableCamp.value
                                        ? const Color(0xff01FFF4)
                                        : const Color(0xffeeeeee),
                                  ),
                                  onPressed: () {
                                    isAvailableCamp.value = true;
                                  },
                                  child: const Text(
                                    "Available Campaigns",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAvailableCamp.value
                                        ? const Color(0xffeeeeee)
                                        : const Color(0xff01FFF4),
                                  ),
                                  onPressed: () {
                                    isAvailableCamp.value = false;
                                  },
                                  child: const Text(
                                    "Past associations",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isAvailableCamp.value
                              ? AvailableCampaigns(
                                  brandId: id,
                                )
                              : PastAssociations(
                                  brandId: id,
                                ),
                        ],
                      ),
                    ),
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

class BrandTabs extends HookConsumerWidget {
  final String title;
  final int value;
  final IconData icon;
  const BrandTabs({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                color: const Color(0xffeeeeee),
                borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 30,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                textScaleFactor: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                title,
                textScaleFactor: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}

class AvailableCampaigns extends HookConsumerWidget {
  final String brandId;
  const AvailableCampaigns({super.key, required this.brandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> isLoading = useState<bool>(true);
    ValueNotifier<List> availableCampaign = useState<List>([]);
    CusApiReq apiReq = CusApiReq();

    Future<void> init() async {
      final branddata = await apiReq.postApi2(jsonEncode({"brand": brandId}),
          path: "/api/campaign-search");

      availableCampaign.value = branddata[0]["data"];

      isLoading.value = false;
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

    return isLoading.value
        ? const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        : availableCampaign.value.isEmpty
            ? const WarningAlart(
                message: "There is not available Campaigns",
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for (int i = 0;
                        i < availableCampaign.value.length;
                        i++) ...[
                      HomeCard(
                        imgUrl: availableCampaign.value[i]["brand"]["logo"],
                        champname: availableCampaign.value[i]["campaignName"],
                        title: availableCampaign.value[i]["brand"]["name"],
                        btnColor: const Color(0xfffbc98e),
                        btnText: "Learn more & apply",
                        btnFunction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChampignInfo(
                                id: availableCampaign.value[i]["id"].toString(),
                              ),
                            ),
                          );
                        },
                        website: availableCampaign.value[i]["brand"]["webUrl"],
                        category: int.parse(
                            availableCampaign.value[i]["campaignTypeId"]),
                        isHeart: false,
                        amount: availableCampaign.value[i]["costPerPost"]
                            .toString()
                            .split(".")[0],
                        currency: availableCampaign.value[i]["currency"]
                            ["code"],
                        platforms: getPlatforms(
                            availableCampaign.value[i]["platforms"]),
                        networkImg: true,
                      ),
                    ],
                  ],
                ),
              );
  }
}

class PastAssociations extends HookConsumerWidget {
  final String brandId;
  const PastAssociations({super.key, required this.brandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> isLoading = useState<bool>(true);
    CusApiReq apiReq = CusApiReq();
    ValueNotifier<List> pastAssociations = useState<List>([]);

    final userStateW = ref.watch(userState);
    Future<void> init() async {
      final userId = await userStateW.getUserId();
      final dynamic req = {
        "search": {
          "fromUser": userId,
          "influencer": userId,
          "brand": brandId,
        },
      };
      final branddata =
          await apiReq.postApi2(jsonEncode(req), path: "/api/search-draft");

      pastAssociations.value = branddata[0]["data"];

      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);

    return isLoading.value
        ? const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        : pastAssociations.value.isEmpty
            ? const WarningAlart(message: "There is not Past Associations")
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < pastAssociations.value.length; i++) ...[
                      Container(
                        width: 280,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        margin: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: whiteC,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CachedNetworkImage(
                                      imageUrl: pastAssociations.value[i]
                                          ["influencer"]["pic"],
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
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
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        pastAssociations.value[i]["influencer"]
                                                ["name"]
                                            .toString()
                                            .split("@")[0],
                                        textAlign: TextAlign.left,
                                        textScaleFactor: 1,
                                        style: const TextStyle(
                                            color: blackC,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        pastAssociations.value[i]["influencer"]
                                            ["email"],
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.fade,
                                        textScaleFactor: 1,
                                        style: const TextStyle(
                                            color: blackC,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            const Text(
                              "Message",
                              textAlign: TextAlign.left,
                              textScaleFactor: 1,
                              style: TextStyle(
                                  color: blackC,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              pastAssociations.value[i]["description"],
                              textAlign: TextAlign.left,
                              textScaleFactor: 1,
                              style: const TextStyle(
                                  color: blackC,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Publish Date : ${pastAssociations.value[i]["publishAt"].toString().split("-")[2].split(" ")[0]}-${pastAssociations.value[i]["publishAt"].toString().split("-")[1]}-${pastAssociations.value[i]["publishAt"].toString().split("-")[0]}",
                              textAlign: TextAlign.left,
                              textScaleFactor: 1,
                              style: const TextStyle(
                                  color: blackC,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) => PdfViewer(
                                          link: pastAssociations.value[i]
                                              ["attach01"],
                                        )),
                                  ),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    color: backgroundC,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.attachment,
                                        color: blackC,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      "Attachment",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          color: blackC,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (int.parse(pastAssociations.value[i]["status"]
                                    ["code"]) ==
                                3) ...[
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffbeff80),
                                  minimumSize: const Size.fromHeight(30),
                                ),
                                child: Text(
                                  "Accepted",
                                  textScaleFactor: 1,
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            ] else if (int.parse(pastAssociations.value[i]
                                    ["status"]["code"]) ==
                                5) ...[
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffff88bb),
                                  minimumSize: const Size.fromHeight(30),
                                ),
                                child: Text(
                                  "Rejected",
                                  textScaleFactor: 1,
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            ] else ...[
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xfffbca8e),
                                  minimumSize: const Size.fromHeight(30),
                                ),
                                child: Text(
                                  "Under Process",
                                  textScaleFactor: 1,
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
  }
}
