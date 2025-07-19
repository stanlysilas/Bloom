import 'package:bloom/required_data/colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme =
    // Light theme customization
    ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle:
        TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Nunito'),
    elevation: 0,
    actionsIconTheme: IconThemeData(color: Colors.black),
  ),
  primaryColor: primaryColorLightMode,
  primaryColorLight: boxBackgroundColorLightMode,
  primaryColorDark: Colors.grey.shade400,
  dividerColor: Colors.grey,
  iconTheme: const IconThemeData(color: Colors.black),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black),
    labelMedium: TextStyle(color: Colors.white),
  ),
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  radioTheme:
      RadioThemeData(fillColor: WidgetStatePropertyAll(primaryColorLightMode)),
  textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(primaryColorLightMode),
          textStyle: WidgetStatePropertyAll(TextStyle(
            fontWeight: FontWeight.w500,
          )))),
  searchBarTheme: SearchBarThemeData(
      textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.black)),
      hintStyle: WidgetStatePropertyAll(TextStyle(color: Colors.grey))),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primaryColorLightMode,
    selectionColor: primaryColorLightMode.withAlpha(80),
    selectionHandleColor: primaryColorDarkMode,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(primaryColorLightMode))),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    todayForegroundColor: const WidgetStatePropertyAll(Colors.black),
    todayBackgroundColor: WidgetStateProperty.all(primaryColorLightMode),
    todayBorder: BorderSide.none,
    dayForegroundColor: WidgetStateProperty.all(Colors.black),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: primaryColorLightMode,
        ),
      ),
    ),
    cancelButtonStyle:
        ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.red)),
    confirmButtonStyle:
        ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.black)),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.white,
    dayPeriodColor: primaryColorLightMode,
    dayPeriodTextColor: Colors.black,
    dialBackgroundColor: Colors.grey[100],
    dialHandColor: primaryColorLightMode,
    entryModeIconColor: Colors.black,
    hourMinuteColor: primaryColorLightMode,
    hourMinuteShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    hourMinuteTextColor: Colors.black,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColorLightMode)),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    ),
    cancelButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.red),
    ),
    confirmButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.black),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.grey[50],
      labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(color: Colors.black, fontSize: 12)),
      iconTheme:
          const WidgetStatePropertyAll(IconThemeData(color: Colors.black))),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: Colors.grey.shade300,
    selectedLabelTextStyle: const TextStyle(
        color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
    unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
    selectedIconTheme: const IconThemeData(color: Colors.white),
    unselectedIconTheme: const IconThemeData(color: Colors.grey),
  ),
  bottomSheetTheme:
      const BottomSheetThemeData(backgroundColor: Colors.transparent),
  // fontFamily: 'Nunito',
  // pageTransitionsTheme: PageTransitionsTheme(
  //   builders: {
  //     TargetPlatform.android: CustomPageTransitionsBuilder(),
  //     TargetPlatform.iOS: CustomPageTransitionsBuilder(),
  //     TargetPlatform.windows: CustomPageTransitionsBuilder(),
  //     TargetPlatform.macOS: CustomPageTransitionsBuilder(),
  //     TargetPlatform.linux: CustomPageTransitionsBuilder(),
  //   },
  // ),
);

final ThemeData darkTheme =
// Dark theme customization
    ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF181818),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF181818),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle:
        TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Nunito'),
    elevation: 0,
    actionsIconTheme: IconThemeData(color: Colors.white),
  ),
  primaryColor: primaryColorDarkMode,
  primaryColorLight: boxBackgroundColorDarkMode,
  primaryColorDark: Colors.grey[800],
  dividerColor: Colors.grey,
  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.black)),
  checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      side: const BorderSide(color: Colors.white)),
  radioTheme:
      RadioThemeData(fillColor: WidgetStatePropertyAll(primaryColorDarkMode)),
  textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(primaryColorDarkMode),
          textStyle: WidgetStatePropertyAll(TextStyle(
            fontWeight: FontWeight.w500,
          )))),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(primaryColorDarkMode))),
  searchBarTheme: SearchBarThemeData(
      textStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white)),
      hintStyle: WidgetStatePropertyAll(TextStyle(color: Colors.grey))),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: primaryColorDarkMode,
    selectionColor: primaryColorDarkMode.withAlpha(80),
    selectionHandleColor: primaryColorLightMode,
  ),
  datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.grey.shade900,
      headerForegroundColor: Colors.white,
      todayBorder: BorderSide.none,
      weekdayStyle: const TextStyle(color: Colors.grey),
      yearForegroundColor: WidgetStateProperty.all(Colors.white),
      todayBackgroundColor: WidgetStateProperty.all(primaryColorDarkMode),
      todayForegroundColor: WidgetStateProperty.all(Colors.white),
      dayForegroundColor: WidgetStateProperty.all(Colors.white),
      rangePickerHeaderBackgroundColor: Colors.white,
      rangePickerHeaderForegroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: const TextStyle(color: Colors.white),
        prefixStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: primaryColorDarkMode,
          ),
        ),
      ),
      cancelButtonStyle:
          ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.red)),
      confirmButtonStyle:
          ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.white))),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.grey.shade900,
    dayPeriodColor: primaryColorDarkMode,
    dayPeriodTextColor: Colors.white,
    dialBackgroundColor: boxBackgroundColorDarkMode,
    dialHandColor: primaryColorDarkMode,
    dialTextColor: Colors.white,
    entryModeIconColor: Colors.white,
    hourMinuteColor: primaryColorDarkMode,
    hourMinuteTextColor: Colors.white,
    hourMinuteShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    inputDecorationTheme: InputDecorationTheme(
        counterStyle: const TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryColorDarkMode)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none)),
    cancelButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.red),
    ),
    confirmButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.white),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.grey[900],
      labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(color: Colors.white, fontSize: 12)),
      iconTheme:
          const WidgetStatePropertyAll(IconThemeData(color: Colors.white))),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: Colors.grey.shade800.withAlpha(80),
    selectedLabelTextStyle: const TextStyle(
        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
    unselectedLabelTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
    selectedIconTheme: const IconThemeData(color: Colors.white),
    unselectedIconTheme: const IconThemeData(color: Colors.grey),
  ),
  bottomSheetTheme:
      const BottomSheetThemeData(backgroundColor: Colors.transparent),
  // fontFamily: 'Nunito',
  // pageTransitionsTheme: PageTransitionsTheme(
  //   builders: {
  //     TargetPlatform.android: CustomPageTransitionsBuilder(),
  //     TargetPlatform.iOS: CustomPageTransitionsBuilder(),
  //     TargetPlatform.windows: CustomPageTransitionsBuilder(),
  //     TargetPlatform.macOS: CustomPageTransitionsBuilder(),
  //     TargetPlatform.linux: CustomPageTransitionsBuilder(),
  //   },
  // ),
);

// class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
//   @override
//   Widget buildTransitions<T>(
//     PageRoute<T> route,
//     BuildContext context,
//     Animation<double> animation,
//     // late final Animation<Offset> _offsetAnimation = ;
//     Animation<double> secondaryAnimation,
//     Widget child,
//   ) {
//     return SlideTransition(
//       position: Tween<Offset>(
//         begin: Offset.zero,
//         end: const Offset(1.5, 0.0),
//       ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticIn)),
//       child: child,
//     );
//   }
// }
