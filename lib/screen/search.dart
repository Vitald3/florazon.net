import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:hexcolor/hexcolor.dart';
import '../extensions.dart';
import '../values.dart';
import '../models/api.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  static String _displayStringForOption(Products product) => product.name!;

  bool search(String fullText, String keyword) {
    for (var i = 0; i < keyword.length; i++) {
      if (keyword[i] != fullText[i]) return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final bool searchFieldActive = Provider.of<Values>(context).searchFieldActive;
    final bool searchVisible = Provider.of<Values>(context).searchVisible;
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;

    return FutureBuilder<Data>(
        future: api,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!;

            return Positioned(
              left: 0,
              top: 0,
              child: Visibility(
                visible: searchVisible,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Builder(
                    builder: (context) {
                      return Container(
                        width: width,
                        color: HexColor("#434D56"),
                        padding: const EdgeInsets.all(15),
                        child: Autocomplete<Products>(
                          displayStringForOption: _displayStringForOption,
                          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                TextField(
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(left: 17, right: 15, bottom: 19, top: 19),
                                    hintText: LocaleKeys.textSearch.tr(),
                                    hintStyle: TextStyle(
                                      color: HexColor("#434D56"),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: HexColor("#ccd6de"),
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: HexColor("#ccd6de"),
                                      ),
                                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(searchFieldActive ? 0 : 10), bottomRight: Radius.circular(searchFieldActive ? 0 : 10), topLeft: const Radius.circular(10), topRight: const Radius.circular(10)),
                                    ),
                                  ),
                                  style: TextStyle(color: HexColor("434D56")),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                      onPressed: () {
                                        Provider.of<Values>(context, listen: false).setProductId(data.products![0].productId!);
                                        Provider.of<Values>(context, listen: false).setSearchFieldActive(false);
                                        Provider.of<Values>(context, listen: false).updateSearchVisible(false);
                                        Provider.of<Values>(context, listen: false).setData("product");
                                        Navigator.pushNamed(context, "product");
                                      },
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          minimumSize: Size.zero,
                                          alignment: Alignment.centerRight
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 15),
                                        child: SvgPicture.asset("assets/icons/searchButton.svg", semanticsLabel: 'Search', width: 18, height: 18),
                                      ),
                                  ),
                                ),
                              ],
                            );
                          },
                          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Products> onSelected, Iterable<Products> products) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 2.0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10), topLeft: Radius.circular(0), topRight: Radius.circular(0)),
                                ),
                                color: Colors.white,
                                child: SizedBox(
                                  height: 58.0 * products.length,
                                  width: width - 30,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: products.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final Products product = products.elementAt(index);
                                      final String art = LocaleKeys.art.tr();

                                      return GestureDetector(
                                        onTap: () {
                                          onSelected(product);
                                          Provider.of<Values>(context, listen: false).setProductId(product.productId!);
                                          Provider.of<Values>(context, listen: false).setSearchFieldActive(false);
                                          Provider.of<Values>(context, listen: false).setData("product");
                                          Navigator.pushNamed(context, "product");
                                        },
                                        child: ListTile(
                                            title: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                    product.name!,
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                    '$art ${product.sku!}',
                                                    style: const TextStyle(fontSize: 12)
                                                ),
                                              ],
                                            )
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            var x = false;

                            for (var i in data.products!) {
                              if (search(i.name.toString().toLowerCase(), textEditingValue.text.toLowerCase())) {
                                x = true;
                              }
                            }

                            if (!x) {
                              Provider.of<Values>(context, listen: false).setSearchFieldActive(false);
                            } else {
                              Provider.of<Values>(context, listen: false).setSearchFieldActive(textEditingValue.text != '');
                            }

                            if (textEditingValue.text == '') {
                              return const Iterable<Products>.empty();
                            }

                            return data.products!.where((Products product) {
                              return search(product.name.toString().toLowerCase(), textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (Products selection) {
                            Provider.of<Values>(context, listen: false).setSearchFieldActive(false);
                          },
                        ),
                      );
                    }
                ),
              ),
            );
          } else {
            return const EmptyBox();
          }
        }
    );
  }
}