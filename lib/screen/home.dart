import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import '../extensions.dart';
import '../values.dart';
import '../models/api.dart';
import '../screen/city.dart';
import '../screen/item_product.dart';
import '../screen/error.dart';
import '../screen/header.dart';
import '../screen/footer.dart';
import '../screen/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'dart:convert';

class Home extends StatelessWidget {
  const Home({super.key, required this.title});

  final String title;

  FormGroup form() => fb.group(<String, Object>{
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
  });

  @override
  Widget build(BuildContext context) {
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final double width = MediaQuery.of(context).size.width;
    final bool isLoading = Provider.of<Values>(context, listen: false).isLoading;

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

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Stack(
                                alignment: AlignmentDirectional.bottomStart,
                                children: [
                                  if (data.homeSlider != null) CarouselSlider(
                                    options: CarouselOptions(
                                      height: 370,
                                      viewportFraction: 1.0,
                                      autoPlayCurve: Curves.linear,
                                      autoPlay: true,
                                    ),
                                    items: data.homeSlider!.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Stack(
                                              children: [
                                                Stack(
                                                  alignment: AlignmentDirectional.topStart,
                                                  children: [
                                                    FadeInImage.memoryNetwork(
                                                        placeholder: kTransparentImage,
                                                        image: i.image!,
                                                        width: double.infinity,
                                                        height: 240,
                                                        fit: BoxFit.cover,
                                                        alignment: Alignment.topLeft
                                                    ),
                                                    Align(
                                                        alignment: Alignment.bottomCenter,
                                                        child: Image.asset("assets/images/shad.png", width: double.infinity, height: 220, fit: BoxFit.cover)
                                                    )
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 15, top: 50),
                                                  child: Text(
                                                    i.title!.toUpperCase(),
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              ]
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  if (data.popular != null) Padding(
                                    padding: EdgeInsets.only(bottom: 2, top: data.homeSlider == null ? 15 : 0),
                                    child: Align(
                                      alignment: AlignmentDirectional.bottomEnd,
                                      child: SizedBox(
                                        width: width,
                                        height: 171,
                                        child: ListView.builder(
                                            itemExtent: 140,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: data.popular!.length,
                                            itemBuilder: (context, index) {
                                              var category = data.popular![index];

                                              return Padding(
                                                  padding: const EdgeInsets.only(left: 15),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      Provider.of<Values>(context, listen: false).setCategoryId(category.categoryId!);
                                                      Provider.of<Values>(context, listen: false).setData("category");
                                                      Navigator.pushNamed(context, "category");
                                                    },
                                                    child: Container(
                                                      width: 140,
                                                      height: 165,
                                                      margin: const EdgeInsets.only(bottom: 8),
                                                      clipBehavior: Clip.hardEdge,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(4),
                                                          border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                          color: Colors.white,
                                                          image: DecorationImage(
                                                              image: NetworkImage(category.image!),
                                                              alignment: Alignment.bottomCenter
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.3),
                                                              spreadRadius: 0,
                                                              blurRadius: 5,
                                                              offset: const Offset(1, 3), // changes position of shadow
                                                            ),
                                                          ]
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 10, right: 10, top: 12),
                                                        child: Text(
                                                          category.name!,
                                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                              );
                                            }
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                            if (data.productModules != null) Builder(
                                builder: (context) {
                                  var modules = data.productModules!;

                                  if (modules.isNotEmpty) {
                                    return Column(
                                      children: List<Widget>.generate(modules.length, (int index) {
                                        var module = modules[index];

                                        return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: width,
                                                margin: const EdgeInsets.only(bottom: 15),
                                                padding: const EdgeInsets.symmetric(vertical: 15),
                                                child: Center(
                                                    child: Text(
                                                      module.title!,
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                                    )
                                                ),
                                              ),
                                              Container(
                                                width: width,
                                                margin: const EdgeInsets.only(bottom: 15),
                                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  alignment: WrapAlignment.spaceBetween,
                                                  children: List.generate(module.products!.length, (index) {
                                                    return ItemProduct(product: module.products![index]);
                                                  }),
                                                ),
                                              ),
                                              if (module.categoryId! != 0) const SizedBox(height: 10), Center(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Provider.of<Values>(context, listen: false).setCategoryId(module.categoryId!);
                                                    Provider.of<Values>(context, listen: false).setData("category");
                                                    Navigator.pushNamed(context, "category");
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 0.5,
                                                              color: HexColor("#434D56")
                                                          ),
                                                          borderRadius: BorderRadius.circular(35)
                                                      ),
                                                      backgroundColor: Colors.white,
                                                      elevation: 0,
                                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                                                  ),
                                                  child: Text(LocaleKeys.more.tr(), style: TextStyle(fontSize: 16, color: HexColor("#434D56"))),
                                                ),
                                              ), const SizedBox(height: 10),
                                            ]
                                        );
                                      }),
                                    );
                                  } else {
                                    return const EmptyBox();
                                  }
                                }
                            ),
                            const SizedBox(height: 12),
                            if (data.banners != null) Builder(
                                builder: (context) {
                                  if (data.banners!.isNotEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Column(
                                        children: List<Widget>.generate(data.banners!.length, (int index) {
                                          var banner = data.banners![index];

                                          return Padding(
                                              padding: const EdgeInsets.only(bottom: 15),
                                              child:  Stack(
                                                  children: [
                                                    FadeInImage.memoryNetwork(
                                                      placeholder: kTransparentImage,
                                                      image: banner.image!,
                                                      width: double.infinity,
                                                      height: 245,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 28),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.max,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const SizedBox(height: 68),
                                                          Text(
                                                            banner.title!,
                                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                                                          ),
                                                          const SizedBox(height: 15),
                                                          if (banner.categoryId! != 0) ElevatedButton(
                                                            onPressed: () {
                                                              Provider.of<Values>(context, listen: false).setCategoryId(banner.categoryId!);
                                                              Provider.of<Values>(context, listen: false).setData("category");
                                                              Navigator.pushNamed(context, "category");
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                shape: RoundedRectangleBorder(
                                                                    side: BorderSide(
                                                                        width: 0.5,
                                                                        color: HexColor("#434D56")
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(35)
                                                                ),
                                                                backgroundColor: Colors.white,
                                                                elevation: 0,
                                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                                                            ),
                                                            child: Text(LocaleKeys.moreCollection.tr(), style: TextStyle(fontSize: 16, color: HexColor("#434D56"))),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]
                                              )
                                          );
                                        }),
                                      ),
                                    );
                                  } else {
                                    return const EmptyBox();
                                  }
                                }
                            ),
                          ],
                        ),
                      ),
                      const Search(),
                    ],
                  );
                }
                else if (snapshot.hasError) {
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

void register(response, context) {
  response = json.decode(response);
  Provider.of<Values>(context, listen: false).setSubmitLoaded(false);

  FocusScopeNode currentFocus = FocusScope.of(context);

  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(
            (response['login']['email'] == 1 ?
            LocaleKeys.newsletterError3.tr() :
            LocaleKeys.newsletterSuccess.tr()),
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      }
  );
}