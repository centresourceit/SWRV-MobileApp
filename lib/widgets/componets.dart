// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/utils/utilsmethods.dart';
import 'package:swrv/utils/utilthemes.dart';
import 'package:swrv/widgets/buttons.dart';

import '../state/notificatoinstata.dart';
import '../state/userstate.dart';
import '../view/home/home.dart';
import '../view/notifications/notifications.dart';

class HomeCard extends HookConsumerWidget {
  final String title;
  final String champname;
  final String imgUrl;
  final Color btnColor;
  final String btnText;
  final Function btnFunction;
  final String website;
  final int category;
  final bool isHeart;
  final String currency;
  final String amount;
  final List platforms;
  final bool networkImg;
  const HomeCard({
    super.key,
    required this.title,
    required this.champname,
    required this.imgUrl,
    required this.btnColor,
    required this.btnText,
    required this.btnFunction,
    required this.website,
    required this.category,
    required this.currency,
    required this.amount,
    required this.platforms,
    this.isHeart = true,
    this.networkImg = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<String> campType = useState("Unboxing");
    ValueNotifier<Color> typeColor = useState(Colors.lightBlueAccent);
    useEffect(() {
      if (category == 1) {
        campType.value = "Unboxing";
        typeColor.value = Colors.lightBlueAccent;
      } else if (category == 2) {
        campType.value = "Sponsored";
        typeColor.value = Colors.indigo;
      } else if (category == 3) {
        campType.value = "Paid Promotion";
        typeColor.value = Colors.red;
      } else if (category == 4) {
        campType.value = "Revealing";
        typeColor.value = Colors.green;
      } else if (category == 5) {
        campType.value = "Campaign";
        typeColor.value = Colors.yellow;
      } else if (category == 6) {
        campType.value = "Bidding";
        typeColor.value = Colors.blue;
      }
      return null;
    }, []);

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
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
                    child: networkImg
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/user.png",
                              fit: BoxFit.cover,
                            ),
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            imgUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    longtext(title, 15),
                    textAlign: TextAlign.left,
                    textScaleFactor: 1,
                    style: GoogleFonts.openSans(
                      color: blackC,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isHeart) ...[
                  const SizedBox(
                    height: 60,
                    child: FaIcon(CupertinoIcons.heart_fill, color: Colors.red),
                  )
                ],
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            longtext(champname, 22),
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: blackC,
            ),
          ),
          RichText(
            text: TextSpan(
              text: 'Budget: ',
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: blackC,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: "$amount USD",
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Category : ${campType.value}",
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: GoogleFonts.openSans(fontSize: 14, color: blackC),
          ),
          Text(
            website,
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: GoogleFonts.openSans(fontSize: 14, color: blackC),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            thickness: 2,
          ),
          Text(
            "Platforms",
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: GoogleFonts.openSans(fontSize: 14, color: blackC),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    for (int i = 0; i < platforms.length; i++) ...[
                      if (i < 4) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: whiteC,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: platforms[i],
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/images/instagram.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                    if (platforms.length > 4) ...[
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xffeeeeee),
                        child: Text(
                          "+${platforms.length - 4}",
                          textScaleFactor: 1,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: blackC,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          CusBtn(
            btnColor: btnColor,
            btnText: btnText,
            textSize: 18,
            btnFunction: btnFunction,
            textColor: blackC,
          )
        ],
      ),
    );
  }
}

class Header extends HookConsumerWidget {
  final bool isShowUser;
  const Header({Key? key, this.isShowUser = true}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateW = ref.watch(userState);
    ValueNotifier<String> userName = useState("loading...");
    ValueNotifier<String> userAvatar = useState("");

    void init() async {
      userName.value = await userStateW.getUserName();
      userAvatar.value = await userStateW.getUserAvatar();
    }

    useEffect(() {
      init();
      return null;
    }, []);
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: ((context) => const HomePage()),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: SizedBox(
              width: 100,
              child: Image.asset(
                "assets/images/logo.png",
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              await ref.watch(notificationState).initnotificaions();
              List noti = ref.watch(notificationState).notifications;
              notificationsAlert(context, noti);
            },
            child: const FaIcon(
              FontAwesomeIcons.solidBell,
              color: secondaryC,
            ),
          ),
          if (isShowUser) ...[
            const SizedBox(
              width: 10,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                width: 35,
                height: 35,
                child: userAvatar.value == "" || userAvatar.value == "0"
                    ? Image.asset(
                        "assets/images/user.png",
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: userAvatar.value,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              userName.value.toString().split("@")[0],
              textScaleFactor: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: blackC,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ],
      ),
    );
  }
}

class MiniCard extends HookConsumerWidget {
  final String title;
  final String imgUrl;
  final Color btnColor;
  final String btnText;
  final Function btnFunction;
  final String info;
  final String name;
  final bool networkImg;

  const MiniCard({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.btnColor,
    required this.btnText,
    required this.btnFunction,
    required this.info,
    required this.name,
    this.networkImg = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
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
                    child: networkImg
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/user.png",
                              fit: BoxFit.cover,
                            ),
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            imgUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Text(
                    title,
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
            height: 20,
          ),
          Text(
            name,
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: blackC),
          ),
          Text(
            info,
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: const TextStyle(fontSize: 14, color: blackC),
          ),
          const SizedBox(
            height: 10,
          ),
          CusBtn(
            btnColor: btnColor,
            btnText: btnText,
            textSize: 18,
            btnFunction: btnFunction,
            textColor: blackC,
          )
        ],
      ),
    );
  }
}

class BrandCard extends HookConsumerWidget {
  final String title;
  final String imgUrl;
  final Color btnColor;
  final String btnText;
  final Function btnFunction;
  final String website;
  final String email;
  final bool networkImg;
  const BrandCard({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.btnColor,
    required this.btnText,
    required this.btnFunction,
    required this.website,
    required this.email,
    this.networkImg = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
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
                    child: networkImg
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/user.png",
                              fit: BoxFit.cover,
                            ),
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            imgUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Text(
                  longtext(title, 15),
                  textAlign: TextAlign.left,
                  textScaleFactor: 1,
                  style: GoogleFonts.openSans(
                    color: blackC,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            email,
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: GoogleFonts.openSans(fontSize: 14, color: blackC),
          ),
          Text(
            website,
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: GoogleFonts.openSans(fontSize: 14, color: blackC),
          ),
          const SizedBox(
            height: 8,
          ),
          CusBtn(
            btnColor: btnColor,
            btnText: btnText,
            textSize: 18,
            btnFunction: btnFunction,
            textColor: blackC,
          )
        ],
      ),
    );
  }
}

class UserCard extends HookConsumerWidget {
  final String title;
  final String champname;
  final String imgUrl;
  final Color btnColor;
  final String btnText;
  final Function btnFunction;
  final String website;
  const UserCard({
    super.key,
    required this.title,
    required this.champname,
    required this.imgUrl,
    required this.btnColor,
    required this.btnText,
    required this.btnFunction,
    required this.website,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
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
                      imageUrl: imgUrl,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
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
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Text(
                    title,
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
            height: 20,
          ),
          Text(
            champname,
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: blackC,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            website,
            textAlign: TextAlign.left,
            textScaleFactor: 1,
            style: const TextStyle(fontSize: 14, color: blackC),
          ),
          const SizedBox(
            height: 10,
          ),
          CusBtn(
            btnColor: btnColor,
            btnText: btnText,
            textSize: 18,
            btnFunction: btnFunction,
            textColor: blackC,
          )
        ],
      ),
    );
  }
}
