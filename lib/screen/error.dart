import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../values.dart';
import 'package:provider/provider.dart';

class Error extends StatelessWidget {
  const Error({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Provider.of<Values>(context, listen: false).currentRoute;

    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.errorNetwork.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, decoration: TextDecoration.none, color: HexColor("#434D56")),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<Values>(context, listen: false).resetHistory();
                    Provider.of<Values>(context, listen: false).setData(currentRoute);
                    Navigator.pushNamed(context, currentRoute);
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                  ),
                  child: Text(LocaleKeys.reload.tr(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<Values>(context, listen: false).resetHistory();
                    Provider.of<Values>(context, listen: false).setData("/");
                    Navigator.pushNamed(context, "/");
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                  ),
                  child: Text(LocaleKeys.buttonContinue.tr(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            )
        )
    );
  }
}