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
import '../screen/order.dart';
import '../screen/item_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:convert';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';

class Account extends StatelessWidget {
  const Account({super.key, required this.title});

  final String title;

  void responseSave(value, context) {
    value = json.decode(value);

    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    if (value != null && value != []) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value['error'] == null ? LocaleKeys.saveSuccess.tr() : LocaleKeys.networkNull.tr()),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleKeys.networkNull.tr()),
      ));
    }
  }

  void save(form, context) {
    if (!form.valid) {
      form.markAllAsTouched();
    } else {
      var response = Provider.of<Values>(context, listen: false).jsonResponse({
        "type": 2,
        "method": "saveAccount",
        "city_id": Provider.of<Values>(context, listen: false).cityId,
        "language_id": Provider.of<Values>(context, listen: false).languageId,
        "session_id": Provider.of<Values>(context, listen: false).sessionId,
        "account_id": Provider.of<Values>(context, listen: false).accountId,
        "currency": Provider.of<Values>(context, listen: false).currencyCode,
        "coupon": Provider.of<Values>(context, listen: false).coupon,
        "wishlist": Provider.of<Values>(context, listen: false).wishlist.join(","),
        "firstname": form.control('name').value,
        "email": form.control('email').value,
        "phone": form.control('phone').value.nsn.toString()
      });

      response.then((value) => responseSave(value, context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = Provider.of<Values>(context, listen: false).isLoading;
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final List<int>? wishlist = Provider.of<Values>(context).wishlist;
    var account = Provider.of<Values>(context, listen: false).account;
    var width = MediaQuery.of(context).size.width;

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
                FormGroup form() => fb.group(<String, Object>{
                  'name': FormControl<String>(
                    value: account!.firstname!,
                    validators: [Validators.required],
                  ),
                  'email': FormControl<String>(
                    value: account.email!,
                    validators: [Validators.required, Validators.email],
                  ),
                  'phone': FormControl<PhoneNumber>(
                    value: PhoneNumber(
                      isoCode: IsoCode.fromJson(snapshot.data!.phoneRegionCode!),
                      nsn: account.telephone!,
                    ),
                    validators: [Validators.required],
                  ),
                });

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
                                                  LocaleKeys.accountMyData.tr(),
                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              const Divider(height: 1),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
                                          child: ReactiveFormBuilder(
                                            form: form,
                                            builder: (context, form, child) {
                                              return Column(
                                                children: <Widget>[
                                                  ReactiveTextField(
                                                    formControlName: 'name',
                                                    decoration: InputDecoration(
                                                      labelText: LocaleKeys.firstname.tr(),
                                                      labelStyle: const TextStyle(fontSize: 14),
                                                      contentPadding: EdgeInsets.zero,
                                                    ),
                                                    keyboardType: TextInputType.name,
                                                    validationMessages: {
                                                      'required': (error) => LocaleKeys.errorName.tr()
                                                    },
                                                    onSubmitted: (formControl) => save(form, context),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ReactiveTextField(
                                                    formControlName: 'email',
                                                    decoration: InputDecoration(
                                                      labelText: LocaleKeys.emailHint.tr(),
                                                      labelStyle: const TextStyle(fontSize: 14),
                                                      contentPadding: EdgeInsets.zero,
                                                    ),
                                                    keyboardType: TextInputType.emailAddress,
                                                    validationMessages: {
                                                      'required': (error) => LocaleKeys.newsletterError1.tr(),
                                                      'email': (error) => LocaleKeys.newsletterError2.tr()
                                                    },
                                                    onSubmitted: (formControl) => save(form, context),
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
                                                    onSubmitted: () {
                                                      save(form, context);
                                                    },
                                                  ),
                                                  const SizedBox(height: 15),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: Wrap(
                                                      alignment: WrapAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          LocaleKeys.accountTextReward.tr(),
                                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                                        ),
                                                        Text(
                                                          account!.reward.toString(),
                                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
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
                                                  LocaleKeys.accountMyOrders.tr(),
                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              const Divider(height: 1),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
                                          child: account != null ? Builder(
                                              builder: (context) {
                                                var orders = account.orders!;

                                                if (account.orders!.isNotEmpty) {
                                                  return Column(
                                                    children: List<Widget>.generate(orders.length, (int index) {
                                                      var order = orders[index];
                                                      final orderId = order.oid;

                                                      return Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: Flex(
                                                                direction: Axis.horizontal,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text("$orderId", style: const TextStyle(fontSize: 12)),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(order.date!, style: const TextStyle(fontSize: 12)),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(order.total!, style: const TextStyle(fontSize: 12)),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(order.status!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1)),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: TextButton(
                                                                      onPressed: () {
                                                                        showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.transparent, builder: (BuildContext context) {
                                                                          return OrderPopup(title: "№$orderId", order: order);
                                                                        });
                                                                      },
                                                                      style: TextButton.styleFrom(
                                                                        padding: const EdgeInsets.all(0),
                                                                        alignment: Alignment.centerRight,
                                                                      ),
                                                                      child: Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
                                                                        decoration: BoxDecoration(
                                                                            border: Border.all(color: HexColor("#C0D0DD"), width: 0.5),
                                                                            color: HexColor("#F4FBFF"),
                                                                            borderRadius: const BorderRadius.all(Radius.circular(5))
                                                                        ),
                                                                        child: SvgPicture.asset("assets/icons/arrow.svg", semanticsLabel: 'Arrow', width: 15, height: 9),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            CarouselSlider(
                                                              options: CarouselOptions(
                                                                height: 60,
                                                                padEnds: false,
                                                                enableInfiniteScroll: false,
                                                                viewportFraction: 0.22,
                                                                disableCenter: true,
                                                                autoPlay: true,
                                                                autoPlayInterval: const Duration(seconds: 3),
                                                                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                                                autoPlayCurve: Curves.fastOutSlowIn,
                                                                scrollDirection: Axis.horizontal,
                                                              ),
                                                              items: order.products!.map((i) {
                                                                return Builder(
                                                                  builder: (BuildContext context) {
                                                                    return GestureDetector(
                                                                      onTap: () {
                                                                        Provider.of<Values>(context, listen: false).setProductId(i.productId!);
                                                                        Provider.of<Values>(context, listen: false).setData("product");
                                                                        Navigator.pushNamed(context, "product");
                                                                      },
                                                                      child: Container(
                                                                        margin: const EdgeInsets.only(right: 10),
                                                                        child: ClipRRect(
                                                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                          child: FadeInImage.memoryNetwork(
                                                                            placeholder: kTransparentImage,
                                                                            image: i.image!,
                                                                            width: 50,
                                                                            height: 50,
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              }).toList(),
                                                            ),
                                                            if (orders.length-1 > index) const SizedBox(height: 10),
                                                            if (orders.length-1 > index) const Divider(),
                                                          ]
                                                      );
                                                    }),
                                                  );
                                                } else {
                                                  return const EmptyBox();
                                                }
                                              }
                                          ) : Text(LocaleKeys.ordersEmpty.tr()),
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
                                                  LocaleKeys.accountTextWishlist.tr(),
                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                              const Divider(height: 1),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: wishlist!.isNotEmpty && account?.wishlist != null && account!.wishlist!.isNotEmpty ? Builder(
                                              builder: (context) {
                                                var wishlists = account.wishlist!;

                                                return Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  alignment: WrapAlignment.spaceBetween,
                                                  children: List.generate(wishlists.length, (index) {
                                                    if (wishlist.contains(wishlists[index].productId)) {
                                                      return ItemProduct(product: wishlists[index]);
                                                    } else {
                                                      return const SizedBox.shrink();
                                                    }
                                                  }),
                                                );
                                              }
                                          ) : Text(LocaleKeys.accountTextWishlistEmpty.tr()),
                                        ),
                                      ]
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(context: context, builder: (BuildContext context) {
                                      return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Scaffold(
                                            backgroundColor: Colors.transparent,
                                            body: Align(
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () {

                                                },
                                                child: SizedBox(
                                                  width: width - 30,
                                                  height: 170,
                                                  child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 27),
                                                          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(2.0))),
                                                          child: SingleChildScrollView(
                                                            child: Wrap(
                                                              runSpacing: 20,
                                                              children: [
                                                                Text(LocaleKeys.textLogoutAlert.tr(), style: TextStyle(fontSize: 16, color: HexColor("#434D56"))),
                                                                const SizedBox(height: 44),
                                                                Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        onPressed: () async {
                                                                          Provider.of<Values>(context, listen: false).setAccountId(0);
                                                                          Provider.of<Values>(context, listen: false).setData("/");
                                                                          Navigator.pushNamed(context, "/");
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
                                                                            minimumSize: Size((width/2)-50, 40),
                                                                            padding: const EdgeInsets.symmetric(vertical: 15)
                                                                        ),
                                                                        child: Text(LocaleKeys.yesLogout.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56"))),
                                                                      ),
                                                                      ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
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
                                                                            minimumSize: Size((width/2)-50, 40),
                                                                            padding: const EdgeInsets.symmetric(vertical: 15)
                                                                        ),
                                                                        child: Text(LocaleKeys.textBack.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56"))),
                                                                      ),
                                                                    ]
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 9, right: 9),
                                                              child: SvgPicture.asset("assets/icons/close2.svg", semanticsLabel: 'Logout', width: 19, height: 19),
                                                            ),
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                      );
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset("assets/icons/logout.svg", semanticsLabel: 'Logout', width: 15, height: 15),
                                      const SizedBox(width: 13),
                                      Text(
                                        LocaleKeys.textLogout.tr(),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(context: context, builder: (BuildContext context) {
                                      return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Scaffold(
                                            backgroundColor: Colors.transparent,
                                            body: Align(
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () {

                                                },
                                                child: SizedBox(
                                                  width: width - 30,
                                                  height: 165,
                                                  child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 27),
                                                          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(2.0))),
                                                          child: SingleChildScrollView(
                                                            child: Wrap(
                                                              runSpacing: 24,
                                                              children: [
                                                                Text(LocaleKeys.textDeleteAlert.tr(), style: TextStyle(fontSize: 16, color: HexColor("#434D56"))),
                                                                Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        onPressed: () async {
                                                                          var response = Provider.of<Values>(context, listen: false).jsonResponse({
                                                                            "type": 1,
                                                                            "method": "deleteAccount",
                                                                            "account_id": Provider.of<Values>(context, listen: false).accountId
                                                                          });

                                                                          response.then((value) {
                                                                            Provider.of<Values>(context, listen: false).setAccountId(0);
                                                                            Provider.of<Values>(context, listen: false).setData("/");
                                                                            Navigator.pushNamed(context, "/");
                                                                          });
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
                                                                            minimumSize: Size((width/2)-50, 40),
                                                                            padding: const EdgeInsets.symmetric(vertical: 15)
                                                                        ),
                                                                        child: Text(LocaleKeys.yesDelete.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56"))),
                                                                      ),
                                                                      ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
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
                                                                            minimumSize: Size((width/2)-50, 40),
                                                                            padding: const EdgeInsets.symmetric(vertical: 15)
                                                                        ),
                                                                        child: Text(LocaleKeys.textBack.tr(), style: TextStyle(fontSize: 14, color: HexColor("#434D56"))),
                                                                      ),
                                                                    ]
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 9, right: 9),
                                                              child: SvgPicture.asset("assets/icons/close2.svg", semanticsLabel: 'Logout', width: 19, height: 19),
                                                            ),
                                                          ),
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                      );
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset("assets/icons/del.svg", semanticsLabel: 'Logout', width: 15, height: 16),
                                      const SizedBox(width: 13),
                                      Text(
                                        LocaleKeys.deleteAccount.tr()
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ]
                          ),
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