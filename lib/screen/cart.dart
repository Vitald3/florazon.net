import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import '../values.dart';
import '../models/api.dart';
import '../screen/header.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import '../extensions.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Cart> cart = Provider.of<Values>(context).cart;
    final List<Totals> totals = Provider.of<Values>(context).totals;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        title: const Header(),
        elevation: 0.5,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ColoredBox(
                color: HexColor("#FFFFFF"),
                child: SingleChildScrollView(
                  child: Builder(
                      builder: (context) {
                        if (cart.isNotEmpty) {
                          return Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: List.generate(cart.length, (index) {
                                  final Product product = cart[index].product!;

                                  if (product.sku != "") {
                                    final String sku = product.sku??"";
                                    final String textArt = LocaleKeys.textSku.tr();

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(left: 15, top: 15, bottom: 10),
                                            child: Wrap(
                                              alignment: WrapAlignment.spaceBetween,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                  child: FadeInImage.memoryNetwork(
                                                    placeholder: kTransparentImage,
                                                    image: product.image!,
                                                    width: 88,
                                                    height: 88,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                SizedBox(
                                                  width: width - 128,
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          product.name??"",
                                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                                        ),
                                                        const SizedBox(height: 3),
                                                        Text(
                                                          "$textArt $sku", style: const TextStyle(fontSize: 10),
                                                        ),
                                                        const SizedBox(height: 20),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Wrap(
                                                              alignment: WrapAlignment.center,
                                                              crossAxisAlignment: WrapCrossAlignment.center,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (cart[index].quantity! > 1) {
                                                                      var qw = cart[index].quantity!;
                                                                      qw--;

                                                                      Provider.of<Values>(context, listen: false).cartUpdate(cart[index].cartId!, qw);
                                                                    } else {
                                                                      Provider.of<Values>(context, listen: false).cartRemove(cart[index].cartId!, product.vazaId??0, cart[index].productId!);
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    width: 30,
                                                                    height: 30,
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                                      color: HexColor("#F4FBFF"),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                                                                    ),
                                                                    child: Center(
                                                                      child: SvgPicture.asset(cart[index].quantity == 1 ? "assets/icons/removeC.svg" : "assets/icons/minus.svg", color: HexColor("#434D56"), semanticsLabel: 'Minus'),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 5),
                                                                SizedBox(
                                                                  width: 30,
                                                                  child: Text(cart[index].quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center),
                                                                ),
                                                                const SizedBox(width: 5),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    var qw = cart[index].quantity!;
                                                                    qw++;

                                                                    Provider.of<Values>(context, listen: false).cartUpdate(cart[index].cartId!, qw);
                                                                  },
                                                                  child: Container(
                                                                    width: 30,
                                                                    height: 30,
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                                      color: HexColor("#F4FBFF"),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                                                                    ),
                                                                    child: Center(
                                                                      child: SvgPicture.asset("assets/icons/plus.svg", semanticsLabel: 'Plus', width: 9, height: 10),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              product.total.toString(),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Provider.of<Values>(context, listen: false).cartRemove(cart[index].cartId!, product.vazaId??0, cart[index].productId!);
                                                              },
                                                              child: Container(
                                                                width: 30,
                                                                height: 30,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                                  color: Colors.white,
                                                                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                                                                ),
                                                                child: Center(
                                                                  child: SvgPicture.asset("assets/icons/close.svg", semanticsLabel: 'Close', width: 25, height: 25),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                        const Divider(),
                                        const SizedBox(height: 20),
                                      ],
                                    );
                                  } else {
                                    return const EmptyBox();
                                  }
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(totals[totals.length-1].text!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900))
                                ),
                              ),
                              const SizedBox(height: 22),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                width: width,
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  runAlignment: WrapAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 0.5,
                                                color: HexColor("#6D8497")
                                            ),
                                            borderRadius: BorderRadius.circular(35)
                                        ),
                                        backgroundColor: HexColor("#ffffff"),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 13),
                                        minimumSize: Size((width/2)-20, 45),
                                      ),
                                      onPressed: () {
                                        Provider.of<Values>(context, listen: false).setPopupVisible(false);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(LocaleKeys.continueCart.tr(), style: TextStyle(color: HexColor("#434D56"))),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 0.5,
                                                color: HexColor("#6D8497")
                                            ),
                                            borderRadius: BorderRadius.circular(35)
                                        ),
                                        backgroundColor: HexColor("#ffffff"),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                                        minimumSize: Size((width/2)-20, 45),
                                      ),
                                      onPressed: () {
                                        Provider.of<Values>(context, listen: false).setPopupVisible(false);
                                        Provider.of<Values>(context, listen: false).setData("checkout");
                                        Navigator.pushNamed(context, "checkout");
                                      },
                                      child: Text(LocaleKeys.textTotal.tr(), style: TextStyle(color: HexColor("#434D56"), fontWeight: FontWeight.w600)),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              width: width-30,
                              margin: const EdgeInsets.only(top: 50),
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
                                  Text(LocaleKeys.cartEmpty.tr())
                                ],
                              ),
                            ),
                          );
                        }
                      }
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }
}