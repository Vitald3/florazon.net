import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import '../values.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import '../screen/header.dart';
import 'package:provider/provider.dart';
import '../screen/item_product.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    final List<int>? wishlist = Provider.of<Values>(context).wishlist;
    var account = Provider.of<Values>(context, listen: false).account;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        title: const Header(),
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: wishlist!.isNotEmpty && account?.wishlist != null && account!.wishlist!.isNotEmpty ? Builder(
            builder: (context) {
              var wishlists = account.wishlist!;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: List.generate(wishlists.length, (index) {
                  if (wishlist.contains(wishlists[index].productId)) {
                    return ItemProduct(product: wishlists[index], close: true);
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              );
            }
        ) : Container(
          padding: const EdgeInsets.all(15),
          width: width-30,
          margin: const EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
            border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
            color: HexColor("#F4FBFF"),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/icons/info.svg", semanticsLabel: 'Info', width: 22, height: 22),
              const SizedBox(width: 15),
              Text(LocaleKeys.accountTextWishlistEmpty.tr())
            ],
          ),
        ),
      ),
    );
  }
}