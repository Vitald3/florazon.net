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
import '../screen/menu.dart';
import '../screen/sort_popup.dart';
import '../screen/footer.dart';
import '../screen/filter_popup.dart';
import '../screen/search.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final Future<Data>? api = Provider.of<Values>(context).api;
    final bool isLoading = Provider.of<Values>(context, listen: false).isLoading;
    final Filters? sorts = Provider.of<Values>(context, listen: false).sorts;
    final Categories? category = Provider.of<Values>(context, listen: false).category;
    var children = Provider.of<Values>(context, listen: false).children;
    var width = MediaQuery.of(context).size.width;
    final bool loadMore = Provider.of<Values>(context, listen: false).loadMore;
    final int categoryId = Provider.of<Values>(context, listen: false).categoryId;

    var products = Provider.of<Values>(context, listen: false).products;
    final List<Products> prods = products;

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
                if (products.isEmpty && category!.products!.isNotEmpty) {
                  products = category.products!;
                }

                if (category!.products!.isEmpty) {
                  products = <Products>[];
                }

                return Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Provider.of<Values>(context, listen: false).setPopupVisible(true);

                                      showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const Menu();
                                          }
                                      );
                                    },
                                    child: Container(
                                      width: width-30,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(35),
                                        color: Colors.white,
                                        border: Border.all(color: HexColor("6D8497"), width: 0.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            LocaleKeys.textCategory.tr(),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 6),
                                          SvgPicture.asset("assets/icons/circle.svg", semanticsLabel: 'Plus'),
                                          const SizedBox(width: 6),
                                          SizedBox(
                                            width: (width/2)-8,
                                            child: Text(
                                              category.name!,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          ),
                                          const Spacer(),
                                          SvgPicture.asset("assets/icons/plusZ.svg", semanticsLabel: 'Plus'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (children != null && children.isNotEmpty) Container(
                                    width: width-30,
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(top: 15),
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 18,
                                      alignment: WrapAlignment.spaceBetween,
                                      children: List.generate(children.length, (index) {
                                        var category = children[index];

                                        return GestureDetector(
                                          onTap: () {
                                            Provider.of<Values>(context, listen: false).setMenuChildCategoryId(category.categoryId!);
                                            Provider.of<Values>(context, listen: false).setCategoryId(category.categoryId!);
                                            Provider.of<Values>(context, listen: false).setData("category");
                                            Navigator.pushNamed(context, "category");
                                          },
                                          child: SizedBox(
                                            width: (width/4)-30,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                FadeInImage.memoryNetwork(
                                                  placeholder: kTransparentImage,
                                                  image: category.image!,
                                                  width: 64,
                                                  height: 74,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  category.name!,
                                                  style: TextStyle(fontSize: 12, color: HexColor(categoryId == category.categoryId! ? "#FF7061" : "#434D56")),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  products.isNotEmpty ? Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Stack(
                                              alignment: Alignment.topLeft,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 60),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      alignment: WrapAlignment.spaceBetween,
                                                      children: List.generate(products.length, (index) {
                                                        return ItemProduct(product: products[index]);
                                                      }),
                                                    ),
                                                  ],
                                                ),
                                                Stack(
                                                  alignment: Alignment.topLeft,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Provider.of<Values>(context, listen: false).setPopupVisible(true);
                                                            Provider.of<Values>(context, listen: false).setOpenFilters(false);
                                                            Provider.of<Values>(context, listen: false).setFilterLoaded(false);
                                                            Provider.of<Values>(context, listen: false).setResetLoaded(false);
                                                            Provider.of<Values>(context, listen: false).setCountOpenFilter(0);

                                                            showDialog(context: context, barrierDismissible: true, builder: (BuildContext context) {
                                                              return const FilterPopup();
                                                            });
                                                          },
                                                          child: Container(
                                                            width: (width/2)-18,
                                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(35),
                                                              color: Colors.white,
                                                              border: Border.all(color: HexColor("6D8497"), width: 0.5),
                                                            ),
                                                            child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Text(Provider.of<Values>(context, listen: false).getCountFilters()),
                                                                  const Spacer(),
                                                                  SvgPicture.asset("assets/icons/plusZ.svg", semanticsLabel: 'Plus'),
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                        if (sorts != null) GestureDetector(
                                                          onTap: () {
                                                            showDialog(context: context, builder: (BuildContext context) {
                                                              return const SortPopup();
                                                            });
                                                          },
                                                          child: Container(
                                                            width: (width/2)-18,
                                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(35),
                                                              color: Colors.white,
                                                              border: Border.all(color: HexColor("6D8497"), width: 0.5),
                                                            ),
                                                            child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: <Widget>[
                                                                  Text(LocaleKeys.textSort.tr()),
                                                                  const Spacer(),
                                                                  SvgPicture.asset("assets/icons/plusZ.svg", semanticsLabel: 'Plus'),
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ]
                                          ),
                                          if (category.pages! > 0 && Provider.of<Values>(context, listen: false).page < category.pages!) const SizedBox(height: 20),
                                          if (category.pages! > 0 && Provider.of<Values>(context, listen: false).page < category.pages!) Center(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                if (!loadMore) {
                                                  Provider.of<Values>(context, listen: false).setPage();
                                                  if (prods.isEmpty) Provider.of<Values>(context, listen: false).setProducts(false);
                                                  await Provider.of<Values>(context, listen: false).setData("category");

                                                  if (context.mounted) {
                                                    Provider.of<Values>(context, listen: false).setLoadMore(false);
                                                    Provider.of<Values>(context, listen: false).setProducts(false);
                                                  }
                                                }
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
                                              child: loadMore ? SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: CupertinoActivityIndicator(
                                                  animating: true,
                                                  radius: 18,
                                                  color: HexColor("#FF7061"),
                                                ),
                                              ) : Wrap(
                                                children: [
                                                  Text(LocaleKeys.loadMore.tr(), style: TextStyle(fontSize: 16, color: HexColor("#434D56"))),
                                                  const SizedBox(width: 6),
                                                  SvgPicture.asset("assets/icons/downMore.svg", semanticsLabel: 'Close', width: 7, height: 13)
                                                ],
                                              ),
                                            ),
                                          )
                                        ]
                                    ),
                                  ) : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(Provider.of<Values>(context).selectedFilters.isEmpty ? LocaleKeys.textEmpty.tr() : LocaleKeys.textEmptyFilter.tr()),
                                        const SizedBox(height: 20),
                                        if (Provider.of<Values>(context).selectedFilters.isNotEmpty) ElevatedButton(
                                          onPressed: () {
                                            Provider.of<Values>(context, listen: false).setFilterLoaded(false);
                                            Provider.of<Values>(context, listen: false).setResetLoaded(false);
                                            Provider.of<Values>(context, listen: false).setCategoryId(category.categoryId!);
                                            Provider.of<Values>(context, listen: false).setData("category");
                                            Provider.of<Values>(context, listen: false).setOpenFilters(false);
                                            Navigator.pushNamed(context, "category");
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
                                          ),
                                          child: Text(LocaleKeys.resetParam.tr().toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                            )
                        ),
                      ),
                      const Search(),
                    ]
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
        ),
        bottomNavigationBar: const Footer()
      ),
    );
  }
}