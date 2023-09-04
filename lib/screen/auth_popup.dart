import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import '../values.dart';
import '../screen/header.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:reactive_forms/reactive_forms.dart';

GoogleSignInAccount? googleUser;
Map<String, dynamic>? _userData;
var passText = "";

class AuthPopup extends StatelessWidget {
  const AuthPopup({super.key});

  logIn(context, currentRoute) async {
    final AuthorizationResult result = await TheAppleSignIn.performRequests([
      const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:
        if (result.credential?.email != null) {
          var firstname = result.credential?.fullName?.givenName;
          var lastname = result.credential?.fullName?.familyName;
          var email = result.credential?.email;
          Provider.of<Values>(context, listen: false).setAppleUser(result.credential?.user!, firstname!, lastname!, email!);

          var response = Provider.of<Values>(context, listen: false).jsonResponse({
            "type": 1,
            "method": "register",
            "email": email,
            "language_id": Provider.of<Values>(context, listen: false).languageId,
            "name": firstname,
            "lastname": lastname,
            "service": "IOS",
            "password": "fhJ91Hdir8"
          });

          response.then((value) => register(value, context, currentRoute, false));
        } else if (result.credential?.user != null) {
          var apple = Provider.of<Values>(context, listen: false).getAppleUser();

          if (apple != null && apple["id"] == result.credential?.user) {
            var response = Provider.of<Values>(context, listen: false).jsonResponse({
              "type": 1,
              "method": "register",
              "email": apple["email"],
              "language_id": Provider.of<Values>(context, listen: false).languageId,
              "name": apple["name"],
              "lastname": apple["lastname"],
              "service": "IOS",
              "password": "fhJ91Hdir8"
            });

            response.then((value) => register(value, context, currentRoute, false));
          }
        } else {
          showCupertinoDialog(
              context: context,
              builder: (ctx) {
                return CupertinoAlertDialog(
                  title: Text(LocaleKeys.errorAuthEmail.tr()),
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

        break;

      case AuthorizationStatus.error:

        break;

      case AuthorizationStatus.cancelled:

        break;
    }
  }

  Future<void> login(context, currentRoute) async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      _userData = userData;

      if (_userData != null) {
        var name = _userData!['name'];
        var firstname = name;
        var lastname = '';

        final fullName = _userData!['name']!.split(' ');

        if (fullName[1] != "") {
          firstname = fullName[0];
          lastname = fullName[1];
        }

        var response = Provider.of<Values>(context, listen: false).jsonResponse({
          "type": 1,
          "method": "register",
          "email": _userData!['email'],
          "language_id": Provider.of<Values>(context, listen: false).languageId,
          "name": firstname,
          "lastname": lastname,
          "service": Platform.isAndroid ? "Android" : "IOS",
          "password": "fhJ91Hdir8"
        });

        response.then((value) => register(value, context, currentRoute, false));
      }
    } else {
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text(LocaleKeys.errorAuth.tr()),
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

  Future<void> _signInGoogle(context, currentRoute) async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );

      googleUser = await googleSignIn.signInSilently() ?? await googleSignIn.signIn();

      if (googleUser != null) {
        var name = googleUser!.displayName;
        var firstname = name;
        var lastname = '';

        final fullName = name!.split(' ');

        if (fullName[1] != "") {
          firstname = fullName[0];
          lastname = fullName[1];
        }

        var response = Provider.of<Values>(context, listen: false).jsonResponse({
          "type": 1,
          "method": "register",
          "email": googleUser!.email,
          "language_id": Provider.of<Values>(context, listen: false).languageId,
          "name": firstname,
          "lastname": lastname,
          "service": Platform.isAndroid ? "Android" : "IOS",
          "password": "fhJ91Hdir8"
        });

        response.then((value) => register(value, context, currentRoute, false));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void logins(response, context, currentRoute) {
    response = json.decode(response);

    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    Provider.of<Values>(context, listen: false).setFieldIsLoading(false);
    Provider.of<Values>(context, listen: false).setFieldRegisterIsLoading(false);

    if (response['login']['customer_id'] != 0) {
      Provider.of<Values>(context, listen: false).resetHistory();
      Provider.of<Values>(context, listen: false).setAccountId(response['login']['customer_id']);
      Provider.of<Values>(context, listen: false).setData("account");
      Navigator.pushNamed(context, "account");
    } else {
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text(
                (response['login']['customer_id'] == 0 && response['login']['email'] == 1 ?
                LocaleKeys.passwordError.tr() :
                LocaleKeys.noCustomer.tr()),
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

  void register(response, context, currentRoute, register) {
    response = json.decode(response);

    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    Provider.of<Values>(context, listen: false).setFieldIsLoading(false);
    Provider.of<Values>(context, listen: false).setFieldRegisterIsLoading(false);

    if (register) {
      if (response['login']['email'] != 0) {
        showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: Text(
                  LocaleKeys.countCustomer.tr(),
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
      } else {
        Provider.of<Values>(context, listen: false).resetHistory();
        Provider.of<Values>(context, listen: false).setAccountId(response['login']['customer_id']);
        Provider.of<Values>(context, listen: false).setData("account");
        Navigator.pushNamed(context, "account");
      }
    } else {
      Provider.of<Values>(context, listen: false).resetHistory();
      Provider.of<Values>(context, listen: false).setAccountId(response['login']['customer_id']);
      Provider.of<Values>(context, listen: false).setData("account");
      Navigator.pushNamed(context, "account");
    }
  }

  Map<String, dynamic>? confirmValidate(AbstractControl<dynamic> control) {
    return control.value != "" && control.value == passText ? null : {'confirmValidate': false};
  }

  FormGroup loginForm() => fb.group(<String, Object>{
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
  });

  FormGroup registerForm() => fb.group(<String, Object>{
    'name': FormControl<String>(
      validators: [Validators.required],
    ),
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
    'confirm': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6), confirmValidate],
    ),
  });

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Provider.of<Values>(context, listen: false).currentRoute;
    final bool fieldIsLoading = Provider.of<Values>(context).fieldIsLoading;
    final bool fieldRegisterIsLoading = Provider.of<Values>(context).fieldRegisterIsLoading;
    var height = MediaQuery.of(context).size.height-150;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          title: const Header(),
          elevation: 0.5,
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 15.0,
                  toolbarHeight: 44,
                  elevation: 0,
                  backgroundColor: HexColor("#ffffff"),
                  bottom: PreferredSize(
                    preferredSize: const Size(double.infinity, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                      color: Colors.white,
                      child: TabBar(
                        indicatorColor: HexColor("#FF7061"),
                        indicatorWeight: 4,
                        labelColor: HexColor("#FF7061"),
                        unselectedLabelColor: HexColor("#434D56"),
                        tabs: [
                          SizedBox(
                            height: 28,
                            child: Tab(
                              child: ColoredBox(
                                color: Colors.white,
                                child: Text(
                                  LocaleKeys.tabLogin.tr(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 28,
                            child: Tab(
                              child: ColoredBox(
                                color: Colors.white,
                                child: Text(
                                  LocaleKeys.tabRegister.tr(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Container(
                    height: height,
                    padding: const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 15),
                    color: Colors.white,
                    child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ReactiveFormBuilder(
                            form: loginForm,
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
                                      textInputAction: TextInputAction.next
                                  ),
                                  const SizedBox(height: 15),
                                  ReactiveTextField(
                                    formControlName: 'password',
                                    decoration: InputDecoration(
                                      labelText: LocaleKeys.password.tr(),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    obscureText: true,
                                    validationMessages: {
                                      'required': (error) => LocaleKeys.errorPassword.tr(),
                                      'minLength': (error) => LocaleKeys.errorPasswordLength.tr()
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                        onPressed: () {
                                          Provider.of<Values>(context, listen: false).setData("forgotten");
                                          Navigator.pushNamed(context, "forgotten");
                                        },
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            alignment: Alignment.centerRight
                                        ),
                                        child: Text(
                                          LocaleKeys.forgotten.tr(),
                                          style: TextStyle(color: HexColor("#FF7061"), decoration: TextDecoration.underline),
                                        )
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  ReactiveFormConsumer(
                                    builder: (context, loginForm, child) {
                                      return ElevatedButton(
                                        onPressed: () {
                                          if (!loginForm.valid) {
                                            loginForm.markAllAsTouched();
                                          } else if (!fieldIsLoading) {
                                            Provider.of<Values>(context, listen: false).setFieldIsLoading(true);

                                            var response = Provider.of<Values>(context, listen: false).jsonResponse({
                                              "type": 1,
                                              "method": "login",
                                              "email": loginForm.control('email').value,
                                              "password": loginForm.control('password').value
                                            });

                                            response.then((value) => logins(value, context, currentRoute));
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
                                        child: fieldIsLoading ? const SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(color: Colors.white),
                                        ) : Text(LocaleKeys.login.tr().toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                                      );
                                    },
                                  ),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 23),
                                        Center(
                                          child: Text(LocaleKeys.orSoc.tr(), style: const TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(height: 23),
                                        ElevatedButton(
                                          onPressed: () => _signInGoogle(context, currentRoute),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 0.5,
                                                    color: HexColor("#C7C8D3")
                                                ),
                                                borderRadius: BorderRadius.circular(35)
                                            ),
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(width, 40),
                                          ),
                                          child: SvgPicture.asset("assets/icons/google.svg", semanticsLabel: 'Google', width: 90, height: 40),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => login(context, currentRoute),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 0.5,
                                                    color: HexColor("#C7C8D3")
                                                ),
                                                borderRadius: BorderRadius.circular(35)
                                            ),
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(width, 40),
                                          ),
                                          child: SvgPicture.asset("assets/icons/facebook.svg", semanticsLabel: 'Facebook', width: 80, height: 27),
                                        ),
                                        if (Platform.isIOS) ElevatedButton(
                                            onPressed: () => logIn(context, currentRoute),
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      width: 0.5,
                                                      color: HexColor("#C7C8D3")
                                                  ),
                                                  borderRadius: BorderRadius.circular(35)
                                              ),
                                              backgroundColor: Colors.white,
                                              elevation: 0,
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(width, 40),
                                            ),
                                            child: SvgPicture.asset("assets/icons/appleL.svg", semanticsLabel: 'Apple', width: 80, height: 27)
                                        ),
                                      ]
                                  ),
                                ],
                              );
                            },
                          ),
                          ReactiveFormBuilder(
                            form: registerForm,
                            builder: (context, form, child) {
                              return Column(
                                children: <Widget>[
                                  ReactiveTextField(
                                      formControlName: 'name',
                                      decoration: InputDecoration(
                                        labelText: LocaleKeys.firstname.tr(),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      keyboardType: TextInputType.name,
                                      validationMessages: {
                                        'required': (error) => LocaleKeys.errorName.tr(),
                                      },
                                      textInputAction: TextInputAction.next
                                  ),
                                  const SizedBox(height: 15),
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
                                      textInputAction: TextInputAction.next
                                  ),
                                  const SizedBox(height: 15),
                                  ReactiveTextField(
                                    formControlName: 'password',
                                    decoration: InputDecoration(
                                      labelText: LocaleKeys.password.tr(),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    obscureText: true,
                                    validationMessages: {
                                      'required': (error) => LocaleKeys.errorPassword.tr(),
                                      'minLength': (error) => LocaleKeys.errorPasswordLength.tr()
                                    },
                                    textInputAction: TextInputAction.next,
                                    onChanged: (e) {
                                      var val = e.value;
                                      passText = "$val";
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  ReactiveTextField(
                                    formControlName: 'confirm',
                                    decoration: InputDecoration(
                                      labelText: LocaleKeys.textConfirm.tr(),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    obscureText: true,
                                    validationMessages: {
                                      'required': (error) => LocaleKeys.errorPassword.tr(),
                                      'minLength': (error) => LocaleKeys.errorPasswordLength.tr(),
                                      'confirmValidate': (error) => LocaleKeys.textErrorConfirm.tr()
                                    },
                                  ),
                                  const SizedBox(height: 25),
                                  ReactiveFormConsumer(
                                    builder: (context, form, child) {
                                      return ElevatedButton(
                                        onPressed: () {
                                          if (!form.valid) {
                                            form.markAllAsTouched();
                                          }

                                          if (!fieldRegisterIsLoading && form.valid) {
                                            Provider.of<Values>(context, listen: false).setFieldRegisterIsLoading(true);

                                            var response = Provider.of<Values>(context, listen: false).jsonResponse({
                                              "type": 1,
                                              "method": "register",
                                              "language_id": Provider.of<Values>(context, listen: false).languageId,
                                              "name": form.control('name').value,
                                              "lastname": "",
                                              "service": Platform.isAndroid ? "Android" : "IOS",
                                              "email": form.control('email').value,
                                              "password": form.control('password').value
                                            });

                                            response.then((value) => register(value, context, currentRoute, true));
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
                                        child: fieldRegisterIsLoading ? const SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(color: Colors.white),
                                        ) : Text(LocaleKeys.tabRegister.tr().toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                                      );
                                    },
                                  ),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 23),
                                        Center(
                                          child: Text(LocaleKeys.orSoc.tr(), style: const TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(height: 23),
                                        ElevatedButton(
                                          onPressed: () => _signInGoogle(context, currentRoute),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 0.5,
                                                    color: HexColor("#C7C8D3")
                                                ),
                                                borderRadius: BorderRadius.circular(35)
                                            ),
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(width, 40),
                                          ),
                                          child: SvgPicture.asset("assets/icons/google.svg", semanticsLabel: 'Google', width: 90, height: 40),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => login(context, currentRoute),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 0.5,
                                                    color: HexColor("#C7C8D3")
                                                ),
                                                borderRadius: BorderRadius.circular(35)
                                            ),
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(width, 40),
                                          ),
                                          child: SvgPicture.asset("assets/icons/facebook.svg", semanticsLabel: 'Facebook', width: 80, height: 27),
                                        ),
                                        if (Platform.isIOS) ElevatedButton(
                                            onPressed: () => logIn(context, currentRoute),
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      width: 0.5,
                                                      color: HexColor("#C7C8D3")
                                                  ),
                                                  borderRadius: BorderRadius.circular(35)
                                              ),
                                              backgroundColor: Colors.white,
                                              elevation: 0,
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(width, 40),
                                            ),
                                            child: SvgPicture.asset("assets/icons/appleL.svg", semanticsLabel: 'Apple', width: 80, height: 27)
                                        ),
                                      ]
                                  ),
                                ],
                              );
                            },
                          ),
                        ]
                    ),
                  ),
                ),
              )
          ),
        )
    );
  }
}