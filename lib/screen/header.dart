import 'package:flutter_svg/flutter_svg.dart';
import '../values.dart';
import '../screen/wishlist.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Provider.of<Values>(context, listen: false).currentRoute;
    final List<Map<dynamic, dynamic>> historyPush = Provider.of<Values>(context, listen: false).historyPush;
    final bool popupVisible = Provider.of<Values>(context, listen: false).popupVisible;
    final bool searchVisible = Provider.of<Values>(context).searchVisible;
    var account = Provider.of<Values>(context, listen: false).account;
    var wishlistCount = "";

    if (account != null) {
      wishlistCount = account.wishlist!.length.toString().replaceAll("0", "");
    }

    return SafeArea(
      top: false,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Visibility(
                    visible: !popupVisible && (historyPush.length > 0 && (currentRoute == "category" || currentRoute == "product" || currentRoute == "checkout")),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async {
                          await Provider.of<Values>(context, listen: false).deleteLastHistory();

                          if (context.mounted) {
                            Provider.of<Values>(context, listen: false).setPopupVisible(false);
                            Navigator.of(context).pop();
                          }
                        },
                        child: SizedBox(
                          width: 100,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset("assets/icons/back.svg", semanticsLabel: 'Back', width: 21),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: popupVisible,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                        },
                        child: SizedBox(
                          width: 100,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SvgPicture.asset("assets/icons/back.svg", semanticsLabel: 'Back', width: 21),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (currentRoute != "/") {
                        await Provider.of<Values>(context, listen: false).resetHistory();

                        if (context.mounted) {
                          Provider.of<Values>(context, listen: false).setPopupVisible(false);
                          Provider.of<Values>(context, listen: false).setData("/");
                          if (context.mounted) Navigator.pushNamed(context, "/");
                        }
                      }
                    },
                    child: SvgPicture.asset("assets/icons/logo.svg", semanticsLabel: 'Logo', width: 177),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Spacer(),
                          GestureDetector(
                              child: Stack(
                                alignment: AlignmentDirectional.topEnd,
                                clipBehavior: Clip.none,
                                children: [
                                  SvgPicture.asset("assets/icons/heartH.svg", semanticsLabel: 'Wishlist', width: 25, height: 25),
                                  Positioned(
                                    top: -6,
                                    right: -9,
                                    child: Text(wishlistCount, style: TextStyle(color: HexColor("#434D56"), fontSize: 13)),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (!Provider.of<Values>(context, listen: false).popupVisible) {
                                  Provider.of<Values>(context, listen: false).setPopupVisible(true);

                                  showCupertinoModalPopup(context: context, builder: (BuildContext context) {
                                    return const Wishlist();
                                  });
                                }
                              }
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                              child: SvgPicture.asset("assets/icons/search.svg", semanticsLabel: 'Search', width: 25, height: 25),
                              onTap: () {
                                if (!Provider.of<Values>(context, listen: false).popupVisible) {
                                  if (!searchVisible) {
                                    Provider.of<Values>(context, listen: false).updateSearchVisible(true);
                                  } else {
                                    Provider.of<Values>(context, listen: false).updateSearchVisible(false);
                                  }
                                }
                              }
                          ),
                        ]
                    ),
                  ),
                ]
            ),
          ),
          Visibility(
            visible: searchVisible,
            child: Container(
              color: HexColor("#c0d0dd").withOpacity(0.45),
              padding: const EdgeInsets.only(left: 15, right: 15),
              height: 65,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: SvgPicture.asset("assets/icons/close.svg", semanticsLabel: 'Close', width: 33, height: 33),
                    iconSize: 33,
                    onPressed: () {
                      Provider.of<Values>(context, listen: false).updateSearchVisible(false);
                    }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}