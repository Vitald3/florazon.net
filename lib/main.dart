import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'generated/codegen_loader.g.dart';
import 'package:hexcolor/hexcolor.dart';
import 'extensions.dart';
import 'values.dart';
import 'screen/home.dart';
import 'screen/city.dart';
import 'screen/category.dart';
import 'screen/forgotten.dart';
import 'screen/account.dart';
import 'screen/product.dart';
import 'screen/checkout.dart';
import 'screen/payment.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  final Box<dynamic> setting = await Hive.openBox('setting');
  var values = Values(setting);
  values.setData(setting.get('route') ?? "/");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('en'), Locale('uk'), Locale('pl')],
      path: 'assets/translations',
      fallbackLocale: Locale(values.languageCode),
      assetLoader: const CodegenLoader(),
      child: ChangeNotifierProvider<Values>(
        create: (context) => values,
        child: Florazon(route: setting.get('route') ?? "/", cityId: setting.get('city_id') ?? 0),
      ),
    ),
  );
}

class Florazon extends StatelessWidget {
  const Florazon({super.key, required this.route, required this.cityId});

  final String route;
  final int cityId;

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp(
          routes: {
            '/': (_) => const Home(title: 'Florazon'),
            'city': (_) => City(title: LocaleKeys.selectCity.tr()),
            'category': (_) => const CategoryItem(title: "Category"),
            'forgotten': (_) => const Forgotten(title: "Forgotten"),
            'account': (_) => const Account(title: "Account"),
            'product': (_) => const ProductView(title: "Product"),
            'checkout': (_) => const Checkout(title: "checkout"),
            'payment': (_) => const Payment(title: "Payment"),
          },
          initialRoute: cityId == 0 ? "city" : route,
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/':
                return CupertinoPageRoute(builder: (_) => const Home(title: 'Florazon'), settings: settings);
              case 'city':
                return CupertinoPageRoute(builder: (_) => City(title: LocaleKeys.selectCity.tr()), settings: settings);
              case 'category':
                return CupertinoPageRoute(builder: (_) => const CategoryItem(title: "Category"), settings: settings);
              case 'forgotten':
                return CupertinoPageRoute(builder: (_) => const Forgotten(title: "Forgotten"), settings: settings);
              case 'account':
                return CupertinoPageRoute(builder: (_) => const Account(title: "Account"), settings: settings);
              case 'product':
                return CupertinoPageRoute(builder: (_) => const ProductView(title: "Product"), settings: settings);
              case 'checkout':
                return CupertinoPageRoute(builder: (_) => const Checkout(title: "Checkout"), settings: settings);
              case 'payment':
                return CupertinoPageRoute(builder: (_) => const Payment(title: "Payment"), settings: settings);
              default:
                return CupertinoPageRoute(builder: (_) => City(title: LocaleKeys.selectCity.tr()));
            }
          },
          onUnknownRoute: (settings) => CupertinoPageRoute(
              builder: (context) {
                return City(title: LocaleKeys.selectCity.tr());
              }
          ),
          debugShowCheckedModeBanner: false,
          title: 'Florazon',
          theme: ThemeData(
            primarySwatch: HexColor("#FF7061").asMaterialColor,
            textTheme: TextTheme(
              displayLarge: TextStyle(color: HexColor("#434D56")),
              displayMedium: TextStyle(color: HexColor("#434D56")),
              bodyMedium: TextStyle(color: HexColor("#434D56")),
              titleMedium: TextStyle(color: HexColor("#434D56")),
            ),
          ),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale
      ),
    );
  }
}