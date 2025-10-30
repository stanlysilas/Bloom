import 'package:bloom/theme/color_picker_panel.dart';
import 'package:bloom/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeAndColorsScreen extends StatefulWidget {
  const ThemeAndColorsScreen({super.key});

  @override
  State<ThemeAndColorsScreen> createState() => _ThemeAndColorsScreenState();
}

class _ThemeAndColorsScreenState extends State<ThemeAndColorsScreen> {
  int? colorSchemeValue = 0;
  int? themeSchemeValue;

  @override
  void initState() {
    super.initState();
    getThemeSchemeValue();
  }

  /// Get the themeSchemeValue from SharedPreferences
  void getThemeSchemeValue() async {
    final prefs = await SharedPreferences.getInstance();
    final String themePreference =
        prefs.getString('themeSchemeValue') ?? 'system';

    if (themePreference == 'light') {
      setState(() {
        themeSchemeValue = 0;
      });
    } else if (themePreference == 'dark') {
      setState(() {
        themeSchemeValue = 1;
      });
    } else {
      setState(() {
        themeSchemeValue = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme & Colors'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          // Title of Theme Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Theme Mode',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          // Theme Changing Button
          Container(
            margin: EdgeInsets.symmetric(horizontal: 14),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
                color: Theme.of(context).colorScheme.surfaceContainer),
            width: double.maxFinite,
            alignment: Alignment.center,
            child: SegmentedButton<int>(
              selected: <int>{themeSchemeValue ?? 2},
              showSelectedIcon: true,
              segments: [
                ButtonSegment(
                    value: 0, icon: Icon(Icons.sunny), label: Text('Light')),
                ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.mode_night_rounded),
                    label: Text('Dark')),
                ButtonSegment(
                    value: 2,
                    icon: Icon(Icons.phone_android_rounded),
                    label: Text('System')),
              ],
              onSelectionChanged: (value) {
                setState(() {
                  themeSchemeValue = value.first;
                });

                final themeProvider =
                    Provider.of<ThemeProvider>(context, listen: false);

                if (themeSchemeValue == 0) {
                  themeProvider.setTheme('light');
                } else if (themeSchemeValue == 1) {
                  themeProvider.setTheme('dark');
                } else {
                  themeProvider.setTheme('system');
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          // Title of the ColorPickerPanel Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Color Scheme',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          // ColorScheme Changing Block
          Container(
            margin: EdgeInsets.symmetric(horizontal: 14),
            padding: EdgeInsets.all(12),
            width: double.maxFinite,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
                color: Theme.of(context).colorScheme.surfaceContainer),
            child: ColorPickerPanel(),
          )
        ],
      ),
    );
  }
}


              // ExpansionTile(
              //   tilePadding: EdgeInsets.symmetric(horizontal: 6),
              //   leading: Icon(Icons.phonelink_setup_rounded),
              //   dense: true,
              //   expandedCrossAxisAlignment: CrossAxisAlignment.start,
              //   title: Text(
              //     'Preferences',
              //     style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              //   ),
              //   subtitle: const Text(
              //     'Options to change the app preferences',
              //     style: TextStyle(color: Colors.grey, fontSize: 14),
              //   ),
              //   children: [
              //     // App theme switching option
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //       child: const Text(
              //         'Theme',
              //         style:
              //             TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //       child: const Text(
              //         'Change the main theme of the app',
              //         style: TextStyle(color: Colors.grey),
              //       ),
              //     ),
              //     const SizedBox(
              //       height: 12,
              //     ),
              //     //
              
              //     const SizedBox(
              //       height: 8,
              //     ),
              //     // ColorScheme change options
              //     ColorPickerPanel(),
              //     // TODO: IMPLEMENT SOMETHING USEFUL WITH THE NOTIFICATIONS PANEL SOMETIME LATER INSTEAD OF JUST TOGGLING IT
              //     // BloomListTile(
              //     //   icon: const Icon(Icons.notifications_none_rounded),
              //     //   iconLabelSpace: 8,
              //     //   useSpacer: true,
              //     //   label: 'Notifications',
              //     //   labelStyle: const TextStyle(
              //     //       fontWeight: FontWeight.w600, fontSize: 16),
              //     //   endIcon: const Icon(Icons.keyboard_arrow_right_rounded),
              //     //   innerPadding: const EdgeInsets.symmetric(
              //     //       vertical: 12, horizontal: 14),
              //     //   onTap: () {
              //     //     // Navigate to the notification preferences or settings screen
              //     //     Navigator.of(context).push(MaterialPageRoute(
              //     //         builder: (context) =>
              //     //             const NotificationPreferences()));
              //     //   },
              //     // ),
              //     const SizedBox(
              //       height: 8,
              //     ),
              //     // Option to change the colors of the objects in CalendarView
              //     // BloomListTile(
              //     //   icon: Icon(Icons.format_color_fill_rounded),
              //     //   iconLabelSpace: 8,
              //     //   useSpacer: true,
              //     //   label: 'Change object color',
              //     //   labelStyle: TextStyle(
              //     //     fontWeight: FontWeight.w400,
              //     //     fontSize: 16
              //     //   ),

              //     // ),
              //     // // Change color scheme of the app title & button
              //     // const Text(
              //     //   'Color scheme',
              //     //   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              //     // ),
              //     // const SizedBox(
              //     //   height: 12,
              //     // ),
              //     // SizedBox(
              //     //   width: double.maxFinite,
              //     //   child: CupertinoSlidingSegmentedControl(
              //     //     thumbColor: Theme.of(context).primaryColor,
              //     //     children: {
              //     //       0: Container(
              //     //         height: 12,
              //     //         width: 12,
              //     //         decoration: BoxDecoration(
              //     //           borderRadius: BorderRadius.circular(100),
              //     //           color: Theme.of(context).primaryColor,
              //     //         ),
              //     //       ),
              //     //       1: Container(
              //     //         height: 12,
              //     //         width: 12,
              //     //         decoration: BoxDecoration(
              //     //           borderRadius: BorderRadius.circular(100),
              //     //           color: primaryColorLightMode,
              //     //         ),
              //     //       ),
              //     //       2: Container(
              //     //         height: 12,
              //     //         width: 12,
              //     //         decoration: BoxDecoration(
              //     //             borderRadius: BorderRadius.circular(100),
              //     //             color: secondaryColorLightMode),
              //     //       ),
              //     //     },
              //     //     onValueChanged: (value) {
              //     //       setState(() {
              //     //         colorSchemeValue = value;
              //     //         print(colorSchemeValue);
              //     //       });
              //     //     },
              //     //     groupValue: colorSchemeValue,
              //     //   ),
              //     // ),
              //   ],
              // ),