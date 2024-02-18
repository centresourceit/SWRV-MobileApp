// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/widgets/componets.dart';

import '../../services/apirequest.dart';
import '../campaings/campaigninfo.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';

class NearCampaign extends HookConsumerWidget {
  const NearCampaign({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());

    ValueNotifier<bool> isLoading = useState(true);
    CusApiReq apiReq = CusApiReq();
    ValueNotifier<List> campaigns = useState<List>([]);

    Future<Position> getCurrentLocation() async {
      LocationPermission permission;

      // Request location permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permission is denied forever, handle accordingly
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        // Permission is denied, request permissions
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // Permission is denied, handle accordingly
          return Future.error('Location permissions are denied.');
        }
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition();
      return position;
    }

    void init() async {
      final pos = await getCurrentLocation();
      List champaign = await apiReq.postApi2(
          jsonEncode({"lat": pos.latitude, "long": pos.longitude}),
          path: "/api/geofencing-campaign");
      if (champaign[0]["status"]) {
        campaigns.value = champaign[0]["data"];
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
                  "Campaign near you",
                  textScaleFactor: 1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: blackC,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 25, top: 10),
                child: Text(
                  "The Campaign near you.",
                  textScaleFactor: 1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400, color: blackC),
                ),
              ),
              if (isLoading.value) ...[
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ] else ...[
                const SizedBox(
                  height: 10,
                ),
                if (campaigns.value.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    width: width,
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red)),
                    child: const Text(
                      "There is no campaigns near you.",
                      textScaleFactor: 1,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ] else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: width,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          for (int i = 0; i < campaigns.value.length; i++) ...[
                            MiniCard(
                              imgUrl: campaigns.value[i]["brandLogoUrl"],
                              title: campaigns.value[i]["brandName"],
                              btnColor: const Color(0xfffbc98e),
                              btnText: "Learn more & apply",
                              btnFunction: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChampignInfo(
                                      id: campaigns.value[i]["id"],
                                    ),
                                  ),
                                );
                              },
                              name:
                                  "Campaign Name: ${campaigns.value[i]["campaignName"]}",
                              info:
                                  "Campaign Info: ${campaigns.value[i]["campaignInfo"]}",
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ]
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
