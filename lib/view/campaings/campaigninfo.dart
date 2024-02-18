// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:swrv/database/database.dart';
import 'package:swrv/database/models/favoritechamp.dart';
import 'package:swrv/services/apirequest.dart';
import 'package:swrv/state/userstate.dart';
import 'package:swrv/utils/alerts.dart';
import 'package:swrv/utils/utilsmethods.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/widgets/alerts.dart';
import 'package:swrv/widgets/buttons.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../state/compaign/campaigninfostate.dart';
import '../../widgets/champaleart.dart';
import '../../widgets/componets.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';
import 'moreinfo.dart';

enum AcceptReq { none, pending, accepted, rejected }

class ChampignInfo extends HookConsumerWidget {
  final String id;
  const ChampignInfo({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());
    final width = MediaQuery.of(context).size.width;

    CusApiReq apiReq = CusApiReq();
    final userStateW = ref.watch(userState);
    final champdata = useState([]);
    ValueNotifier<bool> isLoading = useState(true);
    ValueNotifier<List> favList = useState([]);

    ValueNotifier<bool> isFav = useState(false);

    ValueNotifier<bool> isBrand = useState(false);
    ValueNotifier<AcceptReq> acceptReq = useState<AcceptReq>(AcceptReq.none);

    ValueNotifier<List> acceptRequestData = useState<List>([]);

    ValueNotifier<String> userId = useState<String>("");

    ValueNotifier<dynamic> aprovedBid = useState<dynamic>(null);

    ValueNotifier<String> category = useState("");

    void init() async {
      List bidreq = await apiReq.postApi(jsonEncode({"campaignId": id}),
          path: "/api/get-approved-bid");

      if (bidreq[0]["status"]) {
        aprovedBid.value = bidreq[0]["data"][0];
      }

      userId.value = await userStateW.getUserId();
      //fav section
      isBrand.value = await userStateW.isBrand();
      final getfav =
          await isarDB.favoriteChamps.filter().champidEqualTo(id).findAll();
      favList.value = getfav;

      if (favList.value.isEmpty) {
        isFav.value = false;
      } else {
        isFav.value = true;
      }

      //campaigns info section
      final req = {
        "id": id,
      };

      List data =
          await apiReq.postApi(jsonEncode(req), path: "/api/campaign-search");
      if (data[0]["status"] == true) {
        champdata.value = data[0]["data"];
      } else {
        erroralert(context, "Error", "No Data found");
      }

      //accept section
      final req2 = {
        "search": {
          "campaign": id,
          "influencer": await userStateW.getUserId(),
          // "fromUser": await userStateW.getUserId(),
        }
      };

      List reqdata =
          await apiReq.postApi2(jsonEncode(req2), path: "/api/search-invite");
      acceptRequestData.value = reqdata[0]["data"];
      if (reqdata[0]["status"] == false) {
        acceptReq.value = AcceptReq.none;
      } else if (acceptRequestData.value.first["status"]["code"] == "1") {
        acceptReq.value = AcceptReq.pending;
      } else if (acceptRequestData.value.first["status"]["code"] == "3") {
        acceptReq.value = AcceptReq.accepted;
      } else if (acceptRequestData.value.first["status"]["code"] == "5") {
        acceptReq.value = AcceptReq.rejected;
      }

      category.value =
          await apiReq.getCampaignType(champdata.value[0]["campaignTypeId"]);

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
                      margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: whiteC,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CachedNetworkImage(
                                      imageUrl: champdata.value[0]["brand"]
                                          ["logo"],
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
                                    )),
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
                                      champdata.value[0]["brand"]["name"],
                                      textAlign: TextAlign.left,
                                      textScaleFactor: 1,
                                      style: const TextStyle(
                                          color: blackC,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      category.value,
                                      textAlign: TextAlign.left,
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                        color: Colors.green.withOpacity(0.8),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  isFav.value = !isFav.value;
                                  if (favList.value.isEmpty) {
                                    final newFav = FavoriteChamp()
                                      ..champid = id
                                      ..name =
                                          champdata.value[0]["campaignName"]
                                      ..img =
                                          champdata.value[0]["brand"]["logo"];
                                    await isarDB.writeTxn(() async {
                                      await isarDB.favoriteChamps.put(newFav);
                                    });
                                  } else {
                                    await isarDB.writeTxn(() async {
                                      await isarDB.favoriteChamps
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
                            height: 10,
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
                            champdata.value[0]["brand"]["info"],
                            textScaleFactor: 1,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: blackC),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              longtext(champdata.value[0]["campaignName"], 35),
                              textAlign: TextAlign.left,
                              textScaleFactor: 1,
                              style: GoogleFonts.openSans(
                                  color: blackC,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Campaign info",
                              textScaleFactor: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryC),
                            ),
                          ),
                          Text(
                            champdata.value[0]["campaignInfo"],
                            textScaleFactor: 1,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: blackC),
                          ),
                          if (!(int.parse(
                                      champdata.value[0]["campaignTypeId"]) ==
                                  6 ||
                              int.parse(champdata.value[0]["campaignTypeId"]) ==
                                  5)) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Moodboard",
                                textScaleFactor: 1,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryC),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  for (int i = 0;
                                      i <
                                          champdata
                                              .value[0]["moodBoards"].length;
                                      i++) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: CachedNetworkImage(
                                            imageUrl: champdata.value[0]
                                                ["moodBoards"][i]["url"],
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Attachment",
                                textScaleFactor: 1,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryC),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) => PdfViewer(
                                          link: champdata.value[0]
                                              ["attachments"][0]["url"],
                                        )),
                                  ),
                                );
                              },
                              child: Container(
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
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(
                            height: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Platforms",
                              textScaleFactor: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryC),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                for (int i = 0;
                                    i < champdata.value[0]["platforms"].length;
                                    i++) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CachedNetworkImage(
                                          imageUrl: champdata.value[0]
                                                  ["platforms"][i]
                                              ["platformLogoUrl"],
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (!(int.parse(
                                      champdata.value[0]["campaignTypeId"]) ==
                                  6 ||
                              int.parse(champdata.value[0]["campaignTypeId"]) ==
                                  5)) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Mentions",
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: blackC),
                                        ),
                                        for (int i = 0;
                                            i <
                                                champdata.value[0]["mentions"]
                                                    .toString()
                                                    .split(",")
                                                    .length;
                                            i++) ...[
                                          Container(
                                            width: 120,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              color: backgroundC,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "@${champdata.value[0]["mentions"].toString().split(",")[i]}",
                                              textScaleFactor: 1,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: secondaryC),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Hashtags",
                                          textScaleFactor: 1,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: blackC),
                                        ),
                                        for (int i = 0;
                                            i <
                                                champdata.value[0]["hashtags"]
                                                    .toString()
                                                    .split(",")
                                                    .length;
                                            i++) ...[
                                          Container(
                                            width: 120,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              color: backgroundC,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "#${champdata.value[0]["hashtags"].toString().split(",")[i]}",
                                              textScaleFactor: 1,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: secondaryC),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: backgroundC,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(Icons.done, color: Colors.green),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Do",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        color: blackC,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                for (int i = 0;
                                    i <
                                        champdata.value[0]["donts"]
                                            .toString()
                                            .split(",")
                                            .length;
                                    i++) ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Icon(Icons.done,
                                            color: Colors.green),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color:
                                                      blackC.withOpacity(0.15),
                                                  blurRadius: 10),
                                            ],
                                            color: whiteC,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                champdata.value[0]["dos"]
                                                    .toString()
                                                    .split(",")[i],
                                                textScaleFactor: 1,
                                                style: const TextStyle(
                                                  color: blackC,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: backgroundC,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(Icons.close, color: Colors.red),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Don't",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        color: blackC,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                for (int i = 0;
                                    i <
                                        champdata.value[0]["donts"]
                                            .toString()
                                            .split(",")
                                            .length;
                                    i++) ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color:
                                                      blackC.withOpacity(0.15),
                                                  blurRadius: 10),
                                            ],
                                            color: whiteC,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                champdata.value[0]["donts"]
                                                    .toString()
                                                    .split(",")[i],
                                                textScaleFactor: 1,
                                                style: const TextStyle(
                                                  color: blackC,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    CampaignBudget(
                        // currencyCode: champdata.value[0]["currency"]["code"],
                        currencyCode: "USD",
                        totalBudget: champdata.value[0]["totalBudget"],
                        costperpost: champdata.value[0]["costPerPost"],
                        isbid: (int.parse(
                                    champdata.value[0]["campaignTypeId"]) ==
                                6 ||
                            int.parse(champdata.value[0]["campaignTypeId"]) ==
                                5)),
                    CampaignTarget(
                        location: champdata.value[0]["brand"]["city"]["state"]
                            ["country"]["name"],
                        maxReach: champdata.value[0]["maxReach"],
                        minReach: champdata.value[0]["minReach"],
                        startDate: champdata.value[0]["startAt"],
                        endDate: champdata.value[0]["endAt"],
                        isbid: (int.parse(
                                    champdata.value[0]["campaignTypeId"]) ==
                                6 ||
                            int.parse(champdata.value[0]["campaignTypeId"]) ==
                                5)),
                    if (isBrand.value) ...[
                      PandingAcceptRequest(
                        id: id,
                      ),
                      PandingDraftRequest(
                        id: id,
                      ),
                      // PandingPaymentRequest(id: id),
                    ] else ...[
                      if (acceptReq.value == AcceptReq.none) ...[
                        InviteToCampaign(
                          id: id,
                          toUserId: champdata.value[0]["brandUserId"],
                          maxInf: champdata.value[0]["totalParticipants"],
                          endAt: champdata.value[0]["endAt"],
                        ),
                      ] else if (acceptReq.value == AcceptReq.accepted) ...[
                        if (int.parse(champdata.value[0]["campaignTypeId"]) !=
                            6) ...[
                          CampaignsTabs(
                            id: id,
                            brandId: champdata.value[0]["brand"]["id"],
                            userId: userId.value,
                          ),
                        ] else ...[
                          if (aprovedBid.value == null ||
                              aprovedBid.value == "") ...[
                            CampaingBidding(
                              costPerPost: champdata.value[0]["costPerPost"],
                              campaignId: champdata.value[0]["id"],
                              brandId: champdata.value[0]["brand"]["id"],
                              userId: userId.value,
                            ),
                          ] else ...[
                            if (aprovedBid.value["userId"] == userId.value) ...[
                              CampaignsTabs(
                                id: id,
                                brandId: champdata.value[0]["brand"]["id"],
                                userId: userId.value,
                              ),
                            ] else ...[
                              const WarningAlart(
                                message: "Your bid is not accepted",
                              )
                            ],
                          ],
                        ],
                        UserDrafts(
                          id: id,
                        ),
                      ] else if (acceptReq.value == AcceptReq.pending) ...[
                        const InviteToCampaignPanding(),
                      ] else if (acceptReq.value == AcceptReq.rejected) ...[
                        InviteToCampaignRejected(
                          id: id,
                          toUserId: champdata.value[0]["brandUserId"],
                          reason: acceptRequestData.value.first["status"]
                              ["message"],
                        )
                      ],
                    ],
                    if (!isBrand.value) ...[
                      if (int.parse(champdata.value[0]["campaignTypeId"]) ==
                          6) ...[
                        BidSnapshot(
                          campaignid: champdata.value[0]["id"],
                          userid: userId.value,
                        )
                      ],
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

class CampaingBidding extends HookConsumerWidget {
  final String costPerPost;
  final String userId;
  final String campaignId;
  final String brandId;

  const CampaingBidding({
    super.key,
    required this.costPerPost,
    required this.userId,
    required this.campaignId,
    required this.brandId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<int> amount = useState<int>(0);
    CusApiReq apiReq = CusApiReq();
    final remark = useTextEditingController();
    final bidamount = useTextEditingController();

    Future<void> init() async {
      final req = {"campaignId": campaignId};

      List reqdata = await apiReq.postApi2(jsonEncode(req),
          path: "/api/get-campaign-last-bid");
      if (reqdata[0]["status"]) {
        amount.value = int.parse(reqdata[0]["data"][0]["bidamount"]);
      } else {
        amount.value = 0;
      }
    }

    useEffect(() {
      init();
      return null;
    }, []);

    final GlobalKey<FormState> formKey =
        useMemoized(() => GlobalKey<FormState>());
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(10),
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
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Bidding",
                textScaleFactor: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackC,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Divider(),
            Text(
              "Starting bid: ${costPerPost.split(".")[0]}",
              textScaleFactor: 1,
              style: const TextStyle(
                color: blackC,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Current bid: ${amount.value.toString().split(".")[0]}",
              textScaleFactor: 1,
              style: const TextStyle(
                color: blackC,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Min bid: ${100}",
              textScaleFactor: 1,
              style: TextStyle(
                color: blackC,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter Amount",
              textScaleFactor: 1,
              style: TextStyle(
                color: blackC,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: bidamount,
                  validator: (value) {
                    if (value == null || value.isEmpty || value == "") {
                      return 'Please enter the amount.';
                    } else if (int.parse(value) % 100 != 0) {
                      return "Bid amount must be a multiple of 100.";
                    } else if (amount.value < int.parse(value)) {
                      return "Bid amount must be less then current bid amount.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xfff3f4f6),
                    hintText: "Amount...",
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TextFormField(
                  minLines: 4,
                  maxLines: 6,
                  controller: remark,
                  validator: (value) {
                    if (value == null || value.isEmpty || value == "") {
                      return 'Please enter the some description.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xfff3f4f6),
                    hintText: "Remark...",
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfffbca8e),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final req = {
                      "brandId": brandId,
                      "userId": userId,
                      "campaignId": campaignId,
                      "remark": remark.text,
                      "bidamount": bidamount.text,
                    };

                    List reqdata = await apiReq.postApi2(jsonEncode(req),
                        path: "/api/add-bid");
                    if (reqdata[0]["status"]) {
                      Navigator.pop(context);
                    } else {
                      erroralert(context, "Error", "Unable to bid.");
                    }
                  }
                },
                child: const Text("Bid Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CampaignBudget extends HookWidget {
  const CampaignBudget({
    super.key,
    required this.currencyCode,
    required this.costperpost,
    required this.totalBudget,
    required this.isbid,
  });
  final String currencyCode;
  final String costperpost;
  final String totalBudget;
  final bool isbid;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: whiteC,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const Row(
            children: [
              FaIcon(
                FontAwesomeIcons.coins,
                color: secondaryC,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Budget",
                textScaleFactor: 1,
                style: TextStyle(
                  color: blackC,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(
            color: blackC,
          ),
          Row(
            children: [
              const Text(
                "Cost per post",
                textScaleFactor: 1,
                style: TextStyle(
                  color: blackC,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                "${costperpost.toString().split('.')[0]} $currencyCode",
                textScaleFactor: 1,
                style: const TextStyle(
                  color: blackC,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if (!isbid) ...[
            Row(
              children: [
                const Text(
                  "Total Budget",
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: blackC,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  "${totalBudget.toString().split('.')[0]} $currencyCode",
                  textScaleFactor: 1,
                  style: const TextStyle(
                    color: blackC,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ],
      ),
    );
  }
}

class CampaignTarget extends HookWidget {
  const CampaignTarget({
    super.key,
    required this.location,
    required this.minReach,
    required this.maxReach,
    required this.startDate,
    required this.endDate,
    required this.isbid,
  });
  final String location;
  final String minReach;
  final String maxReach;
  final String startDate;
  final String endDate;
  final bool isbid;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: whiteC,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const Row(
            children: [
              FaIcon(
                FontAwesomeIcons.coins,
                color: secondaryC,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Target",
                textScaleFactor: 1,
                style: TextStyle(
                  color: blackC,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(
            color: blackC,
          ),
          Row(
            children: [
              const Text(
                "Audience location",
                textScaleFactor: 1,
                style: TextStyle(
                  color: secondaryC,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              FittedBox(
                child: Text(
                  location,
                  textScaleFactor: 1,
                  style: const TextStyle(
                    color: secondaryC,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if (!isbid) ...[
            Row(
              children: [
                const Text(
                  "Min reach",
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: blackC,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  minReach,
                  textScaleFactor: 1,
                  style: const TextStyle(
                    color: blackC,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text(
                  "Max reach",
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: blackC,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  maxReach,
                  textScaleFactor: 1,
                  style: const TextStyle(
                    color: blackC,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
          Row(
            children: [
              const Text(
                "Start date",
                textScaleFactor: 1,
                style: TextStyle(
                  color: blackC,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                "${startDate.split("-")[2].split(" ")[0]}-${startDate.split("-")[1]}-${startDate.split("-")[0]}",
                textScaleFactor: 1,
                style: const TextStyle(
                  color: blackC,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Text(
                "End date",
                textScaleFactor: 1,
                style: TextStyle(
                  color: blackC,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                "${endDate.split("-")[2].split(" ")[0]}-${endDate.split("-")[1]}-${endDate.split("-")[0]}",
                textScaleFactor: 1,
                style: const TextStyle(
                  color: blackC,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InviteToCampaign extends HookConsumerWidget {
  const InviteToCampaign({
    super.key,
    required this.id,
    required this.toUserId,
    required this.endAt,
    required this.maxInf,
  });
  final String id;
  final String toUserId;
  final String endAt;
  final String maxInf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    TextEditingController msg = useTextEditingController();
    ValueNotifier<int> invites = useState<int>(0);
    CusApiReq apiReq = CusApiReq();

    Future<void> init() async {
      final req = {
        "search": {
          "status": "3",
          "campaign": id.toString(),
        }
      };

      List data =
          await apiReq.postApi2(jsonEncode(req), path: "/api/search-invite");

      if (data[0]["status"]) {
        invites.value = data[0]["data"].length;
      }
    }

    useEffect(() {
      init();
      return null;
    }, []);
    return Container(
      width: width,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryC,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const Text(
            "Would you like to participate in this campaign?",
            textScaleFactor: 1,
            style: TextStyle(
              color: whiteC,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: SizedBox(
              width: 200,
              child: CusBtn(
                btnColor: primaryC,
                btnText: "Apply",
                textSize: 18,
                btnFunction: () {
                  if ((DateTime.now().isAfter(DateTime.parse(endAt)))) {
                    erroralert(context, "Error", "Campaign already ended.");
                  } else if (invites.value > int.parse(maxInf)) {
                    erroralert(context, "Error", "Campaign is already full.");
                  }
                  connectAlert(context, ref, msg, id, toUserId);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class InviteToCampaignPanding extends HookConsumerWidget {
  const InviteToCampaignPanding({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryC,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: const Column(
        children: [
          Text(
            "Your request is in progress.. ",
            textScaleFactor: 1,
            style: TextStyle(
              color: whiteC,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class InviteToCampaignRejected extends HookConsumerWidget {
  const InviteToCampaignRejected({
    super.key,
    required this.id,
    required this.toUserId,
    required this.reason,
  });
  final String id;
  final String toUserId;
  final String reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    TextEditingController msg = useTextEditingController();
    return Container(
      width: width,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryC,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Your request has been rejected..",
            textScaleFactor: 1,
            style: TextStyle(
              color: whiteC,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Reason",
            textScaleFactor: 1,
            style: TextStyle(
              color: whiteC,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(
            color: whiteC,
          ),
          Text(
            reason,
            textScaleFactor: 1,
            style: const TextStyle(
              color: whiteC,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: SizedBox(
              width: 200,
              child: CusBtn(
                btnColor: primaryC,
                btnText: "Apply Again",
                textSize: 18,
                btnFunction: () {
                  connectAlert(context, ref, msg, id, toUserId);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PdfViewer extends HookConsumerWidget {
  final String link;
  const PdfViewer({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> isLoading = useState(true);
    PdfViewerController controller = PdfViewerController();
    useEffect(() {
      Timer(const Duration(seconds: 10), () {
        isLoading.value = false;
      });
      return null;
    });
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundC,
      appBar: AppBar(
        backgroundColor: secondaryC,
        title: const Text(
          "SWRV PDF Viwer",
          textScaleFactor: 1,
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: (isLoading.value)
                      ? const Center(child: CircularProgressIndicator())
                      : SfPdfViewer.network(
                          controller: controller,
                          link,
                          pageLayoutMode: PdfPageLayoutMode.single,
                        ),
                ),
              ),
              if (!isLoading.value) ...[
                Positioned(
                  left: 0,
                  bottom: height * 0.025,
                  child: SizedBox(
                    width: width,
                    child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryC),
                              onPressed: () {
                                controller.previousPage();
                              },
                              child: const Text("Previous")),
                        )),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryC),
                                onPressed: () {
                                  controller.nextPage();
                                },
                                child: const Text("Next")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CampaignsTabs extends HookConsumerWidget {
  const CampaignsTabs({
    super.key,
    required this.id,
    required this.brandId,
    required this.userId,
  });
  final String id;
  final String brandId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chamInfoState = ref.watch(campaignInfoState);

    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < chamInfoState.tabName.length; i++) ...[
                  InkWell(
                    onTap: () {
                      chamInfoState.setCurTab(i);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          )
                        ],
                        color: (chamInfoState.curTab == i)
                            ? secondaryC
                            : backgroundC,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        chamInfoState.tabName[i],
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: (chamInfoState.curTab == i) ? whiteC : blackC,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (chamInfoState.curTab == 0) ...[
            CreateDraft(
              id: id,
            )
          ],
          if (chamInfoState.curTab == 1) ...[
            LiveCampaigns(
              id: id,
              brandId: brandId,
            ),
          ],
          if (chamInfoState.curTab == 2) ...[
            PandingPaymentRequest(id: id, userId: userId),
          ],
        ],
      ),
    );
  }
}

class CreateDraft extends HookConsumerWidget {
  const CreateDraft({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey =
        useMemoized(() => GlobalKey<FormState>());
    final width = MediaQuery.of(context).size.width;
    final campaignInfoStateW = ref.watch(campaignInfoState);
    TextEditingController discription = useTextEditingController();
    TextEditingController publishDate = useTextEditingController();

    final userStateW = ref.watch(userState);

    void init() async {
      final platdata = await userStateW.getUserData(context);
      campaignInfoStateW.setPlatforms(jsonDecode(platdata)[0]["platforms"]);
    }

    useEffect(() {
      init();
      return null;
    }, []);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      width: width,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: whiteC,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackC.withOpacity(0.2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Create campaign draft",
              textScaleFactor: 1,
              style: TextStyle(
                color: secondaryC,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (!campaignInfoStateW.createDraft) ...[
              const Text(
                "Would you like to Create campaign draft?",
                textScaleFactor: 1,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: secondaryC,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              CusBtn(
                btnColor: const Color(0xff01FFF4),
                btnText: "Create",
                textSize: 16,
                btnFunction: () {
                  campaignInfoStateW.setCreateDraft(true);
                },
                textColor: blackC,
              )
            ] else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0;
                        i < campaignInfoStateW.platforms.length;
                        i++) ...[
                      InkWell(
                        onTap: () {
                          campaignInfoStateW.togglePlatfroms(i);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: whiteC,
                            shape: BoxShape.circle,
                            border: campaignInfoStateW.selectedPlatfomrs[i]
                                ? Border.all(color: Colors.blue, width: 2)
                                : Border.all(
                                    color: Colors.transparent, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: SizedBox(
                              width: 35,
                              height: 35,
                              child: CachedNetworkImage(
                                imageUrl: campaignInfoStateW.platforms[i]
                                    ["platform"]["logo"],
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  campaignInfoStateW.addAttachment(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: backgroundC,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.attachment,
                        color: blackC,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        (campaignInfoStateW.attachments == null)
                            ? "Attachments"
                            : longtext(
                                campaignInfoStateW.attachments!.path
                                    .split("/")
                                    .last
                                    .toString(),
                                15),
                        textScaleFactor: 1,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                          color: blackC,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            campaignInfoStateW.addAttachment(context);
                          },
                          child: const Icon(
                            Icons.add,
                            color: blackC,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty || value == "") {
                        return "Please enter the publish date";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      campaignInfoStateW.setPublishDate(value);
                    },
                    readOnly: true,
                    controller: publishDate,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: Colors.black.withOpacity(0.8),
                      ),
                      filled: true,
                      fillColor: const Color(0xfff3f4f6),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    onTap: () async {
                      var date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(DateTime.now().year + 2,
                            DateTime.now().month, DateTime.now().day),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.pink,
                                onSurface: Colors.pink,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.pink,
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      publishDate.text = DateFormat("dd-MM-yyyy").format(date!);
                      campaignInfoStateW.setPublishDate(
                          DateFormat("dd-MM-yyyy").format(date));
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TextFormField(
                    minLines: 4,
                    maxLines: 6,
                    controller: discription,
                    onChanged: (value) {
                      campaignInfoStateW.setDescription(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || value == "") {
                        return 'Please enter the some description.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xfff3f4f6),
                      hintText: "description...",
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
                btnColor: secondaryC,
                btnText: "Submit",
                textSize: 18,
                btnFunction: () async {
                  if (formKey.currentState!.validate()) {
                    await campaignInfoStateW.createcmapDraft(context, id);
                  }
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class PandingAcceptRequest extends HookConsumerWidget {
  const PandingAcceptRequest({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignInfoStateW = ref.watch(campaignInfoState);
    TextEditingController rejectInvite = useTextEditingController();

    void init() async {
      await campaignInfoStateW.setAcceptRequest(context, id);
    }

    useEffect(() {
      init();
      return null;
    }, []);
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Requested Invites",
            textScaleFactor: 1,
            style: TextStyle(
              color: blackC,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (campaignInfoStateW.acceptRequest.isEmpty) ...[
            const SizedBox(
              height: 20,
            ),
            const WarningAlart(
              message: "No Request..",
            )
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0;
                    i < campaignInfoStateW.acceptRequest.length;
                    i++) ...[
                  Container(
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
                                  imageUrl: campaignInfoStateW.acceptRequest[i]
                                      ["influencer"]["pic"],
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  campaignInfoStateW.acceptRequest[i]
                                      ["influencer"]["name"],
                                  textAlign: TextAlign.left,
                                  textScaleFactor: 1,
                                  style: const TextStyle(
                                      color: blackC,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  campaignInfoStateW.acceptRequest[i]
                                      ["influencer"]["email"],
                                  textAlign: TextAlign.left,
                                  textScaleFactor: 1,
                                  style: const TextStyle(
                                      color: blackC,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
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
                          campaignInfoStateW.acceptRequest[i]["status"]
                              ["message"],
                          textAlign: TextAlign.left,
                          textScaleFactor: 1,
                          style: const TextStyle(
                              color: blackC,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(width: 2.0, color: greenC),
                              ),
                              onPressed: () {
                                champAccecptInvite(
                                  context,
                                  ref,
                                  campaignInfoStateW.acceptRequest[i]["id"],
                                  id,
                                );
                              },
                              icon: const Icon(
                                Icons.thumb_up,
                                color: greenC,
                              ),
                              label: const Text(
                                "Accept",
                                textScaleFactor: 1,
                                style: TextStyle(
                                    color: greenC,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(width: 2.0, color: redC),
                              ),
                              onPressed: () {
                                champRejectInvite(
                                  context,
                                  ref,
                                  rejectInvite,
                                  campaignInfoStateW.acceptRequest[i]["id"],
                                  id,
                                );
                              },
                              icon: const Icon(Icons.thumb_down, color: redC),
                              label: const Text(
                                "Reject",
                                textScaleFactor: 1,
                                style: TextStyle(
                                    color: redC,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
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
    );
  }
}

class PandingDraftRequest extends HookConsumerWidget {
  const PandingDraftRequest({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignInfoStateW = ref.watch(campaignInfoState);
    TextEditingController rejectDraft = useTextEditingController();

    void init() async {
      await campaignInfoStateW.setDraftRequest(context, id);
    }

    useEffect(() {
      init();
      return null;
    }, []);
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Requested Drafts",
            textScaleFactor: 1,
            style: TextStyle(
              color: blackC,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (campaignInfoStateW.draftRequest.isEmpty) ...[
            const SizedBox(
              height: 20,
            ),
            const WarningAlart(
              message: "No request for drafts..",
            )
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0;
                    i < campaignInfoStateW.draftRequest.length;
                    i++) ...[
                  Container(
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
                                  imageUrl: campaignInfoStateW.draftRequest[i]
                                      ["influencer"]["pic"],
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  campaignInfoStateW.draftRequest[i]
                                      ["influencer"]["name"],
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.fade,
                                  textScaleFactor: 1,
                                  style: const TextStyle(
                                      color: blackC,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  campaignInfoStateW.draftRequest[i]
                                      ["influencer"]["email"],
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
                          campaignInfoStateW.draftRequest[i]["description"],
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
                          "Publish Date : ${campaignInfoStateW.draftRequest[i]["publishAt"].toString().split("-")[2].split(" ")[0]}-${campaignInfoStateW.draftRequest[i]["publishAt"].toString().split("-")[1]}-${campaignInfoStateW.draftRequest[i]["publishAt"].toString().split("-")[0]}",
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
                                      link: campaignInfoStateW.draftRequest[i]
                                          ["attach01"],
                                    )),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
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
                        const Divider(),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(width: 2.0, color: greenC),
                              ),
                              onPressed: () {
                                champAccecptDraft(
                                  context,
                                  ref,
                                  campaignInfoStateW.draftRequest[i]["id"],
                                  id,
                                );
                              },
                              icon: const Icon(
                                Icons.thumb_up,
                                color: greenC,
                              ),
                              label: const Text(
                                "Accept",
                                textScaleFactor: 1,
                                style: TextStyle(
                                    color: greenC,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(width: 2.0, color: redC),
                              ),
                              onPressed: () {
                                champRejectDraft(
                                  context,
                                  ref,
                                  rejectDraft,
                                  campaignInfoStateW.draftRequest[i]["id"],
                                  id,
                                );
                              },
                              icon: const Icon(Icons.thumb_down, color: redC),
                              label: const Text(
                                "Reject",
                                textScaleFactor: 1,
                                style: TextStyle(
                                    color: redC,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
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
    );
  }
}

class UserDrafts extends HookConsumerWidget {
  const UserDrafts({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<List> userDrafts = useState([]);
    CusApiReq apiReq = CusApiReq();
    UserState userState = UserState();

    void init() async {
      final req1 = {
        "search": {
          "fromUser": await userState.getUserId(),
          "influencer": await userState.getUserId(),
          "campaign": id
        }
      };
      List drafts =
          await apiReq.postApi2(jsonEncode(req1), path: "/api/search-draft");
      if (drafts[0]["status"]) {
        userDrafts.value = drafts[0]["data"];
        log(userDrafts.value.toString());
      }
    }

    useEffect(() {
      init();
      return null;
    }, []);
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Requested Drafts",
            textScaleFactor: 1,
            style: TextStyle(
              color: blackC,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (userDrafts.value.isEmpty) ...[
            const SizedBox(
              height: 20,
            ),
            const WarningAlart(
              message: "No drafts created..",
            )
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < userDrafts.value.length; i++) ...[
                  Container(
                    width: 260,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 250,
                            height: 180,
                            child: CachedNetworkImage(
                              imageUrl: userDrafts.value[i]["influencer"]
                                  ["pic"],
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/images/user.png",
                                fit: BoxFit.cover,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          userDrafts.value[i]["influencer"]["name"],
                          textAlign: TextAlign.left,
                          textScaleFactor: 1,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                              color: blackC,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          "Description",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: blackC,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          userDrafts.value[i]["description"],
                          textAlign: TextAlign.left,
                          textScaleFactor: 1,
                          style: const TextStyle(
                              color: blackC,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text(
                          "Platforms",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: blackC,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CachedNetworkImage(
                              imageUrl: userDrafts.value[i]["handle"]
                                  ["platform"]["logo"],
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Publication Time",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: blackC,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        if (userDrafts.value[i]["draft_approval"] == null) ...[
                          const WarningAlart(
                            message: "Publication Time not set",
                          )
                        ] else ...[
                          Text(
                            DateFormat('dd/MM/yyyy').format(DateTime.parse(
                                userDrafts.value[i]["draft_approval"]
                                    .toString())),
                            textAlign: TextAlign.left,
                            textScaleFactor: 1,
                            style: const TextStyle(
                              color: blackC,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Campaign Link",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: blackC,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        if (userDrafts.value[i]["linkCampaign"] == null) ...[
                          const WarningAlart(
                            message: "No Campaign is Linked",
                          )
                        ] else ...[
                          InkWell(
                            onTap: () async {
                              try {
                                if (!await launchUrl(Uri.parse(
                                    userDrafts.value[i]["linkCampaign"]))) {
                                  erroralert(context, "Error",
                                      'Could not open ${userDrafts.value[i]["linkCampaign"]}');
                                }
                              } catch (e) {
                                erroralert(context, "Error",
                                    'Could not open link "${userDrafts.value[i]["linkCampaign"]}"');
                              }
                            },
                            child: Container(
                              width: 250,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: blackC.withOpacity(0.2),
                                    blurRadius: 5,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(5),
                                color: const Color(0xfffbca8e),
                              ),
                              child: const Center(
                                child: Text(
                                  "View Campaign Link",
                                  textAlign: TextAlign.left,
                                  textScaleFactor: 1,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => PdfViewer(
                                      link: userDrafts.value[i]["attach01"],
                                    )),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
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
                        const SizedBox(
                          height: 6,
                        ),
                        Container(
                          width: 250,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: blackC.withOpacity(0.2), blurRadius: 5)
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: (userDrafts.value[i]["status"]["name"] ==
                                    "PENDING")
                                ? const Color(0xff80fffa)
                                : (userDrafts.value[i]["status"]["name"] ==
                                        "REJECTED")
                                    ? const Color(0xffff88bb)
                                    : const Color(0xffbeff80),
                          ),
                          child: Center(
                            child: Text(
                              userDrafts.value[i]["status"]["name"],
                              textAlign: TextAlign.left,
                              textScaleFactor: 1,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
    );
  }
}

class LiveCampaigns extends HookConsumerWidget {
  const LiveCampaigns({
    super.key,
    required this.id,
    required this.brandId,
  });
  final String id;
  final String brandId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CusApiReq apiReq = CusApiReq();

    ValueNotifier<List> campdraft = useState<List>([]);

    ValueNotifier<bool> isLoading = useState<bool>(false);

    final campaignInfoStateW = ref.watch(campaignInfoState);

    final userStateW = ref.watch(userState);

    init() async {
      isLoading.value = true;
      final req = {
        "search": {
          "fromUser": await userStateW.getUserId(),
          "campaign": id,
          "influencer": await userStateW.getUserId(),
          "status": 3,
        },
      };
      final infdata =
          await apiReq.postApi2(jsonEncode(req), path: "/api/search-draft");
      campdraft.value = infdata[0]["data"];

      campaignInfoStateW.setLinkBox(List.filled(campdraft.value.length, false));
      campaignInfoStateW.setTextController(List.filled(
        campdraft.value.length,
        TextEditingController(),
      ));
      campaignInfoStateW.setError(List.filled(
        campdraft.value.length,
        false,
      ));

      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);

    return isLoading.value
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : campdraft.value.isEmpty
            ? const Text(
                "You haven't created any draft yet. or it's not accepted.",
                textScaleFactor: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < campdraft.value.length; i++) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(10),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                height: 20,
                                width: 20,
                                imageUrl: campdraft.value[i]["handle"]
                                    ["platform"]["logo"],
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/images/user.png",
                                  fit: BoxFit.cover,
                                ),
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                campdraft.value[i]["handle"]["name"],
                                textScaleFactor: 1,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: blackC,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (campdraft.value[i]["linkCampaign"] == null ||
                              campdraft.value[i]["linkCampaign"] == "") ...[
                            if (campaignInfoStateW.linkBox[i]) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: TextFormField(
                                    controller:
                                        campaignInfoStateW.textController[i],
                                    onChanged: (value) {
                                      campaignInfoStateW.setBrand(value);
                                    },
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Color(0xfff3f4f6),
                                      hintText: "Link of the campaign...",
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              if (campaignInfoStateW.error[i]) ...[
                                const Text(
                                  "Fill the link",
                                  textScaleFactor: 1,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xfffbca8e),
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  onPressed: () async {
                                    isLoading.value = true;
                                    campaignInfoStateW.setErrorValue(false, i);
                                    if (campaignInfoStateW
                                            .textController[i].text.isEmpty ||
                                        campaignInfoStateW
                                                .textController[i].text ==
                                            "") {
                                      campaignInfoStateW.setErrorValue(true, i);
                                    } else {
                                      final resdata = await apiReq.postApi2(
                                          jsonEncode({
                                            "id": campdraft.value[i]["id"]
                                                .toString(),
                                            "linkCampaign": campaignInfoStateW
                                                .textController[i].text
                                          }),
                                          path: "/api/update-draft");

                                      if (resdata[0]["status"]) {
                                        campaignInfoStateW.setErrorValue(
                                            false, i);
                                        campaignInfoStateW.setLinkBoxValue(
                                            false, i);
                                        await init();
                                      }
                                    }
                                    isLoading.value = false;
                                  },
                                  child: const Text("Link"),
                                ),
                              ),
                            ] else ...[
                              SizedBox(
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xfffbca8e),
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  onPressed: () {
                                    campaignInfoStateW.setLinkBoxValue(true, i);
                                  },
                                  child: const Text("Link campaign"),
                                ),
                              ),
                            ],
                          ] else ...[
                            SizedBox(
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xfffbca8e),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MoreCampInfo(
                                        brandId: brandId,
                                        campId: id,
                                        draftId: campdraft.value[i]["id"],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "View insight",
                                  textScaleFactor: 1,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    )
                  ]
                ],
              );
  }
}

class PandingPaymentRequest extends HookConsumerWidget {
  const PandingPaymentRequest({
    super.key,
    required this.id,
    required this.userId,
  });
  final String id;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<List> playmentReq = useState<List>([]);
    CusApiReq apiReq = CusApiReq();
    ValueNotifier<String> currencycode = useState("");

    void init() async {
      final req = {
        "search": {"campaign": id, "influencer": userId}
      };

      // id, influencer, campaign, brandUser
      List payments =
          await apiReq.postApi2(jsonEncode(req), path: "/api/get-req-pay");
      if (payments[0]["status"]) {
        playmentReq.value = payments[0]["data"];
      }
      // currencycode.value = await userStateW.getCurrencyCode();
      currencycode.value = "USD";
    }

    useEffect(() {
      init();
      return null;
    }, []);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (playmentReq.value.isEmpty) ...[
          const SizedBox(
            height: 20,
          ),
          const WarningAlart(
            message: "No payment request pending.",
          )
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (int i = 0; i < playmentReq.value.length; i++) ...[
                Container(
                  width: 280,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                                imageUrl: playmentReq.value[i]["influencer"]
                                    ["pic"],
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                playmentReq.value[i]["influencer"]["name"]
                                    .split("@")[0],
                                textAlign: TextAlign.left,
                                textScaleFactor: 1,
                                style: const TextStyle(
                                    color: blackC,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                playmentReq.value[i]["influencer"]["email"],
                                textAlign: TextAlign.left,
                                textScaleFactor: 1,
                                style: const TextStyle(
                                    color: blackC,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      const Text(
                        "Requested Amount",
                        textAlign: TextAlign.left,
                        textScaleFactor: 1,
                        style: TextStyle(
                            color: blackC,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${playmentReq.value[i]["amount"].toString().split('.')[0]} ${currencycode.value}",
                        textAlign: TextAlign.left,
                        textScaleFactor: 1,
                        style: const TextStyle(
                          color: blackC,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (int.parse(playmentReq.value[i]["status"]["code"]) ==
                          2) ...[
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
                      ] else if (int.parse(
                              playmentReq.value[i]["status"]["code"]) ==
                          3) ...[
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
        ),
      ],
    );
  }
}

class BidSnapshot extends HookConsumerWidget {
  final String userid;
  final String campaignid;
  const BidSnapshot({
    super.key,
    required this.campaignid,
    required this.userid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CusApiReq apiReq = CusApiReq();

    ValueNotifier<List> bidding = useState<List>([]);
    init() async {
      final biddata = await apiReq.postApi(
          jsonEncode({"campaignId": campaignid}),
          path: "/api/get-bid");

      bidding.value =
          biddata[0]["data"].where((val) => val['userId'] == userid).toList();
    }

    useEffect(() {
      init();
      return null;
    }, []);

    final width = MediaQuery.of(context).size.width;

    return bidding.value.isEmpty
        ? Container()
        : Container(
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 15),
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
                        "Latest bid",
                        textAlign: TextAlign.left,
                        textScaleFactor: 1,
                        style: TextStyle(
                            color: blackC,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
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
                      for (int i = 0; i < bidding.value.length; i++) ...[
                        Container(
                          width: 250,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: blackC.withOpacity(0.1),
                                  blurRadius: 6),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                child: Row(
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
                                            imageUrl: bidding.value[i]
                                                ["userPicUrl"],
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
                                              fit: BoxFit.cover,
                                            ),
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Text(
                                        bidding.value[i]["userName"],
                                        textAlign: TextAlign.left,
                                        textScaleFactor: 1,
                                        style: const TextStyle(
                                            color: blackC,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                "Message",
                                textAlign: TextAlign.left,
                                textScaleFactor: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: blackC,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                bidding.value[i]["remark"],
                                textAlign: TextAlign.left,
                                textScaleFactor: 1,
                                style: const TextStyle(
                                    fontSize: 14, color: blackC),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "Payment",
                                textAlign: TextAlign.left,
                                textScaleFactor: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: blackC,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                bidding.value[i]["bidamount"],
                                textAlign: TextAlign.left,
                                textScaleFactor: 1,
                                style: const TextStyle(
                                    fontSize: 14, color: blackC),
                              ),
                            ],
                          ),
                        )
                      ],
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
