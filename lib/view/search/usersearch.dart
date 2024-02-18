// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/view/user/myaccount.dart';

import '../../services/apirequest.dart';
import '../../state/influencer/findinfluencerstate.dart';
import '../../utils/alerts.dart';
import '../../utils/utilthemes.dart';
import '../../widgets/alerts.dart';
import '../../widgets/componets.dart';

class AdvanceInfSearch extends HookConsumerWidget {
  const AdvanceInfSearch({super.key, this.isTextSearch = true});
  final bool isTextSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    CusApiReq apiReq = CusApiReq();

    final findInfStateW = ref.watch(findInfState);
    TextEditingController filter = useTextEditingController();
    TextEditingController citySearch = useTextEditingController();
    void init() async {
      List platforms =
          await apiReq.postApi(jsonEncode({}), path: "/api/getplatform");

      List category =
          await apiReq.postApi(jsonEncode({}), path: "api/getcategory");

      if (platforms[0]["status"] && category[0]["status"]) {
        findInfStateW.setPlatforms(platforms[0]["data"]);

        findInfStateW.setCmp(category[0]["data"]);
      } else {
        erroralert(context, "error", "No Record Fount");
      }
    }

    useEffect(() {
      init();
      return null;
    }, []);

    void cityBox() {
      showModalBottomSheet(
        backgroundColor: whiteC,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                      child: Text(
                    "City",
                    textScaleFactor: 1,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.85),
                    ),
                  )),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0;
                            i < findInfStateW.cityList.length;
                            i++) ...[
                          CheckboxListTile(
                            value: findInfStateW.selectedCity[i],
                            onChanged: (val) {
                              findInfStateW.setCity(i, val!);
                              setState(() {});
                            },
                            title: Text(
                              '${findInfStateW.cityList[i]["name"]}   [ ${findInfStateW.cityList[i]["code"]} ]',
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 0,
                            backgroundColor: const Color(0xffef4444),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Clear",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff22c55e)),
                          onPressed: () {
                            if (findInfStateW.cityVal.isNotEmpty) {
                              findInfStateW.setCityValue(
                                  "${findInfStateW.cityVal[0]["name"]} [${findInfStateW.cityVal[0]["code"]}]");
                            } else {
                              findInfStateW.setCityValue(null);
                            }

                            Navigator.pop(context);
                          },
                          child: const Text(
                            "confirm",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      );
    }

    return Container(
      width: width,
      margin: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: whiteC,
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
          Row(
            children: [
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundC,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  saveIFilterAlert(context, filter, ref);
                },
                child: const Text(
                  "Save filter",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: blackC,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  hint: const Text(
                    "Saved filter",
                    textScaleFactor: 1,
                    style: TextStyle(
                        fontSize: 16,
                        color: blackC,
                        fontWeight: FontWeight.w500),
                  ),
                  buttonDecoration: BoxDecoration(
                    boxShadow: const [],
                    borderRadius: BorderRadius.circular(10),
                    color: backgroundC,
                  ),
                  itemPadding: const EdgeInsets.only(left: 5, right: 5),
                  buttonPadding: const EdgeInsets.only(left: 5, right: 5),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w400),
                  value: findInfStateW.filtervalue,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  items: [
                    for (int i = 0;
                        i < findInfStateW.filterlist.length;
                        i++) ...[
                      DropdownMenuItem(
                        value: findInfStateW.filterlist[i].name,
                        child: InkWell(
                          onTap: () async {
                            final data = await findInfStateW.loadFromFilter(
                                context, findInfStateW.filterlist[i]);
                            if (data[0] != false) {
                              findInfStateW.setIsSearch(true);
                              findInfStateW.setSearchData(jsonDecode(data[0]));

                              susalert(
                                context,
                                "Completed",
                                "Filter loading from saved filter is completed",
                              );
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            findInfStateW.filterlist[i].name,
                            textScaleFactor: 1,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ],
                  onChanged: (newval) {
                    findInfStateW.setFilterValue(newval!);
                  },
                  buttonElevation: 2,
                  itemHeight: 40,
                  dropdownMaxHeight: 200,
                  dropdownPadding: null,
                  isDense: false,
                  dropdownElevation: 8,
                  scrollbarRadius: const Radius.circular(40),
                  scrollbarThickness: 6,
                  scrollbarAlwaysShow: true,
                  offset: const Offset(0, 0),
                  dropdownDecoration: BoxDecoration(
                    color: whiteC,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Select",
              textScaleFactor: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: secondaryC),
            ),
          ),
          if (findInfStateW.cmpList.isEmpty) ...[
            const CircularProgressIndicator(),
          ] else ...[
            SizedBox(
              width: width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  hint: const Text(
                    "Category",
                    textScaleFactor: 1,
                    style: TextStyle(
                        fontSize: 16,
                        color: blackC,
                        fontWeight: FontWeight.w400),
                  ),
                  buttonDecoration: BoxDecoration(
                    boxShadow: const [],
                    borderRadius: BorderRadius.circular(10),
                    color: backgroundC,
                  ),
                  itemPadding: const EdgeInsets.only(left: 20, right: 5),
                  buttonPadding: const EdgeInsets.only(left: 20, right: 5),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w400),
                  value: findInfStateW.cmpValue,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  items: [
                    for (int i = 0; i < findInfStateW.cmpList.length; i++) ...[
                      DropdownMenuItem(
                        onTap: () {
                          findInfStateW.setCmpId(i);
                        },
                        value: findInfStateW.cmpList[i]["categoryName"],
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: blackC.withOpacity(0.25),
                              ),
                            ),
                          ),
                          width: 180,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "[${findInfStateW.cmpList[i]["categoryCode"]}] ${findInfStateW.cmpList[i]["categoryName"]}",
                            textScaleFactor: 1,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                    ]
                  ],
                  onChanged: (newval) {
                    findInfStateW.setCmpValue(newval!);
                  },
                  buttonElevation: 2,
                  itemHeight: 40,
                  dropdownMaxHeight: 250,
                  dropdownPadding: null,
                  isDense: false,
                  dropdownElevation: 8,
                  scrollbarRadius: const Radius.circular(40),
                  scrollbarThickness: 6,
                  scrollbarAlwaysShow: true,
                  offset: const Offset(0, 0),
                  dropdownDecoration: BoxDecoration(
                      color: const Color(0xfffbfbfb),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const []),
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
              "Channels",
              textScaleFactor: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: secondaryC),
            ),
          ),
          if (findInfStateW.platforms.isEmpty ||
              findInfStateW.selectedPlatfomrs.isEmpty) ...[
            const CircularProgressIndicator()
          ] else ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < findInfStateW.platforms.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        findInfStateW.togglePlatfroms(i);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: whiteC,
                          shape: BoxShape.circle,
                          border: findInfStateW.selectedPlatfomrs[i]
                              ? Border.all(color: Colors.blue, width: 2)
                              : Border.all(color: Colors.transparent, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            child: CachedNetworkImage(
                              imageUrl: findInfStateW.platforms[i]
                                  ["platformLogoUrl"],
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
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "City",
              textScaleFactor: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: secondaryC),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                controller: citySearch,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: blackC.withOpacity(0.65),
                  ),
                  suffixIcon: InkWell(
                    onTap: () async {
                      if (citySearch.text.isEmpty || citySearch.text == "") {
                        erroralert(context, "Error",
                            "Please fill this filed before searching");
                      } else {
                        findInfStateW.resetCitySelection();
                        final req = {"search": citySearch.text};
                        List city = await apiReq.postApi(jsonEncode(req),
                            path: "api/get-city");
                        if (city[0]["status"] == false) {
                          erroralert(
                              context, "Error", "No city found with this name");
                        } else {
                          findInfStateW.setCityList(city[0]["data"]);
                          cityBox();
                        }
                      }
                    },
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 25,
                    ),
                  ),
                  filled: true,
                  fillColor: backgroundC,
                  errorBorder: InputBorder.none,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              findInfStateW.cityValue ?? "city is not selected",
              textScaleFactor: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: blackC.withOpacity(
                  0.75,
                ),
              ),
            ),
          ),

          // SizedBox(
          //   width: width,
          //   child: DropdownButtonHideUnderline(
          //     child: DropdownButton2<String>(
          //       hint: const Text(
          //         "City",
          //         textScaleFactor: 1,
          //         style: TextStyle(
          //             fontSize: 16,
          //             color: blackC,
          //             fontWeight: FontWeight.w400),
          //       ),
          //       buttonDecoration: BoxDecoration(
          //         boxShadow: const [],
          //         borderRadius: BorderRadius.circular(10),
          //         color: backgroundC,
          //       ),
          //       itemPadding: const EdgeInsets.only(left: 20, right: 5),
          //       buttonPadding: const EdgeInsets.only(left: 20, right: 5),
          //       style: const TextStyle(
          //           fontSize: 18, fontWeight: FontWeight.w400),
          //       value: findInfStateW.cityValue,
          //       icon: const Icon(
          //         Icons.arrow_drop_down,
          //         color: Colors.black,
          //       ),
          //       items: [
          //         for (int i = 0; i < findInfStateW.cityList.length; i++) ...[
          //           DropdownMenuItem(
          //             onTap: () {
          //               findInfStateW.setCityId(i);
          //             },
          //             value: findInfStateW.cityList[i]["name"],
          //             child: Container(
          //               decoration: BoxDecoration(
          //                 border: Border(
          //                   bottom: BorderSide(
          //                     color: blackC.withOpacity(0.25),
          //                   ),
          //                 ),
          //               ),
          //               width: 220,
          //               padding: const EdgeInsets.symmetric(vertical: 8),
          //               child: Text(
          //                 "[${findInfStateW.cityList[i]["code"]}] ${findInfStateW.cityList[i]["name"]}",
          //                 textScaleFactor: 1,
          //                 style: const TextStyle(
          //                     color: Colors.black, fontSize: 16),
          //               ),
          //             ),
          //           ),
          //         ]
          //       ],
          //       onChanged: (newval) {
          //         findInfStateW.setCityValue(newval!);
          //       },
          //       buttonElevation: 2,
          //       itemHeight: 40,
          //       dropdownMaxHeight: 250,
          //       dropdownPadding: null,
          //       isDense: false,
          //       dropdownElevation: 8,
          //       scrollbarRadius: const Radius.circular(40),
          //       scrollbarThickness: 6,
          //       scrollbarAlwaysShow: true,
          //       offset: const Offset(0, 0),
          //       dropdownDecoration: BoxDecoration(
          //           color: const Color(0xfffbfbfb),
          //           borderRadius: BorderRadius.circular(5),
          //           boxShadow: const []),
          //     ),
          //   ),
          // ),

          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              if (isTextSearch) ...[
                TextButton.icon(
                  onPressed: () {
                    findInfStateW.setIsAdvance(false);
                  },
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: secondaryC,
                  ),
                  label: const Text(
                    "Text Search",
                    textScaleFactor: 1,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: secondaryC,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () {
                  findInfStateW.clear();
                },
                child: const Icon(
                  Icons.delete,
                  color: secondaryC,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryC,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final data = await findInfStateW.startSeatch(context);
                  if (data[0] != false) {
                    findInfStateW.setIsSearch(true);
                    findInfStateW.setSearchData(jsonDecode(data[0]));
                  }
                },
                child: const Text(
                  "Search",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: whiteC,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserList extends HookConsumerWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;

    final findInfStateW = ref.watch(findInfState);

    return findInfStateW.isSearch
        ? Container(
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 25),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        "Found: ${findInfStateW.searchData.length} Influencer",
                        textAlign: TextAlign.left,
                        textScaleFactor: 1,
                        style: const TextStyle(
                            color: blackC,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            comingalert(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: backgroundC,
                            elevation: 0,
                          ),
                          icon: const Icon(
                            Icons.sort,
                            color: blackC,
                          ),
                          label: Text(
                            "Reach",
                            textAlign: TextAlign.left,
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: blackC.withOpacity(0.55),
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (findInfStateW.searchData.isEmpty) ...[
                        Text(
                          "Reach",
                          textAlign: TextAlign.left,
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: blackC.withOpacity(0.85),
                              fontSize: 20,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                      for (int i = 0;
                          i < findInfStateW.searchData.length;
                          i++) ...[
                        UserCard(
                          imgUrl: findInfStateW.searchData[i]["pic"],
                          champname: findInfStateW.searchData[i]["email"],
                          title: findInfStateW.searchData[i]["userName"],
                          btnColor: const Color(0xff80fff9),
                          btnText: "View Profile",
                          btnFunction: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyAccount(
                                  id: findInfStateW.searchData[i]["id"]
                                      .toString(),
                                  isSendMsg: true,
                                ),
                              ),
                            );
                          },
                          website: findInfStateW.searchData[i]["bio"],
                        ),
                      ],
                    ],
                  ),
                )
              ],
            ),
          )
        : Container();
  }
}

class TextInfSeach extends HookConsumerWidget {
  const TextInfSeach({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    TextEditingController textSearch = useTextEditingController();
    // final findCampStateW = ref.watch(findCampState);
    final findInfStateW = ref.watch(findInfState);

    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: whiteC,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: shadowC, blurRadius: 5, offset: Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                keyboardType: TextInputType.text,
                controller: textSearch,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  filled: true,
                  fillColor: Color(0xfff3f4f6),
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
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  findInfStateW.setIsAdvance(true);
                  // comingalert(context);
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: secondaryC,
                ),
                label: const Text(
                  "Advance filter",
                  textScaleFactor: 1,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: secondaryC,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  findInfStateW.clear();
                },
                child: const Icon(
                  Icons.delete,
                  color: secondaryC,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryC,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final data =
                      await findInfStateW.textSearch(context, textSearch.text);
                  if (data[0] != false) {
                    findInfStateW.setIsSearch(true);
                    findInfStateW.setSearchData(jsonDecode(data[0]));
                  }
                },
                child: const Text(
                  "Search",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: whiteC,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
