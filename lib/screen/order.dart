import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import '../models/api.dart';
import 'package:transparent_image/transparent_image.dart';

class OrderPopup extends StatelessWidget {
  const OrderPopup({super.key, required this.title, required this.order});

  final String title;
  final Orders order;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
            child: Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List<Widget>.generate(order.products!.length, (int index) {
                          final product = order.products![index];
                          final sku = product.sku!;
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
                                        width: width-128,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name!,
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                "$textArt $sku",
                                                style: const TextStyle(fontSize: 10),
                                              ),
                                              const Divider(),
                                              Text(
                                                product.total.toString(),
                                              ),
                                            ]
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                              const Divider(),
                            ],
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.orderIdText.tr()),
                            Text(order.oid.toString()),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.shipCustomer.tr()),
                            Text(order.shippingFirstname!),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.shipTel.tr()),
                            Text(order.telz!),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.shipDate.tr()),
                            Text(order.date!),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(LocaleKeys.shipTime.tr()),
                            Text(order.vrem!),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(LocaleKeys.textAddress.tr()),
                            ),
                            Expanded(
                              child: Text(order.shippingAddress1!, textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      ),
                      if (order.totals!.isNotEmpty) Wrap(
                        children: List<Widget>.generate(order.totals!.length, (int index) {
                          final total = order.totals![index];

                          return Wrap(
                              children: [
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(total.title!),
                                      Text(total.text!),
                                    ],
                                  ),
                                ),
                              ]
                          );
                        }),
                      ),
                    ]
                ),
                const Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: SizedBox(
                    width: 110,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: ColoredBox(color: Colors.black12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
    );
  }
}