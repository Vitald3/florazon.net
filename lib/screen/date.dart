import 'package:easy_localization/easy_localization.dart';
import '../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../values.dart';
import '../models/api.dart';
import '../screen/header.dart';
import 'package:provider/provider.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:reactive_forms/reactive_forms.dart';

class DatePopup extends StatelessWidget {
  const DatePopup({super.key, required this.form});

  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    var dateSelectedText = Provider.of<Values>(context).dateSelectedText;
    final double width = MediaQuery.of(context).size.width;
    final List<Time> time = Provider.of<Values>(context, listen: false).time;
    final today = DateTime.now();
    var fiftyDaysFromNow = today;
    var lastDay = today.add(const Duration(days: 60));

    if (time.isNotEmpty) {
      fiftyDaysFromNow = today.add(const Duration(days: 1));
    }

    final String selectTime = Provider.of<Values>(context, listen: false).selectTime;

    if (dateSelectedText == "") {
      dateSelectedText = DateFormat.yMMMMd().format(fiftyDaysFromNow);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        title: const Header(),
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.errorDate.tr().toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        LocaleKeys.shipDate.tr(),
                        style: TextStyle(color: HexColor("#8C99A5")),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateSelectedText,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                    ]
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -15),
                child: CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                      calendarType: CalendarDatePicker2Type.single,
                      calendarViewMode: DatePickerMode.day,
                      selectedDayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      weekdayLabelTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      controlsTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      selectedDayHighlightColor: HexColor("#FF9186"),
                      centerAlignModePicker: true,
                      customModePickerIcon: const SizedBox(),
                      firstDate: fiftyDaysFromNow,
                      lastDate: lastDay,
                      currentDate: fiftyDaysFromNow
                  ),
                  value: [Provider.of<Values>(context, listen: false).toDate ?? fiftyDaysFromNow],
                  onValueChanged: (dates) async {
                    var date = dates.first!;
                    Provider.of<Values>(context, listen: false).setToDate(date);
                    Provider.of<Values>(context, listen: false).setSelectDate(date.toString().replaceAll(' 00:00:00.000', ''));
                    form.control("date").value = date;
                    Provider.of<Values>(context, listen: false).setSelectDateText(DateFormat.yMMMMd().format(date));
                    await Provider.of<Values>(context, listen: false).getTime();
                  },
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -35),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        Visibility(
                            visible: time.isNotEmpty,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.textTime.tr(),
                                    style: TextStyle(color: HexColor("#8C99A5")),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    selectTime == "" && time.isNotEmpty ? time[0].time! : selectTime,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment: WrapCrossAlignment.start,
                                        children: List.generate(time.length, (index) {
                                          return GestureDetector(
                                            onTap: () {
                                              Provider.of<Values>(context, listen: false).setSelectTime(time[index].time!);
                                            },
                                            child: Container(
                                              width: width * 0.26,
                                              margin: const EdgeInsets.only(top: 8),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(35),
                                                border: Border.all(color: HexColor(
                                                    selectTime == "" && index == 0 ||
                                                        selectTime == time[index].time!
                                                        ? "#FF7061"
                                                        : "#8C99A5"), width: 1),
                                                color: Colors.white,
                                              ),
                                              child: Text(time[index].time!, style: TextStyle(
                                                  color: HexColor(selectTime == "" && index == 0 ||
                                                      selectTime == time[index].time!
                                                      ? "#FF7061"
                                                      : "#8C99A5")), textAlign: TextAlign.center),
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 15)
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (form.control("date").value == null) {
                                        form.control("date").value = fiftyDaysFromNow;
                                      }

                                      if (Provider.of<Values>(context, listen: false).selectTime == "") {
                                        Provider.of<Values>(context, listen: false).setSelectTime(time[0].time!);
                                      }

                                      if (Provider.of<Values>(context, listen: false).toDate == null) {
                                        Provider.of<Values>(context, listen: false).setToDate(fiftyDaysFromNow);
                                      }

                                      if (Provider.of<Values>(context, listen: false).dateSelected == "") {
                                        Provider.of<Values>(context, listen: false).setSelectDate(dateSelectedText.toString().replaceAll(' 00:00:00.000', ''));
                                      }

                                      if (Provider.of<Values>(context, listen: false).dateSelectedText == "") {
                                        Provider.of<Values>(context, listen: false).setSelectDateText(dateSelectedText);
                                      }

                                      Provider.of<Values>(context, listen: false).setPopupVisible(false);
                                      Navigator.of(context).pop();
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
                                    child: Text(LocaleKeys.buttonContinue.tr().toUpperCase(), style: const TextStyle(fontSize: 16, color: Colors.white)),
                                  )
                                ]
                            )
                        ),
                      ]
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }
}