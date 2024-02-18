import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/utilthemes.dart';
import '../../widgets/componets.dart';

class HelpPayments extends HookConsumerWidget {
  const HelpPayments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: backgroundC,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Payments",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Container(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 200,
                  height: 2,
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce a felis a dolor dictum sodales. Vestibulum metus nunc, ornare nec ornare nec, eleifend eu est. Quisque congue ex et lectus pellentesque, quis feugiat ipsum porta. Aenean erat mi, iaculis eu nisi vitae, sollicitudin lobortis tortor. Vivamus condimentum euismod dolor a viverra. Nulla at tortor ac mi ultricies pretium. Pellentesque eget sollicitudin mi. In vitae auctor ex.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Praesent in porttitor dolor. Suspendisse potenti. Nulla sodales lorem non gravida dictum. Etiam sit amet faucibus nulla. Quisque nec egestas erat. Phasellus pulvinar sed ipsum nec bibendum. Praesent sagittis maximus mi eget iaculis. Mauris id cursus lorem. Nullam feugiat justo eros, quis semper dolor rutrum sit amet. In ornare, ex elementum volutpat ultrices, leo urna hendrerit justo, vitae volutpat nibh libero sit amet leo. Sed odio arcu, pellentesque non quam nec, mattis pulvinar purus. Phasellus vitae lacus vulputate ligula pulvinar cursus placerat nec odio. Nulla lobortis semper lectus, at iaculis est fermentum vel. Morbi quis mauris tellus.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Etiam libero enim, convallis sit amet libero et, pretium pretium nulla. Nam mattis quam quis auctor volutpat. Suspendisse id dolor mattis, facilisis urna vitae, rutrum ipsum. Cras mattis neque at lacus luctus consectetur. Nunc quis nibh sit amet dolor gravida varius eu non mauris. Maecenas convallis semper eros vitae ultrices. Nam sodales dapibus ipsum, quis pellentesque nisi volutpat in. Aenean lacinia id ligula eu porta. Phasellus odio nulla, luctus vitae blandit sed, hendrerit eget augue. Vestibulum enim justo, pretium nec condimentum at, pellentesque a orci. Cras elit magna, mattis eget eleifend non, volutpat vel odio. Vivamus metus nisl, tristique vel dignissim in, tempus ut orci. Nam consectetur, sem eu ullamcorper pulvinar, dui erat lobortis odio, a imperdiet ipsum sapien quis tellus. Sed ornare augue at elit porta, quis gravida elit interdum.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Quisque suscipit, ex rhoncus hendrerit facilisis, velit ex venenatis enim, vel lobortis mauris tellus vel libero. Nulla in elit dolor. Donec non suscipit ante. Sed in turpis in justo volutpat vulputate et id arcu. Quisque vel ipsum vitae justo rutrum convallis luctus sed magna. Suspendisse sit amet arcu purus. Vestibulum nec porta tortor. Cras quis eros ullamcorper enim lacinia feugiat. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In hac habitasse platea dictumst.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Nam enim turpis, interdum et est vel, fringilla facilisis velit. Sed id elit metus. Mauris lacinia sagittis volutpat. Morbi aliquam dui ligula. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce placerat eros nisl, pretium aliquet diam porta in. Phasellus venenatis ipsum nisi. Pellentesque finibus volutpat facilisis. Nulla interdum luctus sapien, quis vulputate massa efficitur ac. Praesent tortor enim, tincidunt condimentum dictum vitae, cursus id est.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryC,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Go Back"),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
