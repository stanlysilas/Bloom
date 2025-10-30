import 'package:bloom/theme/colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: blueLightColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: blueLightColorScheme.surface,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: blueDarkColorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: blueDarkColorScheme.surface,
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
