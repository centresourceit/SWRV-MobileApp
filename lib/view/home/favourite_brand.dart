import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:swrv/database/database.dart';
import 'package:swrv/database/models/favoritebrand.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/widgets/buttons.dart';

import '../../widgets/alerts.dart';
import '../../widgets/componets.dart';
import '../brand/brandinfo.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';

class FavouriteBrand extends HookConsumerWidget {
  const FavouriteBrand({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());
    final width = MediaQuery.of(context).size.width;

    ValueNotifier<List> fav = useState([]);

    ValueNotifier<List<int>> delfav = useState([]);

    void init() async {
      final getfav = await isarDB.favoriteBrands.where().findAll();
      fav.value = getfav;

      List<int> data = [];

      for (int i = 0; i < fav.value.length; i++) {
        data.add(fav.value[i].id);
      }
      delfav.value = data;
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
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(
                height: 20,
              ),
              if (fav.value.isEmpty) ...[
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
                        message: "No favourite brand Found")),
              ] else ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Favourite brand",
                            textScaleFactor: 1,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: blackC),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 100,
                            child: CusBtn(
                              btnColor: primaryC,
                              btnText: "Remove All",
                              textSize: 14,
                              btnFunction: () async {
                                removeFavBrand(context, delfav.value);
                              },
                            ),
                          ),
                        ],
                      ),
                      for (int i = 0; i < fav.value.length; i++) ...[
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BrandInfo(
                                  id: fav.value[i].brandid,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: whiteC,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 5),
                              ],
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  margin: const EdgeInsets.all(5.0),
                                  width: 50,
                                  height: 50,
                                  child: CachedNetworkImage(
                                    imageUrl: fav.value[i].img,
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
                              title: Text(
                                fav.value[i].name,
                                textScaleFactor: 1,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              trailing: const Icon(
                                Icons.favorite,
                                size: 30,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ],
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
