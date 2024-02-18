import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/view/home/search.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/apirequest.dart';
import '../../state/userstate.dart';
import '../../widgets/componets.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';

class EarningsPage extends HookConsumerWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                      fontSize: 20, fontWeight: FontWeight.w800, color: blackC),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 25, top: 10),
                child: Text(
                  "Here you can manage all the\ncampaign that you are participating in.",
                  textScaleFactor: 1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400, color: blackC),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Search()),
                      (route) => false);
                },
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.all(15),
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
                      const SizedBox(
                        height: 40,
                      ),
                      Icon(
                        CupertinoIcons.search,
                        color: blackC.withOpacity(0.65),
                        size: 50,
                      ),
                      const Text(
                        "To earn more money?",
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: blackC),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Search, apply for public campaigns and create more great content",
                        textScaleFactor: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: blackC.withOpacity(0.55)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const GraphStatus(),
              const PaymentStatus(),
              const SizedBox(
                height: 80,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GraphStatus extends HookConsumerWidget {
  const GraphStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<List> graphStatus = useState<List>([]);

    final userStateW = ref.watch(userState);
    ValueNotifier<bool> isLoading = useState(true);
    CusApiReq apiReq = CusApiReq();
    final width = MediaQuery.of(context).size.width;

    void init() async {
      final req = {
        "userId": await userStateW.getUserId(),
      };

      dynamic data =
          await apiReq.postApi2(jsonEncode(req), path: "/api/payment-graph");
      graphStatus.value = data[0]["data"];
      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);

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
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: whiteC,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "Month wise revenue",
                  textScaleFactor: 1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: secondaryC,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (graphStatus.value.isNotEmpty) ...[
                  SizedBox(
                    height: 400,
                    child: BarChart(
                      BarChartData(
                          // gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          titlesData: FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              // leftTitles: AxisTitles(
                              //   sideTitles: SideTitles(showTitles: true),
                              // ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) =>
                                          SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      "${value.toString().split(".")[0]}-${DateTime.now().year}",
                                      textScaleFactor: 1,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                          barGroups: graphStatus.value
                              .map(
                                (value) => BarChartGroupData(
                                  x: int.parse(value["month"]),
                                  barRods: [
                                    BarChartRodData(
                                      toY: double.parse(value["total_earning"]),
                                      color: const Color(
                                        0xff82cdff,
                                      ),
                                      width: 20,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              )
                              .toList()),
                      swapAnimationDuration:
                          const Duration(milliseconds: 150), // Optional
                      swapAnimationCurve: Curves.linear, // Optional
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ] else ...[
                  const Text(
                    "There is nothing to show.",
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}

class PaymentStatus extends HookConsumerWidget {
  const PaymentStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<List> paymetStatus = useState<List>([]);

    final userStateW = ref.watch(userState);
    ValueNotifier<bool> isLoading = useState(true);
    CusApiReq apiReq = CusApiReq();
    final width = MediaQuery.of(context).size.width;

    void init() async {
      final req = {
        "userId": await userStateW.getUserId(),
      };

      dynamic data =
          await apiReq.postApi2(jsonEncode(req), path: "/api/payment-status");
      paymetStatus.value = data[0]["data"];
      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);

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
            width: width,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(
              color: whiteC,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "Brand wise revenue",
                  textScaleFactor: 1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: secondaryC,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (paymetStatus.value.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: backgroundC,
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 5),
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
                                  "Brand",
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
                                width: 200,
                                child: Text(
                                  "Campaign Name",
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
                                width: 120,
                                child: Text(
                                  "Earning",
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
                                width: 140,
                                child: Text(
                                  "Date",
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
                        for (int i = 0; i < paymetStatus.value.length; i++) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CachedNetworkImage(
                                      imageUrl: paymetStatus.value[i]
                                          ["brandLogoUrl"],
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
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    paymetStatus.value[i]["brandName"]
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
                                  width: 200,
                                  child: Text(
                                    paymetStatus.value[i]["campaign_name"]
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
                                  width: 120,
                                  child: Text(
                                    paymetStatus.value[i]
                                            ["total_amount_requested"]
                                        .toString()
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
                                  width: 140,
                                  child: Text(
                                    timeago
                                        .format(
                                          DateTime.now().subtract(
                                            Duration(
                                              days: int.parse(
                                                paymetStatus.value[i]
                                                    ["days_since_payment_made"],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toString(),
                                    // paymetStatus.value[i]
                                    //     ["days_since_payment_made"],
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
                  const Text(
                    "There is nothing to show.",
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}
