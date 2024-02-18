// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/services/apirequest.dart';
import 'package:swrv/utils/alerts.dart';

import '../../state/brand/findbrandstate.dart';
import '../../utils/utilthemes.dart';
import '../../widgets/componets.dart';
import '../brand/brandinfo.dart';

class TextBrandSearch extends HookConsumerWidget {
  const TextBrandSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CusApiReq apiReq = CusApiReq();

    final width = MediaQuery.of(context).size.width;
    TextEditingController textSearch = useTextEditingController();
    final findBrandStateW = ref.watch(findBrandState);

    void init() async {
      List markets =
          await apiReq.postApi(jsonEncode({}), path: "/api/get-market");

      List category =
          await apiReq.postApi(jsonEncode({}), path: "api/getcategory");

      if (markets[0]["status"] && category[0]["status"]) {
        findBrandStateW.setMarket(markets[0]["data"]);

        findBrandStateW.setCmp(category[0]["data"]);
      } else {
        erroralert(context, "error", "No Record Fount");
      }
    }

    useEffect(() {
      init();
      return null;
    }, []);

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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Search",
              textScaleFactor: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: secondaryC),
            ),
          ),
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
                  fillColor: Color(0xffeeeeee),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Category",
              textScaleFactor: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: secondaryC),
            ),
          ),
          if (findBrandStateW.cmpList.isEmpty) ...[
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
                  value: findBrandStateW.cmpValue,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  items: [
                    for (int i = 0;
                        i < findBrandStateW.cmpList.length;
                        i++) ...[
                      DropdownMenuItem(
                        onTap: () {
                          findBrandStateW.setCmpId(i);
                        },
                        value: findBrandStateW.cmpList[i]["categoryName"],
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
                            "[${findBrandStateW.cmpList[i]["categoryCode"]}] ${findBrandStateW.cmpList[i]["categoryName"]}",
                            textScaleFactor: 1,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                    ]
                  ],
                  onChanged: (newval) {
                    findBrandStateW.setCmpValue(newval!);
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
                      color: const Color(0xffeeeeee),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const []),
                ),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Markets",
              textScaleFactor: 1,
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: secondaryC),
            ),
          ),
          if (findBrandStateW.marketList.isEmpty) ...[
            const CircularProgressIndicator(),
          ] else ...[
            SizedBox(
              width: width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  hint: const Text(
                    "Markets",
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
                  value: findBrandStateW.marketValue,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  items: [
                    for (int i = 0;
                        i < findBrandStateW.marketList.length;
                        i++) ...[
                      DropdownMenuItem(
                        onTap: () {
                          findBrandStateW.setMarketId(i);
                        },
                        value: findBrandStateW.marketList[i]["name"],
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
                            "[${findBrandStateW.marketList[i]["code"]}] ${findBrandStateW.marketList[i]["name"]}",
                            textScaleFactor: 1,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                    ]
                  ],
                  onChanged: (newval) {
                    findBrandStateW.setMarketValue(newval!);
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
            height: 10,
          ),
          Row(
            children: [
              const Spacer(),
              InkWell(
                onTap: () {
                  findBrandStateW.clear();
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
                  final data = await findBrandStateW.textSearch(
                      context, textSearch.text);
                  if (data[0] != false) {
                    findBrandStateW.setIsSearch(true);
                    findBrandStateW.setSearchData(jsonDecode(data[0]));
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

class BrandList extends HookConsumerWidget {
  const BrandList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final findBrandStateW = ref.watch(findBrandState);

    return findBrandStateW.isSearch
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
                        "Found: ${findBrandStateW.searchData.length} Campaigns",
                        textAlign: TextAlign.left,
                        textScaleFactor: 1,
                        style: const TextStyle(
                            color: blackC,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
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
                      if (findBrandStateW.searchData.isEmpty) ...[
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
                          i < findBrandStateW.searchData.length;
                          i++) ...[
                        BrandCard(
                          title: findBrandStateW.searchData[i]["name"],
                          imgUrl: findBrandStateW.searchData[i]["logo"],
                          btnColor: const Color(0xff80fff9),
                          btnText: "View",
                          btnFunction: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BrandInfo(
                                  id: findBrandStateW.searchData[i]["brandId"]
                                      .toString(),
                                ),
                              ),
                            );
                          },
                          website: findBrandStateW.searchData[i]["webUrl"],
                          email: findBrandStateW.searchData[i]["email"],
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
