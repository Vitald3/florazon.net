import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:hexcolor/hexcolor.dart';
import '../extensions.dart';
import '../values.dart';
import '../models/api.dart';
import '../screen/error.dart';
import '../screen/header.dart';
import '../screen/footer.dart';
import '../screen/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class Payment extends StatelessWidget {
  const Payment({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = Provider.of<Values>(context, listen: false).isLoading;
    final bool submitLoaded = Provider.of<Values>(context, listen: false).submitLoaded;
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final int orderId = Provider.of<Values>(context, listen: false).orderId;
    final double width = MediaQuery.of(context).size.width;
    final double webViewHeight = Provider.of<Values>(context, listen: false).webViewHeight;
    final String selectPayment = Provider.of<Values>(context).selectPayment;
    final int cityId = Provider.of<Values>(context).cityId;
    final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
      Factory(() => EagerGestureRecognizer())
    };
    UniqueKey key = UniqueKey();
    WebViewController? controller;
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    void updateHeight() async {
      double height = double.parse(await controller!.runJavascriptReturningResult('document.documentElement.scrollHeight;'));

      if (webViewHeight != height && context.mounted) {
        Provider.of<Values>(context, listen: false).setWebViewHeight(height);
      }
    }

    launchURL(String url) async {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalNonBrowserApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    void afterPayment(context) {
      var response = Provider.of<Values>(context, listen: false).jsonResponse({
        "type": 1,
        "method": "order_update",
        "city_id": Provider.of<Values>(context, listen: false).cityId,
        "currency": Provider.of<Values>(context, listen: false).currencyCode,
        "order_id": orderId,
        "payment": selectPayment,
        "account_id": Provider.of<Values>(context, listen: false).accountId,
        "language_id": Provider.of<Values>(context, listen: false).languageId,
        "session_id": Provider.of<Values>(context, listen: false).sessionId
      });

      response.then((value) {
        Provider.of<Values>(context, listen: false).setSubmitLoaded(false);

        if (value != null) {
          value = json.decode(value);

          if (value!["success"] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.orderPaySuccess.tr()),
              ),
            );

            Provider.of<Values>(context, listen: false).setOrderId(0);
            Provider.of<Values>(context, listen: false).setData("/");
            Navigator.pushNamed(context, "/");
          } else {
            Provider.of<Values>(context, listen: false).setOrderId(0);
            Provider.of<Values>(context, listen: false).setData("/");
            Navigator.pushNamed(context, "/");
          }
        }
      });
    }

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
                final Data data = snapshot.data!;
                var seoUrl = data.setting!.seoUrl ?? "kiev";

                if (data.order != null && data.order?.orderId != 0) {
                  final Order order = data.order!;
                  Stripe.publishableKey = order.stripe!.publishableKey!;

                  Future<void> initPaymentSheet(Order data) async {
                    try {
                      await Stripe.instance.initPaymentSheet(
                        paymentSheetParameters: SetupPaymentSheetParameters(
                          merchantDisplayName: 'Florazon',
                          paymentIntentClientSecret: data.stripe!.paymentIntent!,
                          customerEphemeralKeySecret: data.stripe!.ephemeralKey!,
                          customerId: data.stripe!.customer!,
                          style: ThemeMode.light,
                        ),
                      );

                      try {
                        await Stripe.instance.presentPaymentSheet().then((value) {
                          afterPayment(context);
                        });
                      } catch (errorr) {
                        if (context.mounted) {
                          if (errorr is StripeException) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('An error occured ${errorr.error.localizedMessage}'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('An error occured $errorr'),
                              ),
                            );
                          }
                        }
                      }
                    } catch (e) {
                      rethrow;
                    }
                  }

                  var oid = LocaleKeys.textOid.tr();
                  final oidText = order.oid;
                  oid = "$oid №$oidText";

                  return Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Stack(
                                    alignment: AlignmentDirectional.bottomStart,
                                    children: [
                                      const Divider(),
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Text(
                                          oid,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    children: List.generate(order.products!.length, (index) {
                                      final product = order.products![index];
                                      final sku = product.sku!;
                                      final String textArt = LocaleKeys.textSku.tr();

                                      return Wrap(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
                                            child: Wrap(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                  child: FadeInImage.memoryNetwork(
                                                    placeholder: kTransparentImage,
                                                    image: product.image!,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: width-142,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 15, right: 0),
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            product.name!,
                                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                                          ),
                                                          const SizedBox(height: 3),
                                                          Text(
                                                            "$textArt $sku", style: const TextStyle(fontSize: 10),
                                                          ),
                                                          const SizedBox(height: 18),
                                                          Text(
                                                            product.total.toString(),
                                                            textAlign: TextAlign.right,
                                                          ),
                                                        ]
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    children: List.generate(order.totals!.length, (index) {
                                      return Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: width-100,
                                                child: Text(order.totals![index].title!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                              ),
                                              Text(order.totals![index].text!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: width,
                                  color: HexColor("#F4FBFF"),
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: width,
                                          child: Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(LocaleKeys.textOrderId.tr()),
                                              Text(oidText!)
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          width: width,
                                          child: Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(LocaleKeys.shipCustomer.tr()),
                                              Text(order.shippingFirstname!)
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          width: width,
                                          child: Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(LocaleKeys.shipTel.tr()),
                                              Text(order.telZ!)
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          width: width,
                                          child: Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(LocaleKeys.shipDate.tr()),
                                              Text(order.date!)
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          width: width,
                                          child: Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(LocaleKeys.shipTime.tr()),
                                              Text(order.time!)
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          width: width,
                                          child: Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(LocaleKeys.textAddress.tr()),
                                              Text(order.shippingAddress!)
                                            ],
                                          ),
                                        ),
                                        if (order.totals!.isNotEmpty) const Divider(),
                                        if (order.totals!.isNotEmpty) SizedBox(
                                          width: width,
                                          child: Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(LocaleKeys.totalPay.tr()),
                                              Text(order.totals![order.totals!.length-1].text!)
                                            ],
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(LocaleKeys.setPay.tr(), style: const TextStyle(fontSize: 18)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: HexColor("#C0D0DD"), width: 1),
                                          color: Colors.white,
                                        ),
                                        child: Wrap(
                                            alignment: WrapAlignment.start,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0), topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                                  color: HexColor("#c4c4c4").withOpacity(0.45),
                                                ),
                                                child: Wrap(
                                                  children: const [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                      child: Center(
                                                        child: Text(
                                                          "Credit/Debit Card",
                                                          style: TextStyle(fontSize: 16),
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(height: 1),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    if (order.monoPay != null && order.monoPay != "") ListTile(
                                                      title: SvgPicture.asset("assets/icons/monopay.svg", semanticsLabel: 'MonoPay', width: 231, height: 62, fit: BoxFit.contain),
                                                      horizontalTitleGap: 0.0,
                                                      contentPadding: const EdgeInsets.all(0),
                                                      leading: Radio<String>(
                                                        value: "mono",
                                                        groupValue: selectPayment,
                                                        onChanged: (String? value) {
                                                          Provider.of<Values>(context, listen: false).setPayment(value!);
                                                        },
                                                      ),
                                                    ),
                                                    if (order.stripe!.publishableKey != "") ListTile(
                                                      title: SizedBox(
                                                        width: width,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            SvgPicture.asset("assets/icons/stripe.svg", semanticsLabel: 'Stripe', width: 74, height: 70, fit: BoxFit.fitHeight),
                                                            SizedBox(
                                                              width: width,
                                                              child: Wrap(
                                                                children: [
                                                                  SvgPicture.asset("assets/icons/visa.svg", semanticsLabel: 'Visa', width: 28, height: 18),
                                                                  const SizedBox(width: 6),
                                                                  SvgPicture.asset("assets/icons/master.svg", semanticsLabel: 'MasterCard', width: 28, height: 18),
                                                                  const SizedBox(width: 6),
                                                                  SvgPicture.asset("assets/icons/applepay.svg", semanticsLabel: 'Apple Pay', width: 28, height: 18),
                                                                  const SizedBox(width: 6),
                                                                  SvgPicture.asset("assets/icons/gpay.svg", semanticsLabel: 'Google Pay', width: 28, height: 18),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      horizontalTitleGap: 0.0,
                                                      contentPadding: const EdgeInsets.all(0),
                                                      leading: Radio<String>(
                                                        value: "stripe",
                                                        groupValue: selectPayment,
                                                        onChanged: (String? value) {
                                                          Provider.of<Values>(context, listen: false).setPayment(value!);
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (!submitLoaded) {
                                            Provider.of<Values>(context, listen: false).setSubmitLoaded(true);

                                            if (selectPayment == "stripe") {
                                              initPaymentSheet(order);
                                            } else {
                                              showModalBottomSheet(
                                                context: context,
                                                backgroundColor: Colors.white,
                                                isScrollControlled: true,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(
                                                    top: Radius.circular(25.0),
                                                  ),
                                                ),
                                                builder: (builder) {
                                                  return FractionallySizedBox(
                                                    heightFactor: Platform.isIOS ? 0.8 : 0.64,
                                                    child: ClipRRect(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                                                      clipBehavior: Clip.hardEdge,
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(25),
                                                            topRight: Radius.circular(25),
                                                          ),
                                                        ),
                                                        child: Container(
                                                          height: webViewHeight,
                                                          alignment: Alignment.topCenter,
                                                          child: Scaffold(
                                                            resizeToAvoidBottomInset: true,
                                                            body: WebView(
                                                              key: key,
                                                              backgroundColor: Colors.white,
                                                              initialUrl: order.monoPay!,
                                                              onWebViewCreated: (WebViewController c) {
                                                                controller = c;
                                                              },
                                                              onPageFinished: (_) {
                                                                updateHeight();
                                                              },
                                                              javascriptMode: JavascriptMode.unrestricted,
                                                              navigationDelegate: (NavigationRequest request) async {
                                                                if (request.url.contains('checkout/failure')) {
                                                                  Provider.of<Values>(context, listen: false).setSubmitLoaded(false);
                                                                  Provider.of<Values>(context, listen: false).setInitialUrl(order.monoPay!);
                                                                  Navigator.pop(context);
                                                                } else if (request.url.contains('checkout/success')) {
                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(LocaleKeys.orderPaySuccess.tr()),
                                                                    ),
                                                                  );
                                                                  Provider.of<Values>(context, listen: false).setSubmitLoaded(false);
                                                                  Provider.of<Values>(context, listen: false).setInitialUrl(order.monoPay!);
                                                                  Provider.of<Values>(context, listen: false).setSubmitLoaded(false);
                                                                  Provider.of<Values>(context, listen: false).setOrderId(0);
                                                                  Provider.of<Values>(context, listen: false).setData("/");
                                                                  Navigator.pushNamed(context, "/");
                                                                } else if (request.url.contains("payment/mono/response")) {
                                                                  var url = request.url;
                                                                  Provider.of<Values>(context, listen: false).setInitialUrl("$url&order_id=$orderId&city_status=$cityId&region_status=$seoUrl&app=1");
                                                                } else {
                                                                  if (!request.url.contains("about:blank")) {
                                                                    await launchURL(request.url);
                                                                  }
                                                                }

                                                                return NavigationDecision.navigate;
                                                              },
                                                              gestureRecognizers: gestureRecognizers,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).whenComplete(() {
                                                Provider.of<Values>(context, listen: false).setSubmitLoaded(false);
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
                                        ) : Text(LocaleKeys.buttonContinue.tr().toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ]
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