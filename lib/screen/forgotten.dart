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
import 'package:reactive_forms/reactive_forms.dart';
import 'dart:convert';

class Forgotten extends StatelessWidget {
  const Forgotten({super.key, required this.title});

  final String title;

  FormGroup form() => fb.group(<String, Object>{
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final bool isLoading = Provider.of<Values>(context, listen: false).isLoading;
    final Future<Data>? api = Provider.of<Values>(context, listen: false).api;
    final bool submitLoaded = Provider.of<Values>(context).submitLoaded;
    final String currentRoute = Provider.of<Values>(context, listen: false).currentRoute;

    void responseApi(value, context, currentRoute) {
      value = json.decode(value);
      Provider.of<Values>(context, listen: false).setSubmitLoaded(false);

      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }

      Provider.of<Values>(context, listen: false).setSubmitLoaded(false);

      if (value != null && value != []) {
        showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: Text(
                  (value['error'] != null ?
                  LocaleKeys.noCustomer.tr() :
                  LocaleKeys.forgottenSuccess.tr()),
                  style: const TextStyle(fontSize: 16),
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            }
        );
      }
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
                return Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(LocaleKeys.forgottenText.tr(), textAlign: TextAlign.center),
                                const SizedBox(height: 20),
                                ReactiveFormBuilder(
                                  form: form,
                                  builder: (context, form, child) {
                                    return Column(
                                      children: <Widget>[
                                        ReactiveTextField(
                                          formControlName: 'email',
                                          decoration: InputDecoration(
                                            labelText: LocaleKeys.emailHint.tr(),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          keyboardType: TextInputType.emailAddress,
                                          validationMessages: {
                                            'required': (error) => LocaleKeys.newsletterError1.tr(),
                                            'email': (error) => LocaleKeys.newsletterError2.tr()
                                          },
                                        ),
                                        const SizedBox(height: 80),
                                        ReactiveFormConsumer(
                                          builder: (context, form, child) {
                                            return ElevatedButton(
                                              onPressed: () {
                                                if (!form.valid) {
                                                  form.markAllAsTouched();
                                                }

                                                if (!submitLoaded && form.valid) {
                                                  Provider.of<Values>(context, listen: false).setSubmitLoaded(true);

                                                  var response = Provider.of<Values>(context, listen: false).jsonResponse({
                                                    "type": 2,
                                                    "method": "resetPassword",
                                                    "city_id": Provider.of<Values>(context, listen: false).cityId,
                                                    "language_id": Provider.of<Values>(context, listen: false).languageId,
                                                    "session_id": Provider.of<Values>(context, listen: false).sessionId,
                                                    "currency": Provider.of<Values>(context, listen: false).currencyCode,
                                                    "wishlist": Provider.of<Values>(context, listen: false).wishlist.join(","),
                                                    "email": form.control('email').value
                                                  });

                                                  response.then((value) => responseApi(value, context, currentRoute));
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
                                              ) : Text(LocaleKeys.textSend.tr().toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
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