import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swrv/services/apirequest.dart';
import 'package:swrv/state/userstate.dart';
import 'package:swrv/widgets/componets.dart';

import '../../state/compaign/campaigninfostate.dart';
import '../../utils/alerts.dart';
import '../../utils/utilthemes.dart';
import '../../widgets/buttons.dart';

class MoreCampInfo extends HookConsumerWidget {
  final String brandId;
  final String campId;
  final String draftId;

  const MoreCampInfo({
    super.key,
    required this.brandId,
    required this.campId,
    required this.draftId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> tabName = ["Payments", "Rating", "Dispute"];
    ValueNotifier<int> curTab = useState<int>(0);
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < tabName.length; i++) ...[
                            InkWell(
                              onTap: () {
                                curTab.value = i;
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    )
                                  ],
                                  color: (curTab.value == i)
                                      ? secondaryC
                                      : backgroundC,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tabName[i],
                                  textScaleFactor: 1,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        (curTab.value == i) ? whiteC : blackC,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (curTab.value == 0) ...[
                      Payment(
                        brandId: brandId,
                        campId: campId,
                        draftId: draftId,
                      )
                    ],
                    if (curTab.value == 1) ...[
                      Rating(
                        brandId: brandId,
                        campId: campId,
                      )
                    ],
                    if (curTab.value == 2) ...[
                      Dispute(
                        brandId: brandId,
                        campId: campId,
                      )
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Payment extends HookConsumerWidget {
  const Payment({
    super.key,
    required this.brandId,
    required this.campId,
    required this.draftId,
  });
  final String brandId;
  final String campId;
  final String draftId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> paymentbox = useState(false);

    final GlobalKey<FormState> formKey =
        useMemoized(() => GlobalKey<FormState>());
    final width = MediaQuery.of(context).size.width;
    TextEditingController amount = useTextEditingController();
    final userStateW = ref.watch(userState);

    CusApiReq apiReq = CusApiReq();
    ValueNotifier<dynamic> champ = useState<dynamic>(null);
    ValueNotifier<String?> currency = useState<String?>(null);

    ValueNotifier<int> pendingpayment = useState<int>(0);
    ValueNotifier<int> recivedpayment = useState<int>(0);

    ValueNotifier<bool> isLoading = useState<bool>(true);

    Future<void> init() async {
      isLoading.value = true;
      // currency.value = await userStateW.getCurrencyCode();
      currency.value = "USD";
      final req = {
        "id": campId,
      };
      List reqdata =
          await apiReq.postApi2(jsonEncode(req), path: "/api/campaign-search");
      if (reqdata[0]["status"]) {
        champ.value = reqdata[0]["data"];
      }

      final req1 = {
        "userId": await userStateW.getUserId(),
        "draftId": draftId,
      };
      List reqdata1 = await apiReq.postApi2(jsonEncode(req1),
          path: "/api/get-pending-payment");
      if (reqdata1[0]["status"]) {
        pendingpayment.value = int.parse(
            reqdata1[0]["data"]["totalAmtReq"].toString().split(".")[0]);
      }

      final req2 = {
        "userId": await userStateW.getUserId(),
        "draftId": draftId,
      };

      List reqdata2 = await apiReq.postApi2(jsonEncode(req2),
          path: "/api/get-received-payment");
      if (reqdata2[0]["status"]) {
        recivedpayment.value = int.parse(
            reqdata2[0]["data"]["totalAmtReq"].toString().split(".")[0]);
      }

      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);

    return isLoading.value
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                width: width,
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: whiteC,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: blackC.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Budget",
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: blackC,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${champ.value[0]["costPerPost"].toString().split(".")[0]} ${currency.value}",
                          textScaleFactor: 1,
                          style: const TextStyle(
                            color: blackC,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: blackC,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Received",
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: blackC,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${recivedpayment.value} ${currency.value}",
                          textScaleFactor: 1,
                          style: const TextStyle(
                            color: blackC,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Pending",
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: blackC,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${int.parse(champ.value[0]["costPerPost"].toString().split(".")[0]) - recivedpayment.value} ${currency.value}",
                          textScaleFactor: 1,
                          style: const TextStyle(
                            color: blackC,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                width: width,
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: whiteC,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: blackC.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Payment request",
                        textScaleFactor: 1,
                        style: TextStyle(
                          color: secondaryC,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (paymentbox.value) ...[
                        Row(
                          children: [
                            const Text(
                              "Enter Amount",
                              textScaleFactor: 1,
                              style: TextStyle(
                                color: blackC,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: TextFormField(
                                  controller: amount,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value == "") {
                                      return 'Enter the amount.';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: backgroundC,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CusBtn(
                          btnColor: const Color(0xff01FFF4),
                          btnText: "Request payment",
                          textSize: 18,
                          btnFunction: () async {
                            if (formKey.currentState!.validate()) {
                              if (int.parse(amount.text) >
                                  int.parse(champ.value[0]["costPerPost"]
                                          .toString()
                                          .split(".")[0]) -
                                      pendingpayment.value) {
                                erroralert(context, "error",
                                    "Your requested is higher then pending amount.");
                              } else {
                                final req = {
                                  "userId": await userStateW.getUserId(),
                                  "campaignId": campId,
                                  "amtReq": int.parse(amount.text),
                                  "draftId": draftId,
                                  "brandId": brandId,
                                  "paymentType": "1",
                                };

                                List data = await apiReq.postApi2(
                                    jsonEncode(req),
                                    path: "/api/new-pay-request");

                                if (data[0]["status"]) {
                                  Navigator.pop(context);
                                } else {
                                  erroralert(
                                      context, "error", data[0]["message"]);
                                }
                              }

                              //   if (data[0]["status"]) {
                              //     susalert(context, "Successfully requestd",
                              //         "Payment requestd successfully.");
                              //     paymentbox.value = false;
                              //   } else {
                              //     erroralert(
                              //         context, "error", "Unable to send request");
                              //   }
                              //   comingalert(context);
                            }
                          },
                          textColor: blackC,
                        ),
                      ] else ...[
                        CusBtn(
                          btnColor: const Color(0xff01FFF4),
                          btnText: "Request Paymet",
                          textSize: 18,
                          btnFunction: () {
                            paymentbox.value = true;
                          },
                          textColor: blackC,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

class Rating extends HookConsumerWidget {
  const Rating({super.key, required this.brandId, required this.campId});
  final String brandId;
  final String campId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateW = ref.watch(userState);
    CusApiReq apiReq = CusApiReq();
    final width = MediaQuery.of(context).size.width;

    ValueNotifier<double> communication = useState<double>(0);
    ValueNotifier<double> approvals = useState<double>(0);
    ValueNotifier<double> payments = useState<double>(0);

    ValueNotifier<bool> submit = useState<bool>(false);
    ValueNotifier<bool> isLoading = useState<bool>(true);

    Future<void> init() async {
      isLoading.value = true;
      final req = {
        "search": {
          "type": "3",
          "campaign": campId,
          "brand": brandId,
          "influencer": await userStateW.getUserId(),
        },
      };

      List reqdata =
          await apiReq.postApi2(jsonEncode(req), path: "/api/search-review");
      if (reqdata[0]["status"]) {
        if (reqdata[0]["data"].length != 0) {
          submit.value = true;
        }
      }
      isLoading.value = false;
    }

    useEffect(() {
      init();
      return null;
    }, []);

    return isLoading.value
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : !submit.value
            ? Container(
                width: width,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: whiteC,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Rate your Experiencs",
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackC,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Divider(),
                    Text(
                      "Communication",
                      textScaleFactor: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blackC.withOpacity(0.65),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: primaryC,
                      ),
                      onRatingUpdate: (rating) {
                        communication.value = rating;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Approvals",
                      textScaleFactor: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blackC.withOpacity(0.65),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: primaryC,
                      ),
                      onRatingUpdate: (rating) {
                        approvals.value = rating;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Payments",
                      textScaleFactor: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blackC.withOpacity(0.65),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: primaryC,
                      ),
                      onRatingUpdate: (rating) {
                        payments.value = rating;
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryC,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () async {
                          if (communication.value == 0) {
                            erroralert(context, "Error",
                                "Communication Rating should not be 0");
                          } else if (approvals.value == 0) {
                            erroralert(context, "Error",
                                "Approvals Rating should not be 0");
                          } else if (payments.value == 0) {
                            erroralert(context, "Error",
                                "Payment Rating should not be 0");
                          }
                          final req = {
                            "influencerId": await userStateW.getUserId(),
                            "brandId": brandId,
                            "campaignId": campId,
                            "rating1": communication.value,
                            "rating2": approvals.value,
                            "rating3": payments.value,
                            "reviewType": "3",
                            "remark": "User To Brand",
                          };

                          List reqdata = await apiReq.postApi2(jsonEncode(req),
                              path: "/api/add-review");
                          if (reqdata[0]["status"]) {
                            Navigator.pop(context);
                          } else {
                            erroralert(
                                context, "Error", "Unable to add your review.");
                          }
                        },
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              )
            : Container();
  }
}

class Dispute extends HookConsumerWidget {
  const Dispute({super.key, required this.brandId, required this.campId});
  final String brandId;
  final String campId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateW = ref.watch(userState);
    final remark = useTextEditingController();
    CusApiReq apiReq = CusApiReq();
    final GlobalKey<FormState> formKey =
        useMemoized(() => GlobalKey<FormState>());
    final width = MediaQuery.of(context).size.width;

    final campaignInfoStateW = ref.watch(campaignInfoState);

    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: whiteC,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Dispute",
                textScaleFactor: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackC,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Divider(),
            SizedBox(
              width: width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  hint: const Text(
                    "Select Dispute reason",
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
                  value: campaignInfoStateW.discputValue,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  items: [
                    for (int i = 0;
                        i < campaignInfoStateW.disputeValueList.length;
                        i++) ...[
                      DropdownMenuItem(
                        onTap: () {
                          // createCmpSW.setCmpId(i);
                        },
                        value: campaignInfoStateW.disputeValueList[i],
                        child: Container(
                          decoration: const BoxDecoration(),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            campaignInfoStateW.disputeValueList[i],
                            textScaleFactor: 1,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                    ]
                  ],
                  onChanged: (val) {
                    campaignInfoStateW.setDisputeValue(val!);
                    // createCmpSW.setCmpValue(newval!);
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TextFormField(
                  minLines: 4,
                  maxLines: 6,
                  controller: remark,
                  validator: (value) {
                    if (value == null || value.isEmpty || value == "") {
                      return 'Please enter message.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xfff3f4f6),
                    hintText: "Your message",
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryC,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final req = {
                      "type": campaignInfoStateW.getDiscputeType(),
                      "userId": await userStateW.getUserId(),
                      "brandId": brandId,
                      "campaignId": campId,
                      "isBrand": 0,
                      "message": remark.text,
                    };

                    List reqdata = await apiReq.postApi2(jsonEncode(req),
                        path: "/api/add-dispute");
                    if (reqdata[0]["status"]) {
                      Navigator.pop(context);
                    } else {
                      erroralert(context, "Error", "Unable to bid.");
                    }
                  }
                },
                child: const Text("Send message"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
