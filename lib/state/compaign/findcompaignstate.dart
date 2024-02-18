// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/state/userstate.dart';

import '../../services/apirequest.dart';
import '../../utils/alerts.dart';

final findCampState =
    ChangeNotifierProvider<FindCampState>((ref) => FindCampState());

class FindCampState extends ChangeNotifier {
  CusApiReq apiReq = CusApiReq();
  UserState userState = UserState();
  bool isActiveChamp = false;
  bool isSearch = false;
  bool isAdvance = false;
  List searchData = [];
  List filterlist = [];
  String? filtervalue;

  void setIsSearch(bool val) {
    isSearch = val;
    notifyListeners();
  }

  void setIsAdvance(bool val) {
    isAdvance = val;
    notifyListeners();
  }

  void setSearchData(List data) {
    searchData = data;
    notifyListeners();
  }

  bool isBrand = false;

  void setIsActive(bool val) {
    isActiveChamp = val;
    notifyListeners();
  }

  void setIsBrand(bool val) {
    isBrand = val;
    notifyListeners();
  }

  List platforms = [];
  List selectedPlatfomrs = [];
  List selectedPlatfomrsList = [];

  void setPlatforms(List data) {
    platforms = data;
    for (int i = 0; i < data.length; i++) {
      selectedPlatfomrs.add(false);
    }
    notifyListeners();
  }

  void togglePlatfroms(int val) {
    selectedPlatfomrs[val] = !selectedPlatfomrs[val];
    if (selectedPlatfomrsList.contains(platforms[val]["id"])) {
      selectedPlatfomrsList.remove(platforms[val]["id"]);
    } else {
      selectedPlatfomrsList.add(platforms[val]["id"]);
    }
    notifyListeners();
  }

  String? cmpValue;
  String? cmpId;
  List cmpList = [];

  void setCmp(List data) {
    cmpList = data;
    notifyListeners();
  }

  void setCmpId(int id) {
    cmpId = cmpList[id]["id"];
    notifyListeners();
  }

  void setCmpValue(String val) {
    cmpValue = val;
    notifyListeners();
  }

  String? cityValue;

  void setCityValue(String? val) {
    cityValue = val;
    notifyListeners();
  }

  List cityList = [];
  List selectedCity = [];
  List cityVal = [];

  void setCityList(List data) {
    cityList = data;
    for (int i = 0; i < data.length; i++) {
      selectedCity.add(false);
    }
    notifyListeners();
  }

  void setCity(int index, bool value) {
    for (int i = 0; i < selectedCity.length; i++) {
      selectedCity[i] = false;
    }
    selectedCity[index] = value;
    if (value) {
      cityVal = [cityList[index]];
    } else {
      cityVal = [];
    }
    notifyListeners();
  }

  void resetCitySelection() {
    for (int i = 0; i < selectedCity.length; i++) {
      selectedCity[i] = false;
    }
    cityVal = [];
    cityValue = null;
    notifyListeners();
  }

  Future<List> startSeatch(BuildContext context) async {
    final dynamic req = {"active": isActiveChamp ? "1" : "0"};

    if (selectedPlatfomrsList.isNotEmpty) {
      req["platform"] = selectedPlatformList();
    } else if (cmpId != null) {
      req["category"] = cmpId;
    } else if (cityVal.isEmpty) {
      req["city"] = cityVal[0]["id"].toString();
    }

    List data =
        await apiReq.postApi(jsonEncode(req), path: "/api/campaign-search");

    if (data[0] == false) {
      erroralert(
        context,
        "Error",
        data[1].toString(),
      );
    } else if (data[0]["status"] == false) {
      erroralert(
        context,
        "Error",
        data[0]["message"],
      );
    } else {
      notifyListeners();
      return [jsonEncode(data[0]["data"])];
    }

    notifyListeners();
    return [false];
  }

  Future<void> saveFilter(BuildContext context, String filter) async {
    if (selectedPlatfomrsList.isEmpty) {
      erroralert(context, "Error", "Please Select platform");
    } else if (cmpId == null) {
      erroralert(context, "Error", "Please Select category");
    } else if (cityVal.isEmpty) {
      erroralert(context, "Error", "Please Select city");
    } else {
      Map data = {
        "category": cmpId,
        "platform": selectedPlatformList(),
        "city": cityVal[0]["id"].toString(),
        "active": isActiveChamp ? "1" : "0",
      };

      var req = {
        "userId": await userState.getUserId(),
        "name": filter,
        "type": 4.toString(),
        "data": jsonEncode(data).toString()
      };
      final filterdata =
          await apiReq.postApi(jsonEncode(req), path: "/api/add-filter");

      if (filterdata[0] == false) {
        erroralert(
          context,
          "Error",
          filterdata[1].toString(),
        );
      } else if (filterdata[0]["status"] == false) {
        erroralert(
          context,
          "Error",
          filterdata[0]["message"],
        );
      } else {
        await loadFilter(context);
        susalert(context, "Saved", "successfully Saved the filter");
      }
    }
    notifyListeners();
  }

  void setFilterValue(String val) {
    filtervalue = val;
    notifyListeners();
  }

  Future<void> loadFilter(BuildContext context) async {
    var req = {
      "userId": await userState.getUserId(),
      "type": 4.toString(),
    };
    final filterdata =
        await apiReq.postApi(jsonEncode(req), path: "/api/get-filter");

    if (filterdata[0] == false) {
      erroralert(
        context,
        "Error",
        filterdata[1].toString(),
      );
    } else if (filterdata[0]["status"] == false) {
      erroralert(
        context,
        "Error",
        filterdata[0]["message"],
      );
    } else {
      filterlist = filterdata[0]["data"];
    }
    notifyListeners();
  }

  Future<List> loadFromFilter(BuildContext context, dynamic filter) async {
    List data = await apiReq.postApi(jsonEncode(filter["data"]),
        path: "/api/campaign-search");

    if (data[0] == false) {
      erroralert(
        context,
        "Error",
        data[1].toString(),
      );
    } else if (data[0]["status"] == false) {
      erroralert(
        context,
        "Error",
        data[0]["message"],
      );
    } else {
      notifyListeners();
      return [jsonEncode(data[0]["data"])];
    }
    notifyListeners();
    return [false];
  }

  Future<List> textSearch(
      BuildContext context,
      String text,
      String minReact,
      String maxReact,
      String costPerPost,
      String minTarget,
      String totalTarget) async {
    final Map<String, dynamic> req = {"complete": "true", "isPublic": "1"};

    if (text != "") {
      req["name"] = text;
    }
    if (minReact != "") {
      req["minReach"] = minReact;
    }
    if (maxReact != "") {
      req["maxReach"] = maxReact;
    }
    if (costPerPost != "") {
      req["costPerPost"] = costPerPost;
    }
    if (minTarget != "") {
      req["minTarget"] = minTarget;
    }
    if (totalTarget != "") {
      req["totalTarget"] = totalTarget;
    }

    List data =
        await apiReq.postApi(jsonEncode(req), path: "/api/campaign-search");

    if (data[0] == false) {
      erroralert(
        context,
        "Error",
        data[1].toString(),
      );
    } else if (data[0]["status"] == false) {
      erroralert(
        context,
        "Error",
        data[0]["message"],
      );
    } else {
      notifyListeners();
      return [jsonEncode(data[0]["data"])];
    }

    notifyListeners();
    return [false];
  }

  String selectedPlatformList() {
    String res = "";
    for (int i = 0; i < selectedPlatfomrsList.length; i++) {
      if (i == (selectedPlatfomrsList.length - 1)) {
        res += "${selectedPlatfomrsList[i]}";
      } else {
        res += "${selectedPlatfomrsList[i]},";
      }
    }

    return res;
  }

  void clear() {
    isActiveChamp = false;
    for (int i = 0; i < selectedPlatfomrs.length; i++) {
      selectedPlatfomrs[i] = false;
    }

    selectedPlatfomrsList = [];
    cmpValue = null;
    cmpId = null;

    cityValue = null;

    isSearch = false;
    searchData = [];

    notifyListeners();
  }
}
