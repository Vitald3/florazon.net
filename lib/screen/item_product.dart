import 'package:flutter/material.dart';
import '../models/api.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../values.dart';
import '../screen/header.dart';
import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/cupertino.dart';

class ItemProduct extends StatelessWidget {
  const ItemProduct({super.key, required this.product, this.related, this.close});

  final Products product;
  final bool? related;
  final bool? close;

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    var width = 160.0;
    final String currentRoute = Provider.of<Values>(context, listen: false).currentRoute;

    if (orientation != Orientation.portrait) {
      if (currentRoute == "account") {
        width = (MediaQuery.of(context).size.width / 3) - 26;
      } else {
        width = (MediaQuery.of(context).size.width / 3) - 16;
      }
    } else {
      if (currentRoute == "account") {
        width = (MediaQuery.of(context).size.width / 2) - 35;
      } else {
        width = (MediaQuery.of(context).size.width / 2) - 19;
      }
    }

    final wishlist = Provider.of<Values>(context).wishlist;
    var icon = "heart";

    if (wishlist != null && wishlist.contains(product.productId!)) {
      icon = "heartActive";
    }

    return GestureDetector(
      onTap: () {
        Provider.of<Values>(context, listen: false).setProductId(product.productId!);
        Provider.of<Values>(context, listen: false).setData("product");
        Navigator.pushNamed(context, "product");
      },
      child: Container(
        width: width,
        height: width+50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0), topLeft: Radius.circular(3), topRight: Radius.circular(3)),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: product.image!,
                      width: width,
                      height: width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (product.percent! != "") Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 50,
                      height: 25,
                      margin: const EdgeInsets.only(left: 10, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: HexColor("#ffffff"), width: 0.5),
                        color: HexColor("#FF7061"),
                        borderRadius: const BorderRadius.all(Radius.circular(3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 2,
                            offset: const Offset(0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Center(
                          child: Text(product.percent!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ),
                  ),
                  if (close != null && close!) Padding(
                    padding: const EdgeInsets.only(right: 5, top: 5),
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: GestureDetector(
                          child: SvgPicture.asset("assets/icons/closeW.svg", semanticsLabel: 'Close', width: 21, height: 21),
                          onTap: () {
                            wishlist.remove(product.productId);
                            Provider.of<Values>(context, listen: false).setWishlist(wishlist);
                          }
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Stack(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 27),
                          child: Text(
                            product.name!,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: Builder(
                            builder: (context) {
                              if (product.special != "false") {
                                return Wrap(
                                  children: [
                                    Text(
                                      product.special!,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      product.price!,
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: HexColor("#C0D0DD"), decoration: TextDecoration.lineThrough),
                                    ),
                                  ],
                                );
                              } else {
                                return Text(
                                  product.price!,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                );
                              }
                            },
                          ),
                        ),
                      ]
                  ),
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: GestureDetector(
                        child: SvgPicture.asset("assets/icons/$icon.svg", semanticsLabel: 'Wishlist', width: 22, height: 19),
                        onTap: () {
                          if (icon == "heart") {
                            wishlist.add(product.productId);
                          } else {
                            wishlist.remove(product.productId);
                          }

                          Provider.of<Values>(context, listen: false).setWishlist(wishlist);
                        }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopupProduct extends StatelessWidget {
  const PopupProduct({super.key, required this.product, required this.productRelated, required this.productQuantity, required this.width, required this.index});

  final Product product;
  final Products productRelated;
  final int productQuantity;
  final double width;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bool submitLoaded = Provider.of<Values>(context, listen: false).submitLoaded;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: productRelated.image!,
                width: double.infinity,
                height: 375,
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    productRelated.name!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        productRelated.special != "false" ? productRelated.special! : productRelated.price!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 5),
                      if (productRelated.special != "false") Text(
                        productRelated.price!,
                        style: TextStyle(fontSize: 12, color: HexColor("#FF9186"), decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  Text(
                    LocaleKeys.textSku.tr(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    productRelated.sku!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Provider.of<Values>(context, listen: false).setProductQuantity("-");
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
                        child: SvgPicture.asset(productQuantity == 1 ? "assets/icons/removeC.svg" : "assets/icons/minus.svg", semanticsLabel: 'Minus'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 30,
                    child: Text("$productQuantity", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Provider.of<Values>(context, listen: false).setProductQuantity("+");
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
                        child: SvgPicture.asset("assets/icons/plus.svg", semanticsLabel: 'Plus', width: 9, height: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!submitLoaded) {
                      Provider.of<Values>(context, listen: false).setSubmitLoaded(true);
                      final vazId = productRelated.productId != product.vazaId && product.vaza == 1 && product.vazaId != 0 && index == 0 && productRelated.cartId == 0 ? product.vazaId : 0;

                      var response = Provider.of<Values>(context, listen: false).cartAdd(productRelated.productId!, productQuantity, 1, vazId!, null, 0);
                      response.then((value) => Navigator.of(context).pop());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 0.5,
                            color: HexColor("#FF7061")
                        ),
                        borderRadius: BorderRadius.circular(35)
                    ),
                    backgroundColor: HexColor("#FF7061"),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                    minimumSize: Size(width, 50),
                  ),
                  child: submitLoaded ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(color: Colors.white),
                  ) : Text(LocaleKeys.buy.tr().toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        )
    );
  }
}

class Relateds extends StatelessWidget {
  const Relateds({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    var width = 160.0;
    final String currentRoute = Provider.of<Values>(context, listen: false).currentRoute;
    final bool vazDelete = Provider.of<Values>(context, listen: false).vazDelete;
    final List<Products> productRelated = Provider.of<Values>(context, listen: false).productRelated;

    if (orientation != Orientation.portrait) {
      if (currentRoute == "account") {
        width = (MediaQuery.of(context).size.width / 3) - 26;
      } else {
        width = (MediaQuery.of(context).size.width / 3) - 16;
      }
    } else {
      if (currentRoute == "account") {
        width = (MediaQuery.of(context).size.width / 2) - 35;
      } else {
        width = (MediaQuery.of(context).size.width / 2) - 19;
      }
    }

    return Row(
      children: List.generate(productRelated.length, (index) {
        return Padding(
            padding: const EdgeInsets.only(right: 10, top: 2, bottom: 2, left: 2),
            child: Container(
                width: width,
                height: width+50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 2,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Provider.of<Values>(context, listen: false).setPopupVisible(true);

                        showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              final int productQuantity = Provider.of<Values>(context).productQuantity;

                              return PopupProduct(product: product, productRelated: productRelated[index], productQuantity: productQuantity, width: width, index: index);
                            }
                        );
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0), topLeft: Radius.circular(3), topRight: Radius.circular(3)),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: productRelated[index].image!,
                                    width: width,
                                    height: width,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (productRelated[index].percent! != "") Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    width: 50,
                                    height: 25,
                                    margin: const EdgeInsets.only(left: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: HexColor("#ffffff"), width: 0.5),
                                      color: HexColor("#FF7061"),
                                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 0,
                                          blurRadius: 2,
                                          offset: const Offset(0, 2), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(productRelated[index].percent!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 27),
                                          child: Text(
                                            product.name!,
                                            overflow: TextOverflow.fade,
                                            maxLines: 1,
                                            softWrap: false,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            if (productRelated[index].special != "false") {
                                              return Wrap(
                                                children: [
                                                  Text(
                                                    productRelated[index].special!,
                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                                  ),
                                                  const SizedBox(width: 7),
                                                  Text(
                                                    productRelated[index].price!,
                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: HexColor("#C0D0DD"), decoration: TextDecoration.lineThrough),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Text(
                                                productRelated[index].price!,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              );
                                            }
                                          },
                                        ),
                                      ]
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    child: GestureDetector(
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          margin: const EdgeInsets.only(top: 6),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                            color: Colors.white,
                                            borderRadius: const BorderRadius.all(Radius.circular(3)),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset("assets/icons/plus.svg", semanticsLabel: 'AddRelated', width: 10, height: 10),
                                          ),
                                        ),
                                        onTap: () {
                                          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (BuildContext context) {
                                            final int productQuantity = Provider.of<Values>(context).productQuantity;

                                            return PopupProduct(product: product, productRelated: productRelated[index], productQuantity: productQuantity, width: width, index: index);
                                          });
                                        }
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((product.vaza == 1 && product.vazaId != 0 && index == 0 && !vazDelete && productRelated[index].cartQuantity != 0) || productRelated[index].cartId != 0) ClipRRect(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0), topLeft: Radius.circular(3), topRight: Radius.circular(3)),
                      child: SizedBox(
                        width: width,
                        height: double.infinity,
                        child: ColoredBox(
                          color: HexColor("#55667e").withOpacity(0.75),
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    var qw = productRelated[index].cartQuantity!;
                                    qw--;

                                    if (qw > 0) {
                                      Provider.of<Values>(context, listen: false).cartUpdate(productRelated[index].cartId!, qw);
                                    } else {
                                      Provider.of<Values>(context, listen: false).cartRemove(productRelated[index].cartId!, product.vazaId!, productRelated[index].productId!);
                                    }
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
                                      child: SvgPicture.asset(productRelated[index].cartQuantity == 1 ? "assets/icons/removeC.svg" : "assets/icons/minus.svg", semanticsLabel: 'Minus'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: 30,
                                  child: Text(productRelated[index].cartQuantity.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center),
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    var qw = productRelated[index].cartQuantity!;
                                    qw++;

                                    if (productRelated[index].cartId != 0) {
                                      Provider.of<Values>(context, listen: false).cartUpdate(productRelated[index].cartId!, qw);
                                    } else {
                                      Provider.of<Values>(context, listen: false).cartAdd(productRelated[index].productId!, 2, 1, 0, null, 0);
                                    }
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
                                      child: SvgPicture.asset("assets/icons/plus.svg", semanticsLabel: 'Plus', width: 9, height: 10),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
        );
      }),
    );
  }
}