// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swrv/view/campaings/mycompaign.dart';
import 'package:swrv/view/user/myaccount.dart';
import 'package:swrv/view/user/useredit/usereditone.dart';

import '../../state/userstate.dart';
import '../../utils/alerts.dart';
import '../../utils/utilthemes.dart';
import '../../widgets/alerts.dart';
import '../../widgets/componets.dart';
import '../home/earnings.dart';
import '../home/help.dart';
import '../home/home.dart';
import '../navigation/bottomnavbar.dart';
import '../navigation/drawer.dart';
import 'invitetobrand.dart';

class Profile extends HookConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<ScaffoldState> scaffoldKey =
        useMemoized(() => GlobalKey<ScaffoldState>());
    ValueNotifier<SharedPreferences?> prefs = useState(null);
    final userStateW = ref.watch(userState);
    ValueNotifier<String> userName = useState("loading...");
    ValueNotifier<String> nickname = useState("loading...");
    ValueNotifier<String> userAvatar = useState("");
    ValueNotifier<bool> isBrand = useState(false);
    ValueNotifier<bool> isProfileCompleted = useState(false);

    TextEditingController resetpass = useTextEditingController();

    void init() async {
      prefs.value = await SharedPreferences.getInstance();
      userName.value = await userStateW.getUserName();
      userAvatar.value = await userStateW.getUserAvatar();
      nickname.value = await userStateW.getNickname();
      isBrand.value = await userStateW.isBrand();
      isProfileCompleted.value = await userStateW.isProfileCompleted();
    }

    useEffect(() {
      init();
      return;
    }, []);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false);
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Header(
                  isShowUser: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 10),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              width: 100,
                              height: 100,
                              child: userAvatar.value == "" ||
                                      userAvatar.value == "0"
                                  ? Image.asset(
                                      "assets/images/user.png",
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: userAvatar.value,
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
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    userName.value.split("@")[0],
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  nickname.value,
                                  textScaleFactor: 1,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black.withOpacity(0.75)),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final res = await userStateW.isProfileCompleted();

                              if (res) {
                                // if (isBrand.value) {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => const BrandEditOne(),
                                //     ),
                                //   );
                                // } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserEditOne(),
                                  ),
                                );
                                // }
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
                            child: Icon(
                              Icons.edit_outlined,
                              color: Colors.black.withOpacity(0.85),
                              size: 30,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Dashboard",
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.75)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyCampaings(),
                            ),
                          );
                          // ref.watch(pageIndex.state).state = 26;
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff5eead4),
                                ),
                                width: 45,
                                height: 45,
                                child: const Icon(
                                  Icons.people_alt_outlined,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Campaigns",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black.withOpacity(0.65),
                                size: 25,
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EarningsPage(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xfffdba74)),
                                width: 45,
                                height: 45,
                                child: const Icon(
                                  Icons.wallet_giftcard_outlined,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black.withOpacity(0.65),
                                size: 25,
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpPage(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff60a5fa)),
                                width: 45,
                                height: 45,
                                child: const Icon(
                                  Icons.laptop_chromebook_outlined,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              const Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Privacy",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black.withOpacity(0.65),
                                size: 25,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          final userId = await userStateW.getUserId();
                          if (isProfileCompleted.value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => MyAccount(
                                      id: userId,
                                      isSendMsg: false,
                                    )),
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
                              "Uncompleted",
                              "Please first complete your profile first...",
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "My account",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.75)),
                          ),
                        ),
                      ),
                      if (isBrand.value) ...[
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InviteToBrand(),
                                ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              "Invite Users",
                              textScaleFactor: 1,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.75),
                              ),
                            ),
                          ),
                        ),
                      ],
                      InkWell(
                        onTap: () async {
                          resetPassAlert(context, resetpass, ref);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "Change Password",
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          logoutAlert(context, ref);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            "Log Out",
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.red.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ),
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
