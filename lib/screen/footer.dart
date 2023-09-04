import 'package:flutter_svg/flutter_svg.dart';
import '../values.dart';
import '../screen/menu.dart';
import '../screen/cart.dart';
import '../screen/auth_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final int accountId = Provider.of<Values>(context, listen: false).accountId;
    var userIcon = "user";

    if (accountId != 0) {
      userIcon = "userActive";
    }

    var qw = Provider.of<Values>(context).getCartQuantity();

    return SafeArea(
        bottom: false,
        child: Container(
          padding: EdgeInsets.only(left: 30, right: 30, top: 14, bottom: Platform.isIOS ? 34 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 2,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                    child: SvgPicture.asset("assets/icons/home.svg", semanticsLabel: 'Profile', width: 25),
                    onTap: () async {
                      await Provider.of<Values>(context, listen: false).resetHistory();

                      if (context.mounted) {
                        Provider.of<Values>(context, listen: false).setData("/");
                        Navigator.pushNamed(context, "/");
                      }
                    }
                ),
                const Spacer(),
                GestureDetector(
                    child: SvgPicture.asset("assets/icons/$userIcon.svg", semanticsLabel: 'Profile', width: 25),
                    onTap: () {
                      Provider.of<Values>(context, listen: false).setPopupVisible(true);

                      if (accountId == 0) {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              return const AuthPopup();
                            }
                        );
                      } else {
                        Provider.of<Values>(context, listen: false).setData("account");
                        Navigator.pushNamed(context, "account");
                      }
                    }
                ),
                const Spacer(),
                GestureDetector(
                    child: Stack(
                      alignment: AlignmentDirectional.topEnd,
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset("assets/icons/cart.svg", semanticsLabel: 'Cart', width: 25),
                        Positioned(
                          top: -6,
                          right: -9,
                          child: Text(qw, style: TextStyle(color: HexColor("#434D56"), fontSize: 13)),
                        ),
                      ],
                    ),
                    onTap: () {
                      Provider.of<Values>(context, listen: false).setPopupVisible(true);

                      showCupertinoModalPopup(context: context, builder: (BuildContext context) {
                        return const CartScreen();
                      });
                    }
                ),
                const Spacer(),
                GestureDetector(
                    child: SvgPicture.asset("assets/icons/burger.svg", semanticsLabel: 'Menu', width: 25),
                    onTap: () {
                      Provider.of<Values>(context, listen: false).setPopupVisible(true);

                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return const Menu();
                          }
                      );
                    }
                ),
              ]
          ),
        )
    );
  }
}