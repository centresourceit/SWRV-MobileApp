import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/state/userstate.dart';

import '../services/apirequest.dart';

final notificationState = ChangeNotifierProvider<NotificationState>(
  (ref) => NotificationState(),
);

class NotificationState extends ChangeNotifier {
  List notifications = [];
  CusApiReq apiReq = CusApiReq();
  UserState user = UserState();

  Future<void> initnotificaions() async {
    final req = {
      "search": {
        "influencer": await user.getUserId(),
        "status": 3,
      },
    };
    final infdata =
        await apiReq.postApi2(jsonEncode(req), path: "/api/search-draft");

    notifications = infdata[0]["data"];
    notifyListeners();
  }
}
