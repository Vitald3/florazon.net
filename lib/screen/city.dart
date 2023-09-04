import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import '../extensions.dart';
import '../values.dart';
import '../models/api.dart';
import '../screen/error.dart';
import '../screen/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class City extends StatelessWidget {
  const City({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final int cityId = Provider.of<Values>(context, listen: false).cityId;
    final String currentRoute = Provider.of<Values>(context, listen: false).currentRoute;
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final bool isLoading = Provider.of<Values>(context, listen: false).isLoading;

    return FutureBuilder<Data>(
        future: api,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;

            return data.regions != null ? SafeArea(
              top: false,
              bottom: false,
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: cityId == 0 ? AppBar(
                    automaticallyImplyLeading: false,
                    titleSpacing: 15.0,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: Border(
                        bottom: BorderSide(
                            color: HexColor("#C0D0DD"),
                            width: 1
                        )
                    ),
                    title: Center(
                      child: Image.asset("assets/icons/logo.png", width: 124, height: 25),
                    )
                ) : AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  backgroundColor: Colors.white,
                  title: const Header(),
                  elevation: 0.5,
                ),
                body: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (cityId != 0) Builder(
                            builder: (context) {
                              return ColoredBox(
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
                                              GestureDetector(
                                                onTap: () {
                                                  Provider.of<Values>(context, listen: false).setPopupVisible(false);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                                  child: Text(
                                                    data.setting!.geoCity!,
                                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              Transform(
                                                alignment: Alignment.center,
                                                transform: Matrix4.rotationZ(
                                                  3.1415926535897932,
                                                ),
                                                child: SvgPicture.asset("assets/icons/down.svg", color: Colors.white, semanticsLabel: 'Arrow down', width: 11, height: 7),
                                              ),
                                            ]
                                        ),
                                      ),
                                    )
                                ),
                              );
                            }
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    child: Center(
                                        child: Text(
                                          LocaleKeys.v.tr(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, letterSpacing: -0.2, height: 1.2),
                                        )
                                    )
                                ),
                                const SizedBox(height: 11),
                                SizedBox(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: data.regions!.length,
                                      itemBuilder: (context, index) {
                                        var region = data.regions?[index];

                                        return region != null && region.cities!.isNotEmpty ?
                                        Column(
                                            children: <Widget>[
                                              Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    const Expanded(
                                                        child: Divider()
                                                    ),
                                                    Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                                                          child: ImageWidget(
                                                              url: region.flag!,
                                                              w: 93,
                                                              h: 63
                                                          ),
                                                        )
                                                    ),
                                                    const Expanded(
                                                        child: Divider()
                                                    )
                                                  ]
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                                                  child: Text(
                                                    region.name!,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  )
                                              ),
                                              Wrap(
                                                  direction: Axis.horizontal,
                                                  spacing: 14,
                                                  children: <Widget>[
                                                    for(var city in region.cities!) GestureDetector(
                                                        onTap: () {
                                                          Provider.of<Values>(context, listen: false).resetHistory();
                                                          Provider.of<Values>(context, listen: false).setPopupVisible(false);
                                                          Provider.of<Values>(context, listen: false).setCityId(city.id!);
                                                          Provider.of<Values>(context, listen: false).setData(currentRoute == 'city' ? '/' : currentRoute);
                                                          Navigator.pushNamed(context, currentRoute == 'city' ? '/' : currentRoute);
                                                        },
                                                        child:SizedBox(
                                                            width: 79,
                                                            child: Center(
                                                                child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 51,
                                                                        height: 51,
                                                                        child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(51),
                                                                            child: ImageWidget(
                                                                                url: city.image??"",
                                                                                w: 51,
                                                                                h: 51
                                                                            )
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                          padding: const EdgeInsets.only(top: 12, bottom: 14),
                                                                          child: Text(city.name!, textAlign: TextAlign.center,)
                                                                      )
                                                                    ]
                                                                )
                                                            )
                                                        )
                                                    )
                                                  ]
                                              ),
                                              (index == data.regions!.length-1 && data.setting!.description!.isNotEmpty && cityId == 0) ? Padding(
                                                  padding: const EdgeInsets.only(top: 30),
                                                  child: Html(
                                                    data: data.setting!.description!,
                                                    style: {
                                                      "h2": Style(
                                                          fontSize: const FontSize(14.0),
                                                          margin: const EdgeInsets.only(bottom: 6),
                                                          color: Colors.black
                                                      ),
                                                    },
                                                  )
                                              ) : const EmptyBox()
                                            ]
                                        )
                                            : const SizedBox();
                                      }),
                                ),
                              ]
                          ),
                        ),
                      ]
                  ),
                ),
              ),
            ) : const EmptyBox();
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