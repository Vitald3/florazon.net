import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../values.dart';
import '../models/api.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SortPopup extends StatelessWidget {
  const SortPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> selectedFilters = Provider.of<Values>(context).selectedFilters;
    final bool sortLoaded = Provider.of<Values>(context, listen: false).sortLoaded;
    final bool sortResetLoaded = Provider.of<Values>(context, listen: false).sortResetLoaded;
    final Filters? sorts = Provider.of<Values>(context, listen: false).sorts;
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {

              },
              child: Container(
                padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
                margin: const EdgeInsets.only(top: 130),
                width: width - 30,
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
                            Text(LocaleKeys.textSort.tr(), style: TextStyle(fontSize: 16, color: HexColor("#434D56"), fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: SvgPicture.asset("assets/icons/closeW.svg", semanticsLabel: 'Close', width: 30, height: 30),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 17),
                      if (sorts != null) Container(
                          constraints: const BoxConstraints(
                            maxHeight: 350,
                          ),
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: sorts.filter!.length,
                              itemBuilder: (BuildContext context, int index) {
                                var sort = sorts.filter![index];
                                var name = sort.name!;
                                var active = (sort.active! || (selectedFilters.isNotEmpty && selectedFilters.contains(sort.val))) ? true : false;

                                if (!active && index == 0 && selectedFilters.isEmpty) {
                                  active = true;
                                }

                                if (name == 'sort1') {
                                  name = LocaleKeys.sort1.tr();
                                } else if (name == 'sort2') {
                                  name = LocaleKeys.sort2.tr();
                                } else if (name == 'sort3') {
                                  name = LocaleKeys.sort3.tr();
                                } else if (name == 'sort4') {
                                  name = LocaleKeys.sort4.tr();
                                }

                                var val = sort.val;

                                return GestureDetector(
                                  onTap: () async {
                                    for (var item in sorts.filter!) {
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

                                    await Provider.of<Values>(context, listen: false).setSelectedFilters(selectedFilters);
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
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 15),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (!sortLoaded) {
                                    Provider.of<Values>(context, listen: false).setSortLoaded(true);
                                    Provider.of<Values>(context, listen: false).setSortResetLoaded(false);
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
                                    minimumSize: Size((width/2)-42, 40),
                                    padding: const EdgeInsets.symmetric(vertical: 15)
                                ),
                                child: sortLoaded ? SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(color: HexColor("#FF9186")),
                                ) : Text(LocaleKeys.enter.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56"), fontWeight: FontWeight.w600)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (!sortResetLoaded) {
                                    for (var item in sorts!.filter!) {
                                      int found = selectedFilters.indexOf(item.val!);

                                      if (found != -1) {
                                        selectedFilters.removeAt(found);
                                      } else if (item.active! || (selectedFilters.isNotEmpty && selectedFilters.contains(item.val))) {
                                        selectedFilters.remove(item.value);
                                      }
                                    }

                                    Provider.of<Values>(context, listen: false).setSelectedFilters(selectedFilters);
                                    Provider.of<Values>(context, listen: false).setPopupVisible(false);
                                    Provider.of<Values>(context, listen: false).setSortLoaded(false);
                                    Provider.of<Values>(context, listen: false).setSortResetLoaded(true);
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
                                    minimumSize: Size((width/2)-42, 40),
                                    padding: const EdgeInsets.symmetric(vertical: 15)
                                ),
                                child: sortResetLoaded ? SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(color: HexColor("#FF9186")),
                                ) : Text(LocaleKeys.textReset.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56"), fontWeight: FontWeight.w600)),
                              ),
                            ]
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
}