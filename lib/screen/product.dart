import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:hexcolor/hexcolor.dart';
import '../extensions.dart';
import '../values.dart';
import '../models/api.dart';
import '../screen/item_product.dart';
import '../screen/error.dart';
import '../screen/header.dart';
import '../screen/footer.dart';
import '../screen/search.dart';
import '../screen/city.dart';
import '../screen/cart.dart';
import '../screen/video.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:io';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final dynamic productIndexVariant = Provider.of<Values>(context).productIndexVariant;
    final bool isLoading = Provider.of<Values>(context, listen: false).isLoading;
    final bool submitLoaded = Provider.of<Values>(context, listen: false).submitLoaded;
    final int activeImage = Provider.of<Values>(context, listen: false).activeImage;
    final Map<String, dynamic> productVariant = Provider.of<Values>(context, listen: false).productVariant;
    final bool desAnim = Provider.of<Values>(context, listen: false).desAnim;
    var price = Provider.of<Values>(context, listen: false).getProductPrice(productIndexVariant);
    final String special = Provider.of<Values>(context, listen: false).getProductSpecial(productIndexVariant);
    final String percent = Provider.of<Values>(context, listen: false).getProductPercent(productIndexVariant);
    var sku = Provider.of<Values>(context, listen: false).getProductSku(productIndexVariant);
    final List<Sost> variants = Provider.of<Values>(context, listen: false).getVariant(productIndexVariant);
    final CarouselController carouselThumbController = Provider.of<Values>(context, listen: false).carouselThumbController;
    final CarouselController carouselController = Provider.of<Values>(context, listen: false).carouselController;
    final ScrollController scrollController = ScrollController();
    final ScrollController scrollViewedController = ScrollController();
    final int productId = Provider.of<Values>(context, listen: false).productId;
    final int cityId = Provider.of<Values>(context, listen: false).cityId;
    final int languageId = Provider.of<Values>(context, listen: false).languageId;
    final int qwUse = Provider.of<Values>(context, listen: false).qwUse;
    final int variant4 = Provider.of<Values>(context, listen: false).variant4;
    final bool buyVisible = Provider.of<Values>(context, listen: false).buyVisible;
    final ScrollController scroll = ScrollController();
    final Product? product = Provider.of<Values>(context, listen: false).product;

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          title: const Header(),
          elevation: 0.5,
        ),
        body: FutureBuilder<Data>(
            future: api,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data!;

                final wishlist = Provider.of<Values>(context).wishlist;
                var icon = "heart";

                if (wishlist != null && wishlist.contains(product!.productId)) {
                  icon = "heartActive";
                }

                if (sku == "") {
                  sku = product!.sku!;
                }

                if (price == "") {
                  price = product!.price!;
                }

                if (product != null) {
                  return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollUpdateNotification && scrollNotification.metrics.axisDirection == AxisDirection.down) {
                              if (scrollNotification.metrics.pixels + 350 >= scroll.position.maxScrollExtent) {
                                if (!buyVisible) Provider.of<Values>(context, listen: false).setBuyVisible(true);
                              } else if (buyVisible) {
                                Provider.of<Values>(context, listen: false).setBuyVisible(false);
                              }
                            }

                            return true;
                          },
                          child: SingleChildScrollView(
                            controller: scroll,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ColoredBox(
                                    color: HexColor("#434D56"),
                                    child: SizedBox(
                                      height: 46,
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: GestureDetector(
                                          onTap: () {
                                            Provider.of<Values>(context, listen: false).setPopupVisible(true);

                                            showCupertinoModalPopup(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return const City(title: 'Florazon');
                                                }
                                            );
                                          },
                                          child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                SvgPicture.asset("assets/icons/map.svg", color: Colors.white, semanticsLabel: 'Map', width: 12, height: 16),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                                  child: Text(
                                                    data.setting!.geoCity!,
                                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                                  ),
                                                ),
                                                SvgPicture.asset("assets/icons/down.svg", color: Colors.white, semanticsLabel: 'Arrow down', width: 11, height: 7),
                                              ]
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Stack(
                                        alignment: AlignmentDirectional.topEnd,
                                        children: [
                                          Container(
                                            constraints: const BoxConstraints(minWidth: 320, maxWidth: 600),
                                            child: product.images!.isNotEmpty ? Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CarouselSlider.builder(
                                                  itemCount: product.images!.length,
                                                  carouselController: carouselController,
                                                  itemBuilder: (context, index, realIndex) {
                                                    if (product.video != null && index == 1) {
                                                      return Video(video: product.video!);
                                                    } else {
                                                      return FadeInImage.memoryNetwork(
                                                        placeholder: kTransparentImage,
                                                        image: product.images![index],
                                                        width: width,
                                                        height: 375,
                                                        fit: BoxFit.cover,
                                                      );
                                                    }
                                                  },
                                                  options: CarouselOptions(
                                                    viewportFraction: 1,
                                                    initialPage: productVariant["2"] != null ? 1 : 0,
                                                    height: 375,
                                                    enlargeCenterPage: true,
                                                    onPageChanged: (index, reason) {
                                                      Provider.of<Values>(context, listen: false).setActiveImage(index);
                                                      carouselThumbController.animateToPage(index);
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                            child: SvgPicture.asset("assets/icons/prev.svg", semanticsLabel: 'Wishlist', width: 14, height: 24),
                                                            onTap: () {
                                                              var x = activeImage - 1;

                                                              if (x < 0) {
                                                                x = product.images!.length-1;
                                                              }

                                                              Provider.of<Values>(context, listen: false).setActiveImage(x);
                                                              carouselController.previousPage();
                                                              carouselThumbController.previousPage();
                                                            }
                                                        ),
                                                        GestureDetector(
                                                            child: SvgPicture.asset("assets/icons/next.svg", semanticsLabel: 'Wishlist', width: 14, height: 24),
                                                            onTap: () {
                                                              var x = activeImage + 1;

                                                              if (x > product.images!.length-1) {
                                                                x = 0;
                                                              }

                                                              Provider.of<Values>(context, listen: false).setActiveImage(x);
                                                              carouselController.nextPage();
                                                              carouselThumbController.nextPage();
                                                            }
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ],
                                            ) : FadeInImage.memoryNetwork(
                                              placeholder: kTransparentImage,
                                              image: product.image!,
                                              width: width,
                                              height: 375,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15, right: 15),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                (percent != "") ? Align(
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
                                                      child: Text(percent, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                                                    ),
                                                  ),
                                                ) : const Spacer(),
                                                Column(
                                                  children: [
                                                    GestureDetector(
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
                                                    const SizedBox(height: 15),
                                                    if (product.url != "") GestureDetector(
                                                        child: SvgPicture.asset("assets/icons/share.svg", semanticsLabel: 'Share', width: 22, height: 22),
                                                        onTap: () async {
                                                          final box = context.findRenderObject() as RenderBox?;
                                                          var nameShare = product.name!;
                                                          var urlShare = product.url;

                                                          await Share.share(
                                                            "$nameShare - $urlShare",
                                                            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                                                          );
                                                        }
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                  if (product.images!.isNotEmpty) const SizedBox(height: 10),
                                  if (product.images!.isNotEmpty) CarouselSlider.builder(
                                    itemCount: product.images!.length,
                                    carouselController: carouselThumbController,
                                    itemBuilder: (context, index, realIndex) {
                                      return GestureDetector(
                                        onTap: () {
                                          Provider.of<Values>(context, listen: false).setActiveImage(index);
                                          carouselController.animateToPage(index);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 15),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                child: FadeInImage.memoryNetwork(
                                                  placeholder: kTransparentImage,
                                                  image: product.images![index],
                                                  width: 54,
                                                  height: 54,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Visibility(
                                                  visible: activeImage != index,
                                                  child: Container(
                                                    width: 54,
                                                    height: 54,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      color: HexColor("#55667E").withOpacity(0.3),
                                                    ),
                                                  )
                                              ),
                                              if (index == 1) SvgPicture.asset("assets/icons/video.svg", semanticsLabel: 'Video', width: 38, height: 21),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    options: CarouselOptions(
                                      height: 54,
                                      padEnds: false,
                                      enableInfiniteScroll: false,
                                      viewportFraction: 0.18,
                                      disableCenter: true,
                                      autoPlayCurve: Curves.fastOutSlowIn,
                                      scrollDirection: Axis.horizontal,
                                      initialPage: productVariant["2"] != null && product.video == "" ? 1 : 0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width-110),
                                              child: Text(
                                                  product.name!,
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                                              ),
                                            ),
                                            Wrap(
                                              alignment: WrapAlignment.center,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  special != "" ? special : price,
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                ),
                                                const SizedBox(width: 5),
                                                if (special != "") Text(
                                                  price,
                                                  style: TextStyle(fontSize: 12, color: HexColor("#FF9186"), decoration: TextDecoration.lineThrough),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Wrap(
                                          children: [
                                            Text(
                                              LocaleKeys.textSku.tr(),
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              sku,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                        if (product.qws!.isNotEmpty) Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            const Divider(),
                                            const SizedBox(height: 6),
                                            Text(
                                              LocaleKeys.qwFlowers.tr(),
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: List<Widget>.generate(product.qws!.length, (int index) {
                                                if (product.qws![index].use2 == 1) {
                                                  FormGroup formQws() =>
                                                      fb.group(<String, Object>{
                                                        'qws_use': FormControl<int>(
                                                            value: 1
                                                        ),
                                                      });

                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                                                        child: Wrap(
                                                          crossAxisAlignment: WrapCrossAlignment.end,
                                                          children: [
                                                            Text(LocaleKeys.or.tr()),
                                                            const SizedBox(width: 20),
                                                            SizedBox(
                                                              width: 80,
                                                              child: ReactiveFormBuilder(
                                                                form: formQws,
                                                                builder: (context, form, child) {
                                                                  return ReactiveTextField(
                                                                    formControlName: 'qws_use',
                                                                    decoration: InputDecoration(
                                                                      enabledBorder: UnderlineInputBorder(
                                                                        borderSide: BorderSide(width: 0.5, color: HexColor(productIndexVariant == product.qws![index].index ? "#FF9186" : "#434D56")),
                                                                      ),
                                                                      hintText: "00",
                                                                      isDense: true,
                                                                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                                                    ),
                                                                    style: TextStyle(color: HexColor("#434D56"), fontSize: 14),
                                                                    textAlign: TextAlign.center,
                                                                    keyboardType: TextInputType.number,
                                                                    onSubmitted: (formControl) {
                                                                      if (form.control("qws_use").value > 0) {
                                                                        Provider.of<Values>(context, listen: false).setProductIndex(product.qws![index].index);
                                                                        Provider.of<Values>(context, listen: false).setQwUse(form.control("qws_use").value);

                                                                        var response = Provider.of<Values>(context, listen: false).jsonResponse({
                                                                          "type": 1,
                                                                          "method": "price",
                                                                          "pid": product.qws![index].pids,
                                                                          "city_id": cityId,
                                                                          "language_id": languageId,
                                                                          "product_id": productId,
                                                                          "qw": form.control("qws_use").value
                                                                        });

                                                                        response.then((value) => Provider.of<Values>(context, listen: false).setProductPrice(product.qws![index].index, value, form.control("qws_use").value));
                                                                      } else {
                                                                        form.control("qws_use").value = 1;
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Wrap(
                                                        children: [
                                                          Text(LocaleKeys.textQwsMin.tr()),
                                                          Text(LocaleKeys.minimum.tr(), style: const TextStyle(fontWeight: FontWeight.w500))
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Provider.of<Values>(context, listen: false).setProductIndex(product.qws![index].index);
                                                    },
                                                    child: Container(
                                                      width: 52.3,
                                                      height: 52.3,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(3),
                                                        border: Border.all(color: HexColor(productIndexVariant == product.qws![index].index ? "#FF7061" : "#C0D0DD"), width: 1),
                                                        color: HexColor(productIndexVariant == product.qws![index].index ? "#FFF5F4" : "#FFFFFF"),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                                      child: Center(
                                                          child: Text(product.qws![index].name!)
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }),
                                            ),
                                          ],
                                        ),
                                        if (productVariant["1"] != null && (productVariant["2"] != null || productVariant["3"] != null)) Builder(
                                            builder: (context) {
                                              return Column(
                                                children: [
                                                  const SizedBox(height: 5),
                                                  const Divider(),
                                                  const SizedBox(height: 15),
                                                  Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Provider.of<Values>(context, listen: false).setProductIndex(1);

                                                            if (productVariant["1"]["image"] != "") {
                                                              carouselController.animateToPage(0);
                                                              carouselThumbController.animateToPage(0);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(3),
                                                              border: Border.all(color: HexColor(productIndexVariant == 1 ? "#FF9186" : "#C0D0DD"), width: 1),
                                                              color: Colors.white,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const SizedBox(height: 10),
                                                                Text(LocaleKeys.textVariant1.tr(), style: TextStyle(color: HexColor(productIndexVariant == 1 ? "#FF9186" : "#434D56"))),
                                                                const SizedBox(height: 4),
                                                                Text(productVariant["1"]["price"], style: TextStyle(color: HexColor(productIndexVariant == 1 ? "#FF9186" : "#434D56"))),
                                                                const SizedBox(height: 16),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      top: BorderSide(
                                                                        color: HexColor(productIndexVariant == 1 ? "#FF9186" : "#C0D0DD"),
                                                                        width: 0.5,
                                                                      ),
                                                                    ),
                                                                    color: HexColor(productIndexVariant == 1 ? "#FFF5F4" : "#F5FBFF"),
                                                                  ),
                                                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                                                  width: (width / 3) - 15,
                                                                  child: Wrap(
                                                                    alignment: WrapAlignment.center,
                                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                                    children: [
                                                                      SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 1 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (productVariant["2"] != null && (productVariant["1"] != null || productVariant["3"] != null)) GestureDetector(
                                                          onTap: () {
                                                            Provider.of<Values>(context, listen: false).setProductIndex(2);

                                                            if (productVariant["2"]["image2"] != "") {
                                                              carouselController.animateToPage(1);
                                                              carouselThumbController.animateToPage(1);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(3),
                                                              border: Border.all(color: HexColor(productIndexVariant == 2 ? "#FF9186" : "#C0D0DD"), width: 1),
                                                              color: Colors.white,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const SizedBox(height: 10),
                                                                Text(LocaleKeys.textVariant2.tr(), style: TextStyle(color: HexColor(productIndexVariant == 2 ? "#FF9186" : "#434D56"))),
                                                                const SizedBox(height: 4),
                                                                Text(productVariant["2"]["price"], style: TextStyle(color: HexColor(productIndexVariant == 2 ? "#FF9186" : "#434D56"))),
                                                                const SizedBox(height: 16),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      top: BorderSide(
                                                                        color: HexColor(productIndexVariant == 2 ? "#FF9186" : "#C0D0DD"),
                                                                        width: 0.5,
                                                                      ),
                                                                    ),
                                                                    color: HexColor(productIndexVariant == 2 ? "#FFF5F4" : "#F5FBFF"),
                                                                  ),
                                                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                                                  width: (width / 3) - 15,
                                                                  child: Wrap(
                                                                    alignment: WrapAlignment.center,
                                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                                    children: [
                                                                      SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 2 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                      const SizedBox(width: 8),
                                                                      SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 2 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (productVariant["3"] != null && (productVariant["1"] != null || productVariant["2"] != null)) GestureDetector(
                                                          onTap: () {
                                                            Provider.of<Values>(context, listen: false).setProductIndex(3);

                                                            if (productVariant["3"]["image"] != null) {
                                                              carouselController.animateToPage(2);
                                                              carouselThumbController.animateToPage(2);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(3),
                                                              border: Border.all(color: HexColor(productIndexVariant == 3 ? "#FF9186" : "#C0D0DD"), width: 1),
                                                              color: Colors.white,
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const SizedBox(height: 10),
                                                                Text(LocaleKeys.textVariant3.tr(), style: TextStyle(color: HexColor(productIndexVariant == 3 ? "#FF9186" : "#434D56"))),
                                                                const SizedBox(height: 4),
                                                                Text(productVariant["3"]["price"], style: TextStyle(color: HexColor(productIndexVariant == 3 ? "#FF9186" : "#434D56"))),
                                                                const SizedBox(height: 16),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      top: BorderSide(
                                                                        color: HexColor(productIndexVariant == 3 ? "#FF9186" : "#C0D0DD"),
                                                                        width: 0.5,
                                                                      ),
                                                                    ),
                                                                    color: HexColor(productIndexVariant == 3 ? "#FFF5F4" : "#F5FBFF"),
                                                                  ),
                                                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                                                  width: (width / 3) - 15,
                                                                  child: Wrap(
                                                                    alignment: WrapAlignment.center,
                                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                                    children: [
                                                                      SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 3 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                      const SizedBox(width: 8),
                                                                      SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 3 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                      const SizedBox(width: 8),
                                                                      SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 3 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                        if (productVariant["4"] != null) Builder(
                                            builder: (context) {
                                              var min = LocaleKeys.textMinimum.tr();
                                              var priceText = productVariant["4"]["price"];
                                              var priceInt = productVariant["4"]["price_int"];
                                              var price4 = "$min $priceText";

                                              FormGroup form() =>
                                                  fb.group(<String, Object>{
                                                    'price': FormControl<int>(
                                                        value: productVariant["4"]["price_int"]
                                                    ),
                                                  });

                                              return Column(
                                                children: [
                                                  const SizedBox(height: 4),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Provider.of<Values>(context, listen: false).setProductIndex(4);

                                                      if (productVariant["4"]["image"] != null) {
                                                        carouselController.animateToPage(3);
                                                        carouselThumbController.animateToPage(3);
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(3),
                                                        border: Border.all(color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#C0D0DD"), width: 1),
                                                        color: Colors.white,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const SizedBox(height: 10),
                                                          Text(LocaleKeys.textVariant4.tr(), style: TextStyle(color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#434D56"))),
                                                          SizedBox(
                                                            width: 100,
                                                            child: ReactiveFormBuilder(
                                                              form: form,
                                                              builder: (context, form, child) {
                                                                return ReactiveTextField(
                                                                  formControlName: 'price',
                                                                  decoration: InputDecoration(
                                                                    enabledBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(width: 0.5, color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#434D56")),
                                                                    ),
                                                                    isDense: true,
                                                                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                                                  ),
                                                                  style: TextStyle(color: HexColor("#434D56"), fontSize: 14),
                                                                  textAlign: TextAlign.center,
                                                                  keyboardType: TextInputType.number,
                                                                  onSubmitted: (formControl) {
                                                                    Provider.of<Values>(context, listen: false).setProductIndex(4);

                                                                    if (productVariant["4"]["image"] != null) {
                                                                      carouselController.animateToPage(3);
                                                                      carouselThumbController.animateToPage(3);
                                                                    }

                                                                    if (form.control("price").value < priceInt) {
                                                                      formControl.value = priceInt;
                                                                    }

                                                                    Provider.of<Values>(context, listen: false).setVariant4(form.control("price").value);
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(price4, style: TextStyle(color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#434D56"))),
                                                          const SizedBox(height: 16),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              border: Border(
                                                                top: BorderSide(
                                                                  color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#C0D0DD"),
                                                                  width: 0.5,
                                                                ),
                                                              ),
                                                              color: HexColor(productIndexVariant == 4 ? "#FFF5F4" : "#F5FBFF"),
                                                            ),
                                                            padding: const EdgeInsets.symmetric(vertical: 7),
                                                            width: width,
                                                            child: Wrap(
                                                              alignment: WrapAlignment.center,
                                                              crossAxisAlignment: WrapCrossAlignment.center,
                                                              children: [
                                                                SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                const SizedBox(width: 8),
                                                                SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                const SizedBox(width: 8),
                                                                SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                const SizedBox(width: 8),
                                                                SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                                const SizedBox(width: 8),
                                                                SvgPicture.asset("assets/icons/variant.svg", color: HexColor(productIndexVariant == 4 ? "#FF9186" : "#434D56"), semanticsLabel: 'Variant', width: 19, height: 19),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                        if (variants.isNotEmpty) Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            const Divider(),
                                            const SizedBox(height: 6),
                                            Text(
                                              LocaleKeys.productVarText.tr(),
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: List<Widget>.generate(variants.length, (int index) {
                                                return Wrap(
                                                    alignment: WrapAlignment.center,
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    children: [
                                                      SvgPicture.asset("assets/icons/circle.svg", color: HexColor("#C0D0DD"), semanticsLabel: 'Circle', width: 6, height: 6),
                                                      const SizedBox(width: 6),
                                                      Text(variants[index].name!, style: TextStyle(color: HexColor("#434D56"), fontWeight: FontWeight.w300)),
                                                      const SizedBox(width: 2),
                                                      Text(variants[index].qw!.toString(), style: TextStyle(color: HexColor("#434D56"), fontWeight: FontWeight.w300)),
                                                      const SizedBox(width: 2),
                                                      Text(LocaleKeys.varSh.tr(), style: TextStyle(color: HexColor("#434D56"), fontWeight: FontWeight.w300)),
                                                    ]
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        if (product.description != "") Builder(
                                            builder: (context) {
                                              return Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  const Divider(),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.white,
                                                            elevation: 0,
                                                            padding: EdgeInsets.zero
                                                        ),
                                                        onPressed: () {
                                                          if (desAnim) {
                                                            Provider.of<Values>(context, listen: false).setDesAnim(false);
                                                          } else {
                                                            Provider.of<Values>(context, listen: false).setDesAnim(true);
                                                          }
                                                        },
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              LocaleKeys.productDes.tr(),
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: HexColor("#434D56")),
                                                            ),
                                                            Transform(
                                                              alignment: Alignment.center,
                                                              transform: Matrix4.rotationZ(
                                                                !desAnim ? 0 : 3.1415926535897932,
                                                              ),
                                                              child: SvgPicture.asset("assets/icons/arrow.svg", color: HexColor("#434D56"), semanticsLabel: 'Alt', width: 8, height: 8),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: desAnim,
                                                        child: Html(
                                                          data: product.description,
                                                          style: {
                                                            "body": Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
                                                            "h2": Style(
                                                                fontSize: const FontSize(14.0),
                                                                color: Colors.black
                                                            ),
                                                          },
                                                        ),
                                                      ),
                                                      const Divider(),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (product.products!.isNotEmpty) Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: width,
                                          margin: const EdgeInsets.only(bottom: 15),
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide( //                    <--- top side
                                                color: HexColor("#C0D0DD").withAlpha(70),
                                                width: 6,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                              child: Text(
                                                LocaleKeys.textRelated.tr(),
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                              )
                                          ),
                                        ),
                                        Container(
                                          width: width,
                                          margin: const EdgeInsets.only(left: 15),
                                          child: RawScrollbar(
                                            thumbColor: HexColor("#BBCAD3"),
                                            trackColor: HexColor("#E8EDF0"),
                                            trackVisibility: true,
                                            trackRadius: const Radius.circular(5),
                                            trackBorderColor: Colors.transparent,
                                            thumbVisibility: true,
                                            thickness: 7,
                                            radius: const Radius.circular(5),
                                            controller: scrollController,
                                            scrollbarOrientation: ScrollbarOrientation.bottom,
                                            child: Container(
                                              margin: const EdgeInsets.only(bottom: 20),
                                              child: SingleChildScrollView(
                                                controller: scrollController,
                                                scrollDirection: Axis.horizontal,
                                                child: Relateds(product: product),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ]
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Column(
                                        children: [
                                          AnimatedOpacity(
                                            opacity: buyVisible ? 1 : 0,
                                            duration: const Duration(milliseconds: 100),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                if (!submitLoaded) {
                                                  Provider.of<Values>(context, listen: false).setSubmitLoaded(true);
                                                  var vazBuy = false;

                                                  if (product.vaza == 1 && product.vazaId != 0) {
                                                    for (var e in product.products!) {
                                                      if (e.cartId != 0 && product.vazaId == e.productId) {
                                                        vazBuy = true;
                                                      }
                                                    }
                                                  }

                                                  final vazId = !vazBuy ? product.vazaId : 0;
                                                  var qws = <int, dynamic>{};

                                                  if (product.qws!.isNotEmpty) {
                                                    for (var element in product.qws!) {
                                                      if (element.index == productIndexVariant) {
                                                        qws = {element.pids!: qwUse != 0 ? qwUse : ""};
                                                      }
                                                    }
                                                  }

                                                  await Provider.of<Values>(context, listen: false).cartAdd(product.productId!, 1, productIndexVariant, vazId!, qws.isNotEmpty ? qws : null, variant4);

                                                  if (context.mounted) {
                                                    Provider.of<Values>(context).setPopupVisible(true);
                                                    showCupertinoModalPopup(context: context, builder: (BuildContext context) {
                                                      return const CartScreen();
                                                    });
                                                  }
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
                                          const SizedBox(height: 20),
                                          if (product.payIcons!.isNotEmpty) SizedBox(
                                            width: width,
                                            child: Wrap(
                                              alignment: WrapAlignment.spaceBetween,
                                              children: List.generate(product.payIcons!.length, (index) {
                                                final String image = product.payIcons![index];

                                                if (image.contains(".svg")) {
                                                  return SvgPicture.network(product.payIcons![index], semanticsLabel: 'Pay icon', width: 44, height: 28);
                                                } else {
                                                  return Image.network(product.payIcons![index], width: 44, height: 28);
                                                }
                                              }),
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                  if (product.viewed!.isNotEmpty) Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 15),
                                        Container(
                                          width: width,
                                          margin: const EdgeInsets.only(bottom: 15),
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide( //                    <--- top side
                                                color: HexColor("#C0D0DD").withAlpha(70),
                                                width: 6,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                              child: Text(
                                                LocaleKeys.viewed.tr(),
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                              )
                                          ),
                                        ),
                                        Container(
                                          width: width,
                                          margin: const EdgeInsets.only(left: 15),
                                          child: RawScrollbar(
                                            thumbColor: HexColor("#BBCAD3"),
                                            trackColor: HexColor("#E8EDF0"),
                                            trackVisibility: true,
                                            trackRadius: const Radius.circular(5),
                                            trackBorderColor: Colors.transparent,
                                            thumbVisibility: true,
                                            thickness: 7,
                                            radius: const Radius.circular(5),
                                            controller: scrollViewedController,
                                            scrollbarOrientation: ScrollbarOrientation.bottom,
                                            child: Container(
                                              margin: EdgeInsets.only(bottom: Platform.isAndroid ? 20 : 55),
                                              child: SingleChildScrollView(
                                                controller: scrollViewedController,
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: List.generate(product.viewed!.length, (index) {
                                                    return Padding(
                                                        padding: const EdgeInsets.only(right: 10, top: 2, bottom: 2, left: 2),
                                                        child: ItemProduct(product: product.viewed![index])
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (Platform.isAndroid) const SizedBox(height: 20),
                                      ]
                                  ),
                                ]
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                          child: Visibility(
                            visible: !buyVisible,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!submitLoaded) {
                                  Provider.of<Values>(context, listen: false).setSubmitLoaded(true);
                                  var vazBuy = false;

                                  if (product.vaza == 1 && product.vazaId != 0) {
                                    for (var e in product.products!) {
                                      if (e.cartId != 0 && product.vazaId == e.productId) {
                                        vazBuy = true;
                                      }
                                    }
                                  }

                                  final vazId = !vazBuy ? product.vazaId : 0;
                                  var qws = <int, dynamic>{};

                                  if (product.qws!.isNotEmpty) {
                                    for (var element in product.qws!) {
                                      if (element.index == productIndexVariant) {
                                        qws = {element.pids!: qwUse != 0 ? qwUse : ""};
                                      }
                                    }
                                  }

                                  await Provider.of<Values>(context, listen: false).cartAdd(product.productId!, 1, productIndexVariant, vazId!, qws.isNotEmpty ? qws : null, variant4);

                                  if (context.mounted) {
                                    Provider.of<Values>(context, listen: false).setPopupVisible(true);

                                    showCupertinoModalPopup(context: context, builder: (BuildContext context) {
                                      return const CartScreen();
                                    });
                                  }
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
                        ),
                        const Search(),
                      ]
                  );
                } else {
                  return const EmptyBox();
                }
              } else if (snapshot.hasError) {
                return const Error();
              }

              if (!isLoading) {
                return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    child: Center(
                        child: CupertinoActivityIndicator(
                          animating: true,
                          radius: 18,
                          color: HexColor("#FF7061"),
                        )
                    )
                );
              } else {
                return const EmptyBox();
              }
            }
        ),
        bottomNavigationBar: const Footer()
      ),
    );
  }
}