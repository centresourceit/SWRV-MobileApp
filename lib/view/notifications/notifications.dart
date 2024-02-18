import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/utilthemes.dart';

void notificationsAlert(BuildContext context, List notificaions) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        contentPadding: const EdgeInsets.all(5),
        backgroundColor: whiteC,
        scrollable: true,
        alignment: Alignment.topCenter,
        content: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Notifications",
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blackC.withOpacity(0.85),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const FaIcon(
                      FontAwesomeIcons.xmark,
                      color: blackC,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              for (int i = 0; i < notificaions.length; i++) ...[
                NotificationBox(
                  image: notificaions[i]["brand"]["logo"],
                  title: notificaions[i]["brand"]["name"],
                  subtitle:
                      "Your campaign draft request is ${notificaions[i]["status"]["name"]}.",
                ),
              ]
            ],
          ),
        ),
      ),
    ),
  );
}

class NotificationBox extends HookConsumerWidget {
  final String image;
  final String title;
  final String subtitle;

  const NotificationBox({
    super.key,
    required this.image,
    required this.subtitle,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: blackC.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CachedNetworkImage(
              imageUrl: image,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Image.asset(
                "assets/images/user.png",
                fit: BoxFit.cover,
              ),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  textScaleFactor: 1,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: blackC.withOpacity(0.85),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  subtitle,
                  textScaleFactor: 1,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: blackC.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
