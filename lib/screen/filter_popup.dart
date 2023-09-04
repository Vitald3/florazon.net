import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../extensions.dart';
import '../values.dart';
import '../models/api.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterPopup extends StatelessWidget {
  const FilterPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final List<String> selectedFilters = Provider.of<Values>(context).selectedFilters;
    final bool filterLoaded = Provider.of<Values>(context, listen: false).filterLoaded;
    final bool openFilters = Provider.of<Values>(context, listen: false).openFilters;
    final bool resetLoaded = Provider.of<Values>(context, listen: false).resetLoaded;
    final int countOpenFilter = Provider.of<Values>(context, listen: false).countOpenFilter;
    final List<Filters>? filterGroups = Provider.of<Values>(context, listen: false).filterGroups;
    var filters = Provider.of<Values>(context, listen: false).filters;
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<Data>(
            future: api,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
                      margin: const EdgeInsets.only(top: 130),
                      width: width - 30,
                      constraints: BoxConstraints(
                        maxHeight: height-145,
                      ),
                      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      child: SingleChildScrollView(
                        child: Wrap(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12, right: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(LocaleKeys.textFilter.tr(), style: TextStyle(fontSize: 16, color: HexColor("#434D56"), fontWeight: FontWeight.w500)),
                                  GestureDetector(
                                    onTap: () {
                                      Provider.of<Values>(context, listen: false).setOpenFilters(false);
                                      Navigator.of(context).pop();
                                    },
                                    child: SvgPicture.asset("assets/icons/closeW.svg", semanticsLabel: 'Close', width: 30, height: 30),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(
                                maxHeight: 500
                              ),
                              padding: const EdgeInsets.only(bottom: 15),
                              child: SingleChildScrollView(
                                child: Stack(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  children: [
                                    Wrap(
                                      children: List<Widget>.generate(filterGroups!.length, (int index) {
                                        var filter = filterGroups[index];

                                        return ExpansionTile(
                                          title: Text(filter.name!),
                                          tilePadding: const EdgeInsets.only(left: 12, right: 8, top: 0),
                                          controlAffinity: ListTileControlAffinity.trailing,
                                          shape: const Border(),
                                          onExpansionChanged: (bool expanding) {
                                            if (expanding && selectedFilters.isNotEmpty) {
                                              Provider.of<Values>(context, listen: false).setCountOpenFilter(countOpenFilter + 1);
                                              Provider.of<Values>(context, listen: false).setOpenFilters(true);
                                            } else {
                                              if (countOpenFilter - 1 == 0) {
                                                Provider.of<Values>(context, listen: false).setOpenFilters(false);
                                              }

                                              Provider.of<Values>(context, listen: false).setCountOpenFilter(countOpenFilter - 1);
                                            }
                                          },
                                          children: <Widget>[
                                            Container(
                                              constraints: const BoxConstraints(
                                                maxHeight: 300,
                                              ),
                                              padding: EdgeInsets.only(bottom: index == filterGroups.length-1 ? 65 : 0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (openFilters && filter.active == 1) Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                                    child: Wrap(
                                                      spacing: 6,
                                                      children: List<Widget>.generate(selectedFilters.length, (int index) {
                                                        var select = selectedFilters[index];

                                                        for (var i in filter.filter!) {
                                                          if (select == i.val) {
                                                            return GestureDetector(
                                                              onTap: () async {
                                                                if (!resetLoaded) {
                                                                  Provider.of<Values>(context, listen: false).setResetLoaded(true);

                                                                  int found = selectedFilters.indexOf(i.val!);

                                                                  if (found != -1) {
                                                                    selectedFilters.removeAt(found);
                                                                  } else if (i.active! || (selectedFilters.isNotEmpty && selectedFilters.contains(i.val))) {
                                                                    selectedFilters.remove(i.value);
                                                                  }

                                                                  Provider.of<Values>(context, listen: false).setSelectedFilters(selectedFilters);

                                                                  if (selectedFilters.isEmpty) {
                                                                      Provider.of<Values>(context, listen: false).resetFilters();
                                                                  }

                                                                  await Provider.of<Values>(context, listen: false).setData("category");

                                                                  if (context.mounted) {
                                                                    Provider.of<Values>(context, listen: false).setProducts(true);

                                                                    if (selectedFilters.isEmpty) {
                                                                      Provider.of<Values>(context, listen: false).setOpenFilters(false);
                                                                    }

                                                                    Provider.of<Values>(context, listen: false).setResetLoaded(false);
                                                                    Navigator.of(context).pop();
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  border: Border.all(color: HexColor("#FF9186"), width: 0.5),
                                                                  color: HexColor("#ffc6c0").withOpacity(0.6),
                                                                ),
                                                                constraints: const BoxConstraints(
                                                                  maxWidth: 114,
                                                                ),
                                                                clipBehavior: Clip.hardEdge,
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                        child: Text(i.name!, style: TextStyle(fontSize: 14, color: HexColor("#434D56"), overflow: TextOverflow.ellipsis)),
                                                                    ),
                                                                    SvgPicture.asset("assets/icons/close2.svg", semanticsLabel: 'Close', width: 11, height: 11),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }

                                                        return const EmptyBox();
                                                      }),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ListView.builder(
                                                        itemExtent: 50,
                                                        itemCount: filter.filter!.length,
                                                        itemBuilder: (context, index) {
                                                          var value = filter.filter![index];
                                                          var name = value.name!;
                                                          var val = value.val;
                                                          var active = (value.active! || (selectedFilters.isNotEmpty && selectedFilters.contains(val))) ? true : false;

                                                          return GestureDetector(
                                                            onTap: () async {
                                                              for (var item in filter.filter!) {
                                                                item.active = false;
                                                                int found = selectedFilters.indexOf(val!);

                                                                if (val == item.val) {
                                                                  item.active = true;
                                                                }

                                                                if (found != -1) {
                                                                  selectedFilters.removeAt(found);
                                                                } else {
                                                                  selectedFilters.remove(item.value);
                                                                }
                                                              }
                                                              selectedFilters.remove(val);
                                                              selectedFilters.add(val.toString());

                                                              Provider.of<Values>(context, listen: false).setSelectedFilters(selectedFilters);
                                                              Provider.of<Values>(context, listen: false).setFilters(filter);
                                                              Provider.of<Values>(context, listen: false).setOpenFilters(true);
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 20,
                                                                    height: 20,
                                                                    alignment: Alignment.center,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                                      color: HexColor("#F4FBFF"),
                                                                    ),
                                                                    child: Container(
                                                                      width: 15,
                                                                      height: 15,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        color: HexColor(active ? "#434D56" : "#F4FBFF"),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 12),
                                                                  Text(name, style: TextStyle(color: HexColor(active ? "#FF9186" : "#434D56"))),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                    if (filters != null && openFilters) Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 12, right: 12, top: (Platform.isAndroid ? 25 : 15), bottom: 0),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  if (!filterLoaded) {
                                                    Provider.of<Values>(context, listen: false).setFilterLoaded(true);
                                                    Provider.of<Values>(context, listen: false).setResetLoaded(false);
                                                    filters.active = 1;
                                                    await Provider.of<Values>(context, listen: false).setData("category");

                                                    if (context.mounted) {
                                                      Provider.of<Values>(context, listen: false).setProducts(true);
                                                      Navigator.of(context).pop();
                                                    }
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            width: 0.5,
                                                            color: HexColor("#C0D0DD")
                                                        ),
                                                        borderRadius: BorderRadius.circular(30)
                                                    ),
                                                    backgroundColor: HexColor("F4FBFF"),
                                                    elevation: 0,
                                                    minimumSize: Size(filters.active! == 0 ? width-70 : (width/2)-42, 40),
                                                    padding: const EdgeInsets.symmetric(vertical: 15)
                                                ),
                                                child: filterLoaded ? SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child: CircularProgressIndicator(color: HexColor("#FF9186")),
                                                ) : Text(LocaleKeys.enter.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56"), fontWeight: FontWeight.w600)),
                                              ),
                                              Visibility(
                                                visible: filters.active! > 0,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    if (!resetLoaded) {
                                                      Provider.of<Values>(context, listen: false).setResetLoaded(true);

                                                      for (var item in filters.filter!) {
                                                        int found = selectedFilters.indexOf(item.val!);

                                                        if (found != -1) {
                                                          selectedFilters.removeAt(found);
                                                        } else if (item.active! || (selectedFilters.isNotEmpty && selectedFilters.contains(item.val))) {
                                                          selectedFilters.remove(item.value);
                                                        }
                                                      }

                                                      Provider.of<Values>(context, listen: false).setSelectedFilters(selectedFilters);
                                                      Provider.of<Values>(context, listen: false).resetFilters();
                                                      await Provider.of<Values>(context, listen: false).setData("category");

                                                      if (context.mounted) {
                                                        Provider.of<Values>(context, listen: false).setProducts(true);
                                                        Provider.of<Values>(context, listen: false).setOpenFilters(false);
                                                        Provider.of<Values>(context, listen: false).setResetLoaded(false);
                                                        Navigator.of(context).pop();
                                                      }
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 0.5,
                                                              color: HexColor("#C0D0DD")
                                                          ),
                                                          borderRadius: BorderRadius.circular(30)
                                                      ),
                                                      backgroundColor: HexColor("F4FBFF"),
                                                      elevation: 0,
                                                      minimumSize: Size((width/2)-42, 40),
                                                      padding: const EdgeInsets.symmetric(vertical: 15)
                                                  ),
                                                  child: resetLoaded ? SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: CircularProgressIndicator(color: HexColor("#FF9186")),
                                                  ) : Text(LocaleKeys.textReset.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56"), fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                            ]
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return const EmptyBox();
            }
        ),
      )
    );
  }
}