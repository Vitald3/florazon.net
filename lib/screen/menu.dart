import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import '../extensions.dart';
import '../values.dart';
import '../models/api.dart';
import '../screen/header.dart';
import '../screen/error.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final int menuCategoryId = Provider.of<Values>(context).menuCategoryId;
    final String currentRoute = Provider.of<Values>(context, listen: false).currentRoute;
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final int languageId = Provider.of<Values>(context, listen: false).languageId;
    final List<Categories>? categories = Provider.of<Values>(context, listen: false).categories;
    final int menuChildCategoryId = Provider.of<Values>(context, listen: false).menuChildCategoryId;
    final bool isLoading = Provider.of<Values>(context, listen: false).isLoading;
    final double width = MediaQuery.of(context).size.width;
    final List<Categories>? childrenMenu = Provider.of<Values>(context, listen: false).childrenMenu;

    return FutureBuilder<Data>(
        future: api,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!;

            return SafeArea(
              top: false,
              bottom: false,
              child: Scaffold(
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
                          color: HexColor("#EFF3F7"),
                          child: SingleChildScrollView(
                            child: Builder(
                                builder: (context) {
                                  var mes = data.setting!;
                                  var menuLanguages = data.languages!;

                                  var selectLang = "";
                                  var selectCode = "";

                                  for (var item in menuLanguages) {
                                    if (item.languageId == languageId) {
                                      selectLang = item.name!;
                                      selectCode = item.code!;
                                    }
                                  }

                                  return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        ColoredBox(
                                          color: HexColor("#F4FBFF"),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        Visibility(
                                                          visible: mes.fbMessenger != "",
                                                          child: IconButton(
                                                              constraints: const BoxConstraints(),
                                                              padding: EdgeInsets.zero,
                                                              iconSize: 36,
                                                              icon: SvgPicture.asset("assets/icons/messenger.svg", semanticsLabel: 'Messenger', width: 36, height: 36),
                                                              onPressed: () {
                                                                _makeAppMessage(mes.fbMessenger!, "", "FbMessenger");
                                                              }
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: mes.whatsapp != "",
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 10),
                                                            child: IconButton(
                                                                constraints: const BoxConstraints(),
                                                                padding: EdgeInsets.zero,
                                                                iconSize: 36,
                                                                icon: SvgPicture.asset("assets/icons/whatsapp.svg", semanticsLabel: 'Whatsapp', width: 36, height: 36),
                                                                onPressed: () {
                                                                  _makeAppMessage(mes.whatsapp!, "", "Whatsapp");
                                                                }
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: mes.viber != "",
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 10),
                                                            child: IconButton(
                                                                constraints: const BoxConstraints(),
                                                                padding: EdgeInsets.zero,
                                                                iconSize: 36,
                                                                icon: SvgPicture.asset("assets/icons/viber.svg", semanticsLabel: 'Viber', width: 36, height: 36),
                                                                onPressed: () {
                                                                  _makeAppMessage(mes.viber!, "", "Viber");
                                                                }
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: mes.telegram != "",
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 10),
                                                            child: IconButton(
                                                                constraints: const BoxConstraints(),
                                                                padding: EdgeInsets.zero,
                                                                iconSize: 36,
                                                                icon: SvgPicture.asset("assets/icons/telegram.svg", semanticsLabel: 'Telegram', width: 36, height: 36),
                                                                onPressed: () {
                                                                  _makeAppMessage(mes.telegram!, "", "Telegram");
                                                                }
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                  mes.phone != "" ? GestureDetector(
                                                      onTap: () {
                                                        _makeAppMessage(mes.phone!, "", "Call");
                                                      },
                                                      child: Text(mes.phone!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                                                  ) : const EmptyBox()
                                                ]
                                            ),
                                          ),
                                        ),
                                        ColoredBox(
                                          color: HexColor("#FFFFFF"),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                                children: <Widget>[
                                                  menuLanguages.isNotEmpty ?
                                                  GestureDetector(
                                                    onTap: () {
                                                      showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (BuildContext context) {
                                                        return SafeArea(
                                                          top: false,
                                                          bottom: false,
                                                          child: Scaffold(
                                                            backgroundColor: Colors.transparent,
                                                            bottomNavigationBar: Container(
                                                              height: (menuLanguages.length * 40) + 40,
                                                              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                                                              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
                                                              child: Stack(
                                                                  children: [
                                                                    const Align(
                                                                      alignment: Alignment.topCenter,
                                                                      child: SizedBox(
                                                                        width: 110,
                                                                        height: 6,
                                                                        child: ClipRRect(
                                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                          child: ColoredBox(color: Colors.black12),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    ListView.builder(
                                                                        itemCount: menuLanguages.length,
                                                                        itemBuilder: (context, index) {
                                                                          var lang = menuLanguages[index];
                                                                          var lCode = lang.code;

                                                                          return GestureDetector(
                                                                            onTap: () {
                                                                              Provider.of<Values>(context, listen: false).resetHistory();
                                                                              Provider.of<Values>(context, listen: false).setPopupVisible(false);
                                                                              Provider.of<Values>(context, listen: false).setLanguageId(lang.languageId!);
                                                                              Provider.of<Values>(context, listen: false).setLanguageCode(lang.code2!);
                                                                              context.setLocale(Locale(lang.code2!));
                                                                              Provider.of<Values>(context, listen: false).setData(currentRoute == 'city' ? '/' : currentRoute);
                                                                              Navigator.pushNamed(context, currentRoute);
                                                                            },
                                                                            child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: <Widget>[
                                                                                  SvgPicture.asset("assets/icons/lang/$lCode.svg", allowDrawingOutsideViewBox: true, semanticsLabel: lang.name, width: 31, height: 18),
                                                                                  const SizedBox(width: 10, height: 40),
                                                                                  Text(
                                                                                    lang.name!,
                                                                                    style: TextStyle(fontSize: 14, color: HexColor("#434D56"), decoration: TextDecoration.none),
                                                                                  ),
                                                                                ]
                                                                            ),
                                                                          );
                                                                        }
                                                                    ),
                                                                  ]
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                    },
                                                    child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Text(selectLang),
                                                          Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Text(LocaleKeys.change.tr()),
                                                                SvgPicture.asset("assets/icons/arrow.svg", semanticsLabel: 'Arrow', width: 11, height: 7)
                                                              ]
                                                          ),
                                                        ]
                                                    ),
                                                  ) : const EmptyBox(),
                                                ]
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                            visible: categories != null,
                                            child: Container(
                                              width: width,
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: width,
                                                    child: Wrap(
                                                      spacing: 15,
                                                      runSpacing: 18,
                                                      alignment: WrapAlignment.spaceBetween,
                                                      children: List.generate(categories!.length, (index) {
                                                        var category = categories[index];

                                                        return GestureDetector(
                                                          onTap: () {
                                                            if (category.children!.isNotEmpty) {
                                                              Provider.of<Values>(context, listen: false).setMenuCategoryId(category.categoryId!);
                                                              Provider.of<Values>(context, listen: false).setMenuChildren(category.children!);
                                                            } else {
                                                              Provider.of<Values>(context, listen: false).setMenuCategoryId(0);
                                                              Provider.of<Values>(context, listen: false).setMenuChildCategoryId(0);
                                                              Provider.of<Values>(context, listen: false).setCategoryId(category.categoryId!);
                                                              Provider.of<Values>(context, listen: false).setData("category");
                                                              Navigator.pushNamed(context, "category");
                                                            }
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.all(10),
                                                            width: (width/3)-22,
                                                            clipBehavior: Clip.hardEdge,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(4),
                                                                border: Border.all(color: HexColor(menuCategoryId == category.categoryId! ? "#FF7061" : "#C0D0DD"), width: 0.5),
                                                                color: Colors.white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors.black.withOpacity(0.1),
                                                                      spreadRadius: 0,
                                                                      blurRadius: 4,
                                                                      offset: const Offset(0, 4)
                                                                  ),
                                                                ]
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 38,
                                                                  child: Text(
                                                                    category.name!,
                                                                    style: const TextStyle(fontSize: 14),
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                                FadeInImage.memoryNetwork(
                                                                  placeholder: kTransparentImage,
                                                                  image: category.image!,
                                                                  width: 85,
                                                                  height: 85,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  ),
                                                  if (childrenMenu != null && childrenMenu.isNotEmpty && menuCategoryId > 0) Container(
                                                    width: width-30,
                                                    color: Colors.white,
                                                    margin: const EdgeInsets.only(top: 20),
                                                    padding: const EdgeInsets.all(20),
                                                    child: Wrap(
                                                      spacing: 10,
                                                      runSpacing: 18,
                                                      alignment: WrapAlignment.start,
                                                      children: List.generate(childrenMenu.length, (index) {
                                                        var category = childrenMenu[index];

                                                        return GestureDetector(
                                                          onTap: () {
                                                            Provider.of<Values>(context, listen: false).setMenuChildCategoryId(category.categoryId!);
                                                            Provider.of<Values>(context, listen: false).setCategoryId(category.categoryId!);
                                                            Provider.of<Values>(context, listen: false).setData("category");
                                                            Navigator.pushNamed(context, "category");
                                                          },
                                                          child: SizedBox(
                                                            width: (width/3)-30,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                FadeInImage.memoryNetwork(
                                                                  placeholder: kTransparentImage,
                                                                  image: category.image!,
                                                                  width: 54,
                                                                  height: 60,
                                                                  fit: BoxFit.contain,
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Text(
                                                                  category.name!,
                                                                  style: TextStyle(fontWeight: FontWeight.w500, color: HexColor(menuChildCategoryId == category.categoryId! ? "#FF7061" : "#434D56")),
                                                                  textAlign: TextAlign.center,
                                                                  maxLines: 2,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            child: TextButton(
                                              onPressed: () {
                                                var seoUrl = data.setting!.seoUrl ?? "kiev";

                                                _openLink("https://florazon.net/$selectCode/$seoUrl/privacy-policy");
                                              },
                                              style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  alignment: Alignment.centerLeft
                                              ),
                                              child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    SvgPicture.asset("assets/icons/circle.svg", semanticsLabel: 'Circle', width: 6, height: 6),
                                                    const SizedBox(width: 6),
                                                    Text(LocaleKeys.textPolicy.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56")), textAlign: TextAlign.center),
                                                  ]
                                              ),
                                            )
                                        )
                                      ]
                                  );
                                }
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            );
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
    );
  }
}

Uri url(String phone, String message, String app) {
  late String link;

  if (Platform.isAndroid) {
    if (app == 'Whatsapp') {
      link = "https://wa.me/$phone/?text=${Uri.parse(message)}";
    } else if (app == 'FbMessenger') {
      link = "fb-messenger://user/$phone";
    } else if (app == 'Viber') {
      link = "viber://chat?number=%2B$phone";
    } else if (app == 'Telegram') {
      link = "https://t.me/$phone";
    } else if (app == 'Call') {
      link = "tel:$phone";
    }
  } else {
    if (app == 'Whatsapp') {
      link = "https://api.whatsapp.com/send?phone=$phone=${Uri.parse(message)}";
    } else if (app == 'FbMessenger') {
      link = "https://m.me/$phone";
    } else if (app == 'Viber') {
      link = "viber://chat?number=%2B$phone";
    } else if (app == 'Telegram') {
      link = "https://t.me/$phone";
    } else if (app == 'Call') {
      link = "tel:$phone";
    }
  }

  return Uri.parse(link);
}

Future<void> _makeAppMessage(String phone, String message, String app) async {
  if (!await launchUrl(url(phone, message, app))) {
    throw Exception('Could not launch $app');
  }
}

Future<void> _openLink(String link) async {
  if (!await launchUrl(Uri.parse(link))) {
    throw Exception('Could not launch $link');
  }
}