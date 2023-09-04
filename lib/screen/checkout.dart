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
import '../screen/date.dart';
import '../screen/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:convert';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:io';

class Checkout extends StatelessWidget {
  const Checkout({super.key, required this.title});

  final String title;

  void couponSet(value, context) {
    value = json.decode(value);
    Provider.of<Values>(context, listen: false).setSubmitLoaded(false);

    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    if (value != null && value != []) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value['coupon'] != null ? LocaleKeys.couponSuccess.tr() : LocaleKeys.errorCoupon.tr()),
      ));

      if (value['coupon'] != null) {
        var totals = <Totals>[];

        for (var i in value!["totals"]) {
          totals.add(Totals.fromJson(i));
        }

        Provider.of<Values>(context, listen: false).setTotals(totals);
        Provider.of<Values>(context, listen: false).setCoupon(value['coupon']);
        Provider.of<Values>(context, listen: false).setCouponOpen(false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleKeys.networkNull.tr()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = Provider.of<Values>(context).isLoading;
    final bool submitLoaded = Provider.of<Values>(context, listen: false).submitLoaded;
    final bool notAdr = Provider.of<Values>(context, listen: false).notAdr;
    final bool agree = Provider.of<Values>(context, listen: false).agree;
    final String coupon = Provider.of<Values>(context, listen: false).coupon;
    final String selectTime = Provider.of<Values>(context, listen: false).selectTime;
    final String checkoutTel = Provider.of<Values>(context, listen: false).checkoutTel;
    final bool couponOpen = Provider.of<Values>(context, listen: false).couponOpen;
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final List<Cart> cart = Provider.of<Values>(context, listen: false).cart;
    final int commentTree = Provider.of<Values>(context, listen: false).commentTree;
    final int giftTree = Provider.of<Values>(context, listen: false).giftTree;
    final int chaiSet = Provider.of<Values>(context, listen: false).chaiSet;
    final double chai = Provider.of<Values>(context, listen: false).chai;
    final String chaiP = Provider.of<Values>(context, listen: false).chaiP;
    final List<Totals> totals = Provider.of<Values>(context, listen: false).totals;
    final List<Time> time = Provider.of<Values>(context, listen: false).time;
    final double width = MediaQuery.of(context).size.width;
    final String textTree = LocaleKeys.textTree.tr();
    final String textTree2 = LocaleKeys.textTree2.tr();
    final String textTree3 = LocaleKeys.textTree3.tr();
    final String textTree4 = LocaleKeys.textTree4.tr();
    var lang = "";

    String getNoun(number, one, two, five) {
      var n = (number).abs();
      n %= 100;
      if (n >= 5 && n <= 20) {
        return five;
      }
      n %= 10;
      if (n == 1) {
        return one;
      }
      if (n >= 2 && n <= 4) {
        return two;
      }
      return five;
    }

    final commentCountTree = getNoun(commentTree, textTree2, textTree3, textTree4);
    var commentTextTree = "$textTree $commentTree $commentCountTree";
    final giftCountTree = getNoun(giftTree, textTree2, textTree3, textTree4);
    var giftTextTree = "$textTree $giftTree $giftCountTree";

    Map<String, dynamic>? addressValidate(AbstractControl<dynamic> control) {
      return (!notAdr || (notAdr && control.isNotNull && control.value != "")) ? null : {'addressValidate': false};
    }

    FormGroup couponForm() => fb.group(<String, Object>{
      'coupon': FormControl<String>(
        value: coupon,
        validators: [Validators.required],
      ),
    });

    void setChai(dynamic s, String p) {
      if (p != "pl") {
        Provider.of<Values>(context, listen: false).setChaiSet(s);
        Provider.of<Values>(context, listen: false).setChaiP("");
      }

      var response = Provider.of<Values>(context, listen: false).jsonResponse({
        "type": 1,
        "method": "cart,chai,cart",
        "s": s,
        "p": p,
        "coupon": Provider.of<Values>(context, listen: false).coupon,
        "city_id": Provider.of<Values>(context, listen: false).cityId,
        "account_id": Provider.of<Values>(context, listen: false).accountId,
        "language_id": Provider.of<Values>(context, listen: false).languageId,
        "session_id": Provider.of<Values>(context, listen: false).sessionId
      });

      response.then((value) {
        value = json.decode(value);

        if (value != null && value != []) {
          if (value['chai'] != null) {
            final String textAdd = LocaleKeys.textAddSum.tr();
            final String chaiFormat = value!["chai_format"];

            if (s > 0) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("$textAdd $chaiFormat"),
              ));
            }

            var totals = <Totals>[];

            for (var i in value!["totals"]) {
              totals.add(Totals.fromJson(i));
            }

            Provider.of<Values>(context, listen: false).setTotals(totals);
            Provider.of<Values>(context, listen: false).setChai(value['chai']);
            Provider.of<Values>(context, listen: false).setChaiP(p);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(LocaleKeys.networkNull.tr()),
          ));
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
                  lang = Provider.of<Values>(context, listen: false).countryCode;

                  if (lang == "") {
                    lang = context.locale.toString().toUpperCase();
                  }

                  if (lang == "UK") {
                    lang = "UA";
                  } else if (lang == "EN") {
                    lang = "US";
                  }

                  FormGroup formCheckout() => fb.group(<String, Object>{
                    'firstname': FormControl<String>(
                      value: snapshot.data!.account?.firstname,
                      validators: [Validators.required],
                    ),
                    'email': FormControl<String>(
                      value: snapshot.data!.account?.email,
                      validators: [Validators.required, Validators.email],
                    ),
                    'date': FormControl<DateTime>(
                      validators: [Validators.required],
                    ),
                    'phone': FormControl<PhoneNumber>(
                      value: PhoneNumber(
                        isoCode: IsoCode.fromJson(lang),
                        nsn: snapshot.data!.account?.telephone??"",
                      ),
                      validators: [Validators.required],
                    ),
                    'shipping_firstname': FormControl<String>(
                      validators: [Validators.required],
                    ),
                    'telz': FormControl<PhoneNumber>(
                      value: PhoneNumber(
                        isoCode: IsoCode.fromJson(snapshot.data!.phoneRegionCode??"RU"),
                        nsn: "",
                      ),
                      validators: [Validators.required],
                    ),
                    'address_1': FormControl<String>(
                      validators: [addressValidate],
                    ),
                    'nezn': FormControl<bool>(),
                    'comment': FormControl<String>(),
                    'text_gift': FormControl<String>(),
                    's': FormControl<double>(),
                  });

                  return Builder(
                      builder: (context) {
                        if (cart.isNotEmpty) {
                          return Stack(
                              children: [
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: HexColor("#C0D0DD"), width: 1),
                                              color: Colors.white,
                                            ),
                                            width: width,
                                            child: Column(
                                              children: [
                                                Column(
                                                  children: List.generate(cart.length, (index) {
                                                    final product = cart[index].product!;
                                                    final sku = product.sku!;
                                                    final String textArt = LocaleKeys.textSku.tr();

                                                    return Stack(
                                                      alignment: AlignmentDirectional.topEnd,
                                                      children: [
                                                        Wrap(
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
                                                                            Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Wrap(
                                                                                  alignment: WrapAlignment.center,
                                                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        if (cart[index].quantity! > 1) {
                                                                                          var qw = cart[index].quantity!;
                                                                                          qw--;

                                                                                          Provider.of<Values>(context, listen: false).cartUpdate(cart[index].cartId!, qw);
                                                                                        } else {
                                                                                          Provider.of<Values>(context, listen: false).cartRemove(cart[index].cartId!, product.vazaId??0, cart[index].productId!);
                                                                                        }
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 30,
                                                                                        height: 30,
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                                                          color: HexColor("#F4FBFF"),
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(3)),
                                                                                        ),
                                                                                        child: Center(
                                                                                          child: SvgPicture.asset(cart[index].quantity! == 1 ? "assets/icons/removeC.svg" : "assets/icons/minus.svg", color: HexColor("#434D56"), semanticsLabel: 'Minus'),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(width: 5),
                                                                                    SizedBox(
                                                                                      width: 30,
                                                                                      child: Text(cart[index].quantity!.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center),
                                                                                    ),
                                                                                    const SizedBox(width: 5),
                                                                                    GestureDetector(
                                                                                      onTap: () {
                                                                                        var qw = cart[index].quantity!;
                                                                                        qw++;

                                                                                        Provider.of<Values>(context, listen: false).cartUpdate(cart[index].cartId!, qw);
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 30,
                                                                                        height: 30,
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                                                          color: HexColor("#F4FBFF"),
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(3)),
                                                                                        ),
                                                                                        child: Center(
                                                                                          child: SvgPicture.asset("assets/icons/plus.svg", semanticsLabel: 'Plus', width: 9, height: 10),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Text(
                                                                                  product.total.toString(),
                                                                                  textAlign: TextAlign.right,
                                                                                ),
                                                                              ],
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
                                                        ),
                                                        Positioned(
                                                          top: 15,
                                                          right: 15,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Provider.of<Values>(context, listen: false).cartRemove(cart[index].cartId!, product.vazaId??0, cart[index].productId!);
                                                            },
                                                            child: Container(
                                                              width: 30,
                                                              height: 30,
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                                color: Colors.white,
                                                                borderRadius: const BorderRadius.all(Radius.circular(3)),
                                                              ),
                                                              child: Center(
                                                                child: SvgPicture.asset("assets/icons/close.svg", semanticsLabel: 'Close', width: 25, height: 25),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                                                  child: Column(
                                                    children: List.generate(totals.length, (index) {
                                                      final String string = totals[index].string!;

                                                      return Column(
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(string.tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                                              Text(totals[index].text!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 20),
                                                        ],
                                                      );
                                                    }),
                                                  ),
                                                ),
                                                if (snapshot.data!.setting!.couponStatus!) Container(
                                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                                  width: double.infinity,
                                                  child: Wrap(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (!couponOpen) {
                                                            Provider.of<Values>(context, listen: false).setCouponOpen(true);
                                                          } else {
                                                            Provider.of<Values>(context, listen: false).setCouponOpen(false);
                                                          }
                                                        },
                                                        child: Wrap(
                                                          alignment: WrapAlignment.spaceBetween,
                                                          crossAxisAlignment: WrapCrossAlignment.center,
                                                          children: [
                                                            Text(
                                                              LocaleKeys.textCoupon.tr(),
                                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                            ),
                                                            const SizedBox(width: 2),
                                                            Transform(
                                                              alignment: Alignment.center,
                                                              transform: Matrix4.rotationZ(
                                                                couponOpen ? 3.1415926535897932 : 0,
                                                              ),
                                                              child: SvgPicture.asset("assets/icons/down.svg", semanticsLabel: 'Arrow down', width: 11, height: 7),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: couponOpen,
                                                        child: ReactiveFormBuilder(
                                                          form: couponForm,
                                                          builder: (context, form, child) {
                                                            return Container(
                                                              padding: const EdgeInsets.only(top: 10),
                                                              width: double.infinity,
                                                              child: Wrap(
                                                                  alignment: WrapAlignment.spaceBetween,
                                                                  crossAxisAlignment: WrapCrossAlignment.start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 120,
                                                                      child: ReactiveTextField(
                                                                        formControlName: 'coupon',
                                                                        decoration: InputDecoration(
                                                                          enabledBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(width: 0.5, color: HexColor("#434D56")),
                                                                          ),
                                                                          labelText: LocaleKeys.enterCoupon.tr(),
                                                                          labelStyle: const TextStyle(fontSize: 12),
                                                                          isDense: true,
                                                                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                                                        ),
                                                                        validationMessages: {
                                                                          'required': (error) => LocaleKeys.couponEmpty.tr()
                                                                        },
                                                                        style: TextStyle(color: HexColor("#434D56"), fontSize: 14),
                                                                      ),
                                                                    ),
                                                                    ReactiveFormConsumer(
                                                                      builder: (context, form, child) {
                                                                        return ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(
                                                                            shape: RoundedRectangleBorder(
                                                                                side: BorderSide(
                                                                                    width: 0.5,
                                                                                    color: HexColor("#FF9186")
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(35)
                                                                            ),
                                                                            backgroundColor: HexColor("#FF9186"),
                                                                            elevation: 0,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                                            minimumSize: const Size(100, 30),
                                                                          ),
                                                                          onPressed: () {
                                                                            form.markAllAsTouched();

                                                                            if (form.valid && !submitLoaded) {
                                                                              Provider.of<Values>(context, listen: false).setSubmitLoaded(true);

                                                                              var response = Provider.of<Values>(context, listen: false).jsonResponse({
                                                                                "type": 2,
                                                                                "method": "coupon",
                                                                                "coupon": form.control("coupon").value,
                                                                                "city_id": Provider.of<Values>(context, listen: false).cityId,
                                                                                "account_id": Provider.of<Values>(context, listen: false).accountId,
                                                                                "language_id": Provider.of<Values>(context, listen: false).languageId,
                                                                                "session_id": Provider.of<Values>(context, listen: false).sessionId
                                                                              });

                                                                              response.then((value) => couponSet(value, context));
                                                                            }
                                                                          },
                                                                          child: submitLoaded ? const SizedBox(
                                                                            height: 25,
                                                                            width: 25,
                                                                            child: CircularProgressIndicator(color: Colors.white),
                                                                          ) : Text(
                                                                            LocaleKeys.save.tr(),
                                                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ]
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (snapshot.data!.setting!.couponStatus!) const SizedBox(height: 15),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ReactiveFormBuilder(
                                              form: formCheckout,
                                              builder: (context, form, child) {
                                                return Column(
                                                  children: [
                                                    Container(
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
                                                                color: HexColor("#F4FBFF"),
                                                              ),
                                                              child: Wrap(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                                    child: Text(
                                                                      LocaleKeys.infZak.tr(),
                                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  const Divider(height: 1),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
                                                              child: Column(
                                                                children: <Widget>[
                                                                  ReactiveTextField(
                                                                      formControlName: 'firstname',
                                                                      decoration: InputDecoration(
                                                                        labelText: LocaleKeys.checkName.tr(),
                                                                        labelStyle: TextStyle(fontSize: 12, color: HexColor("#769bb7")),
                                                                        hintText: LocaleKeys.firstname.tr(),
                                                                        hintStyle: TextStyle(color: HexColor("#769bb7")),
                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                                                        isDense: true,
                                                                        enabledBorder: UnderlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              width: 1,
                                                                              color: HexColor("#ccd6de")
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      keyboardType: TextInputType.name,
                                                                      validationMessages: {
                                                                        'required': (error) => LocaleKeys.errorName.tr()
                                                                      },
                                                                      textInputAction: TextInputAction.next
                                                                  ),
                                                                  const SizedBox(height: 8),
                                                                  ReactivePhoneFormField<PhoneNumber>(
                                                                      formControlName: 'phone',
                                                                      decoration: InputDecoration(
                                                                        labelText: LocaleKeys.textPhone.tr(),
                                                                        labelStyle: TextStyle(fontSize: 13, color: HexColor("#769bb7")),
                                                                        hintText: LocaleKeys.textPhone.tr(),
                                                                        hintStyle: TextStyle(color: HexColor("#769bb7"), fontSize: 12),
                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                                                        isDense: true,
                                                                        enabledBorder: UnderlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              width: 1,
                                                                              color: HexColor("#ccd6de")
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      validationMessages: {
                                                                        'required': (error) => LocaleKeys.errorPhone.tr(),
                                                                      },
                                                                      textInputAction: TextInputAction.next
                                                                  ),
                                                                  const SizedBox(height: 8),
                                                                  ReactiveTextField(
                                                                      formControlName: 'email',
                                                                      decoration: InputDecoration(
                                                                        labelText: LocaleKeys.emailHint.tr(),
                                                                        labelStyle: TextStyle(fontSize: 12, color: HexColor("#769bb7")),
                                                                        hintText: "E-mail",
                                                                        hintStyle: TextStyle(color: HexColor("#769bb7")),
                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                                                        isDense: true,
                                                                        enabledBorder: UnderlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              width: 1,
                                                                              color: HexColor("#ccd6de")
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      keyboardType: TextInputType.emailAddress,
                                                                      validationMessages: {
                                                                        'required': (error) => LocaleKeys.newsletterError1.tr(),
                                                                        'email': (error) => LocaleKeys.newsletterError2.tr()
                                                                      },
                                                                      textInputAction: TextInputAction.next
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Container(
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
                                                                color: HexColor("#F4FBFF"),
                                                              ),
                                                              child: Wrap(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                                    child: Text(
                                                                      LocaleKeys.infShip.tr(),
                                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  const Divider(height: 1),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
                                                              child: Column(
                                                                children: <Widget>[
                                                                  Stack(
                                                                    alignment: Alignment.centerRight,
                                                                    children: [
                                                                      ReactiveTextField(
                                                                          formControlName: 'date',
                                                                          onTap: (e) {
                                                                            Provider.of<Values>(context, listen: false).setPopupVisible(true);

                                                                            showCupertinoModalPopup(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return DatePopup(form: form);
                                                                                }
                                                                            );
                                                                          },
                                                                          decoration: InputDecoration(
                                                                              labelText: LocaleKeys.checkDate.tr(),
                                                                              labelStyle: TextStyle(fontSize: 12, color: HexColor("#769bb7")),
                                                                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                                                              isDense: true,
                                                                              border: InputBorder.none
                                                                          ),
                                                                          readOnly: true,
                                                                          keyboardType: TextInputType.name,
                                                                          validationMessages: {
                                                                            'required': (error) => LocaleKeys.errorDate.tr()
                                                                          },
                                                                          textInputAction: TextInputAction.next
                                                                      ),
                                                                      GestureDetector(
                                                                          onTap: () {
                                                                            Provider.of<Values>(context, listen: false).setPopupVisible(true);

                                                                            showCupertinoModalPopup(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return DatePopup(form: form);
                                                                                }
                                                                            );
                                                                          },
                                                                          child: ColoredBox(color: Colors.white, child: SvgPicture.asset("assets/icons/date.svg", semanticsLabel: 'Date', width: 32, height: 29))
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Container(
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
                                                                color: HexColor("#F4FBFF"),
                                                              ),
                                                              child: Wrap(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                                    child: Text(
                                                                      LocaleKeys.ingChl.tr(),
                                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  const Divider(height: 1),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
                                                              child: Column(
                                                                children: <Widget>[
                                                                  ReactiveTextField(
                                                                      formControlName: 'shipping_firstname',
                                                                      decoration: InputDecoration(
                                                                        labelText: LocaleKeys.checkChl.tr(),
                                                                        labelStyle: TextStyle(fontSize: 12, color: HexColor("#769bb7")),
                                                                        hintText: LocaleKeys.firstname.tr(),
                                                                        hintStyle: TextStyle(color: HexColor("#769bb7")),
                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                                                        isDense: true,
                                                                        enabledBorder: UnderlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              width: 1,
                                                                              color: HexColor("#ccd6de")
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      keyboardType: TextInputType.name,
                                                                      validationMessages: {
                                                                        'required': (error) => LocaleKeys.errorName.tr()
                                                                      },
                                                                      textInputAction: TextInputAction.next
                                                                  ),
                                                                  const SizedBox(height: 8),
                                                                  ReactivePhoneFormField<PhoneNumber>(
                                                                      formControlName: 'telz',
                                                                      decoration: InputDecoration(
                                                                        labelText: LocaleKeys.checkPhoneChl.tr(),
                                                                        labelStyle: TextStyle(fontSize: 13, color: HexColor("#769bb7")),
                                                                        hintText: LocaleKeys.textPhone.tr(),
                                                                        hintStyle: TextStyle(color: HexColor("#769bb7"), fontSize: 12),
                                                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                                                        isDense: true,
                                                                        enabledBorder: UnderlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              width: 1,
                                                                              color: HexColor("#ccd6de")
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      validationMessages: {
                                                                        'required': (error) => LocaleKeys.errorPhone.tr(),
                                                                      },
                                                                      onChanged: (e) {
                                                                        var val = e.value;
                                                                        var tel = val!.countryCode + val.nsn;

                                                                        Provider.of<Values>(context, listen: false).setCheckoutTel("+$tel");
                                                                      },
                                                                      textInputAction: TextInputAction.next
                                                                  ),
                                                                  const SizedBox(height: 8),
                                                                  Visibility(
                                                                    visible: !notAdr,
                                                                    child: ReactiveTextField(
                                                                        formControlName: 'address_1',
                                                                        decoration: InputDecoration(
                                                                          labelText: LocaleKeys.checkAddressChl.tr(),
                                                                          labelStyle: TextStyle(fontSize: 12, color: HexColor("#769bb7")),
                                                                          hintText: LocaleKeys.checkAddressChl.tr(),
                                                                          hintStyle: TextStyle(color: HexColor("#769bb7")),
                                                                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                                                          isDense: true,
                                                                          enabledBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                width: 1,
                                                                                color: HexColor("#ccd6de")
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        keyboardType: TextInputType.streetAddress,
                                                                        validationMessages: {
                                                                          'addressValidate': (error) => LocaleKeys.addressEmpty.tr(),
                                                                        },
                                                                        textInputAction: TextInputAction.next
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 8),
                                                                  SizedBox(
                                                                    width: double.infinity,
                                                                    child: Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          flex: 5,
                                                                          child: Text(
                                                                            LocaleKeys.notAddress.tr(),
                                                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex: 1,
                                                                          child: CupertinoSwitch(
                                                                            value: notAdr,
                                                                            onChanged: (value) {
                                                                              if (!notAdr) {
                                                                                Provider.of<Values>(context, listen: false).setNotAdr(true);
                                                                              } else {
                                                                                Provider.of<Values>(context, listen: false).setNotAdr(false);
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Container(
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
                                                                color: HexColor("#F4FBFF"),
                                                              ),
                                                              child: Wrap(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Expanded(
                                                                          flex: 3,
                                                                          child: Text(
                                                                            LocaleKeys.infCur.tr(),
                                                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex: 2,
                                                                          child: Text(
                                                                            commentTextTree,
                                                                            style: const TextStyle(fontSize: 10.5, height: 1.6),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Divider(height: 1),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                                                              child: Stack(
                                                                children: [
                                                                  Wrap(
                                                                    children: const [
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                    ],
                                                                  ),
                                                                  ReactiveTextField(
                                                                    formControlName: 'comment',
                                                                    decoration: const InputDecoration(
                                                                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                                                                        isDense: true,
                                                                        border: InputBorder.none
                                                                    ),
                                                                    style: const TextStyle(height: 1.535),
                                                                    maxLines: 4,
                                                                    keyboardType: TextInputType.text,
                                                                    textInputAction: TextInputAction.next,
                                                                    onChanged: (e) {
                                                                      final String textComment = form.control("comment").value;
                                                                      final textCommentLength = textComment.length;

                                                                      Provider.of<Values>(context, listen: false).setCommentTree(300 - textCommentLength);

                                                                      if (textCommentLength >= 300) {
                                                                        form.control("comment").value = textComment.substring(0, 299);

                                                                        FocusScopeNode currentFocus = FocusScope.of(context);

                                                                        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Container(
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
                                                                color: HexColor("#F4FBFF"),
                                                              ),
                                                              child: Wrap(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Expanded(
                                                                          flex: 3,
                                                                          child: Text(
                                                                            LocaleKeys.addGift.tr(),
                                                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex: 2,
                                                                          child: Text(
                                                                            giftTextTree,
                                                                            style: const TextStyle(fontSize: 10.5, height: 1.6),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const Divider(height: 1),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                                                              child: Stack(
                                                                children: [
                                                                  Wrap(
                                                                    children: const [
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                      Divider(),
                                                                      SizedBox(height: 25),
                                                                    ],
                                                                  ),
                                                                  ReactiveTextField(
                                                                    formControlName: 'text_gift',
                                                                    decoration: const InputDecoration(
                                                                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                                                                        isDense: true,
                                                                        border: InputBorder.none
                                                                    ),
                                                                    style: const TextStyle(height: 1.535),
                                                                    maxLines: 4,
                                                                    keyboardType: TextInputType.text,
                                                                    textInputAction: TextInputAction.next,
                                                                    onChanged: (e) {
                                                                      final String textGift = form.control("text_gift").value;
                                                                      final x = textGift.length;

                                                                      Provider.of<Values>(context, listen: false).setGiftTree(300 - x);

                                                                      if (x >= 300) {
                                                                        form.control("text_gift").value = textGift.substring(0, 299);

                                                                        FocusScopeNode currentFocus = FocusScope.of(context);

                                                                        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Container(
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
                                                                color: HexColor("#F4FBFF"),
                                                              ),
                                                              child: Wrap(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                                    child: Text(
                                                                      LocaleKeys.chaiFlor.tr(),
                                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  const Divider(height: 1),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: width,
                                                                    child: Wrap(
                                                                      runAlignment: WrapAlignment.center,
                                                                      alignment: WrapAlignment.spaceBetween,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap: () {
                                                                            setChai(0, "p");
                                                                          },
                                                                          child: Container(
                                                                            width: 60,
                                                                            height: 40,
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(color: HexColor(chaiSet == 0 ? "#FF9186" : "#C0D0DD"), width: 0.5),
                                                                              color: HexColor(chaiSet == 0 ? "#FF9186" : "#F4FBFF"),
                                                                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                                            ),
                                                                            child: Center(
                                                                              child: Text("0%", style: TextStyle(color: HexColor(chaiSet == 0 ? "#ffffff" : "#434D56"))),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap: () {
                                                                            setChai(5, "p");
                                                                          },
                                                                          child: Container(
                                                                            width: 60,
                                                                            height: 40,
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(color: HexColor(chaiSet == 5 ? "#FF9186" : "#C0D0DD"), width: 0.5),
                                                                              color: HexColor(chaiSet == 5 ? "#FF9186" : "#F4FBFF"),
                                                                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                                            ),
                                                                            child: Center(
                                                                              child: Text("5%", style: TextStyle(color: HexColor(chaiSet == 5 ? "#ffffff" : "#434D56"))),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap: () {
                                                                            setChai(10, "p");
                                                                          },
                                                                          child: Container(
                                                                            width: 60,
                                                                            height: 40,
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(color: HexColor(chaiSet == 10 ? "#FF9186" : "#C0D0DD"), width: 0.5),
                                                                              color: HexColor(chaiSet == 10 ? "#FF9186" : "#F4FBFF"),
                                                                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                                            ),
                                                                            child: Center(
                                                                              child: Text("10%", style: TextStyle(color: HexColor(chaiSet == 10 ? "#ffffff" : "#434D56"))),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap: () {
                                                                            setChai(15, "p");
                                                                          },
                                                                          child: Container(
                                                                            width: 60,
                                                                            height: 40,
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(color: HexColor(chaiSet == 15 ? "#FF9186" : "#C0D0DD"), width: 0.5),
                                                                              color: HexColor(chaiSet == 15 ? "#FF9186" : "#F4FBFF"),
                                                                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                                            ),
                                                                            child: Center(
                                                                              child: Text("15%", style: TextStyle(color: HexColor(chaiSet == 15 ? "#ffffff" : "#434D56"))),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    if (snapshot.data!.information != null) SizedBox(
                                                      width: width,
                                                      child: Wrap(
                                                        alignment: WrapAlignment.start,
                                                        crossAxisAlignment: WrapCrossAlignment.center,
                                                        children: [
                                                          CupertinoSwitch(
                                                            value: agree,
                                                            onChanged: (value) {
                                                              if (!agree) {
                                                                Provider.of<Values>(context, listen: false).setAgree(true);
                                                              } else {
                                                                Provider.of<Values>(context, listen: false).setAgree(false);
                                                              }
                                                            },
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.only(left: 8),
                                                            width: width-105,
                                                            child: RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    style: TextStyle(fontSize: 12, color: HexColor("#434D56")),
                                                                    text: LocaleKeys.continueCheck.tr(),
                                                                  ),
                                                                  const TextSpan(style: TextStyle(fontSize: 12, color: Colors.transparent), text: " "),
                                                                  TextSpan(
                                                                    style: TextStyle(fontSize: 12, color: HexColor("#FF7061")),
                                                                    text: LocaleKeys.continueCheck2.tr(),
                                                                    recognizer: TapGestureRecognizer()
                                                                      ..onTap = () => showCupertinoModalPopup(context: context, builder: (BuildContext context) {
                                                                        return Scaffold(
                                                                          appBar: AppBar(
                                                                            automaticallyImplyLeading: false,
                                                                            titleSpacing: 15.0,
                                                                            elevation: 0,
                                                                            backgroundColor: HexColor("#55667E").withOpacity(0.69),
                                                                            title: Align(
                                                                              alignment: Alignment.centerRight,
                                                                              child: Material(
                                                                                child: IconButton(
                                                                                    padding: EdgeInsets.zero,
                                                                                    constraints: const BoxConstraints(),
                                                                                    icon: SvgPicture.asset("assets/icons/close.svg", semanticsLabel: 'Close', width: 30, height: 30),
                                                                                    iconSize: 30,
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop();
                                                                                    }
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          body: Column(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Container(
                                                                                    width: width,
                                                                                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                                                                                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
                                                                                    child: SingleChildScrollView(
                                                                                      child: Padding(
                                                                                          padding: const EdgeInsets.all(15),
                                                                                          child: Html(
                                                                                            data: snapshot.data!.information![0].description,
                                                                                            style: {
                                                                                              "body": Style(
                                                                                                  fontSize: const FontSize(14.0),
                                                                                                  margin: EdgeInsets.zero,
                                                                                                  color: Colors.black
                                                                                              ),
                                                                                              "h2": Style(
                                                                                                  fontSize: const FontSize(14.0),
                                                                                                  margin: const EdgeInsets.only(bottom: 6),
                                                                                                  color: Colors.black
                                                                                              ),
                                                                                            },
                                                                                          )
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ]
                                                                          ),
                                                                        );
                                                                      }),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (snapshot.data!.information != null) const SizedBox(height: 20),
                                                      ReactiveFormConsumer(
                                                      builder: (context, form, child) {
                                                        return ElevatedButton(
                                                          onPressed: () {
                                                            if (!form.valid) {
                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                content: Text(LocaleKeys.errorWarning.tr()),
                                                              ));

                                                              form.markAllAsTouched();
                                                            }

                                                            if (!agree) {
                                                              Provider.of<Values>(context, listen: false).setSubmitLoaded(false);

                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                content: Text(LocaleKeys.errorWarning2.tr()),
                                                              ));
                                                            }

                                                            if (!submitLoaded && form.valid && agree) {
                                                              Provider.of<Values>(context, listen: false).setSubmitLoaded(true);
                                                              var code = form.control('phone').value.countryCode;
                                                              var nsn = form.control('phone').value.nsn;
                                                              final String phone = "+$code$nsn";
                                                              if (selectTime == "") Provider.of<Values>(context, listen: false).setSelectTime(time[0].time!);

                                                              var response = Provider.of<Values>(context, listen: false).jsonResponse({
                                                                "type": 2,
                                                                "method": "checkout",
                                                                "language_id": Provider.of<Values>(context, listen: false).languageId,
                                                                "currency": Provider.of<Values>(context, listen: false).currencyCode,
                                                                "account_id": Provider.of<Values>(context, listen: false).accountId,
                                                                "city_id": Provider.of<Values>(context, listen: false).cityId,
                                                                "session_id": Provider.of<Values>(context, listen: false).sessionId,
                                                                "address": form.control("nezn").isNotNull ? LocaleKeys.notAddress.tr() : form.control("address_1").value,
                                                                "total_sub_total": "totalSubTotal".tr(),
                                                                "total_total": "totalTotal".tr(),
                                                                "total_reward": "totalReward".tr(),
                                                                "total_coupon": "totalCoupon".tr(),
                                                                "total_chai": "totalChai".tr(),
                                                                "textGift": form.control("text_gift").value,
                                                                "comment": form.control("text_gift").value,
                                                                "firstname": form.control("firstname").value,
                                                                "shipping_firstname": form.control("shipping_firstname").value,
                                                                "email": form.control("email").value,
                                                                "nezn": notAdr?1:0,
                                                                "phone": phone,
                                                                'ios': Platform.isIOS?1:0,
                                                                "telz": checkoutTel,
                                                                "date": DateFormat('d/MM/yyyy').format(form.control("date").value),
                                                                "time": selectTime,
                                                                "s": chai,
                                                                "p": chaiP
                                                              });

                                                              response.then((value) {
                                                                if (value != null) {
                                                                  value = json.decode(value);

                                                                  if (value["error"] != null) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                      content: Text(LocaleKeys.errorWarning.tr()),
                                                                    ));
                                                                  } else {
                                                                    Provider.of<Values>(context, listen: false).setSubmitLoaded(false);

                                                                    FocusScopeNode currentFocus = FocusScope.of(context);

                                                                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                                    }

                                                                    if (value!.isNotEmpty) {
                                                                      if (value['order_id'] != null) {
                                                                        Provider.of<Values>(context, listen: false).deleteIndexHistory();
                                                                        Provider.of<Values>(context, listen: false).setChai(0.0);
                                                                        Provider.of<Values>(context, listen: false).setChaiP("");
                                                                        Provider.of<Values>(context, listen: false).setOrderId(value['order_id']!);
                                                                        Provider.of<Values>(context, listen: false).setData("payment");
                                                                        Navigator.pushNamed(context, "payment");
                                                                      } else {
                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                          content: Text(LocaleKeys.errorWarning.tr()),
                                                                        ));
                                                                      }
                                                                    } else {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        content: Text(LocaleKeys.networkNull.tr()),
                                                                      ));
                                                                    }
                                                                  }
                                                                } else {
                                                                  Provider.of<Values>(context, listen: false).setSubmitLoaded(false);

                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                    content: Text(LocaleKeys.networkNull.tr()),
                                                                  ));
                                                                }
                                                              });
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
                                                          ) : Text(LocaleKeys.textTotal.tr().toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(height: 40),
                                                  ],
                                                );
                                              }
                                          ),
                                        ]
                                    ),
                                  ),
                                ),
                                const Search(),
                              ]
                          );
                        } else {
                          return SizedBox(
                            width: width,
                            height: double.infinity,
                            child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(LocaleKeys.textCartEmpty.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 20),
                                    Image.asset("assets/icons/fav.png", width: 60, height: 60),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        Provider.of<Values>(context, listen: false).setData("/");
                                        Navigator.pushNamed(context, "/");
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
                                      child: Text(LocaleKeys.buttonContinue.tr(), style: TextStyle(fontSize: 16, color: HexColor("#434D56"))),
                                    ),
                                  ],
                                )
                            ),
                          );
                        }
                      }
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