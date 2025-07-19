// import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bloom/screens/moreoptions_screen.dart';
import 'package:bloom/screens/settings_screen.dart';
import 'package:bloom/windows_components/navigationrail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customtitlebar extends StatefulWidget {
  const Customtitlebar({super.key});

  @override
  State<Customtitlebar> createState() => _CustomtitlebarState();
}

class _CustomtitlebarState extends State<Customtitlebar> {
  // Required variables
  bool? showSideBar;
  bool? maximize;
  // Init method
  @override
  void initState() {
    super.initState();
    getSideBarStatus();
    maximize = false;
  }

  // Set sidebar
  void getSideBarStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final showSideBarPrefs = prefs.getBool('showSideBar');
    setState(() {
      showSideBar = showSideBarPrefs!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationrailProvider = Provider.of<NavigationrailProvider>(context);
    return WindowTitleBarBox(
      child: MoveWindow(
        child: Container(
          color: Theme.of(context).primaryColorLight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Open or close sideBar button
              IconButton(
                onPressed: () {
                  showSideBar = !showSideBar!;
                  Future.delayed(const Duration(seconds: 1), () async {
                    // Update Provider state and persist preference
                    navigationrailProvider
                        .setSideBarStatus(showSideBar ?? true);
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('showSideBar', showSideBar ?? true);
                  });
                },
                icon: showSideBar != null && showSideBar == true
                    ? const Icon(
                        Icons.menu_open_rounded,
                        size: 18,
                      )
                    : const Icon(
                        Icons.close_rounded,
                        size: 18,
                      ),
              ),
              // Other options for title bar
              // const Text(
              //   'File',
              //   style: TextStyle(fontSize: 12),
              // ),
              // const SizedBox(
              //   width: 12,
              // ),
              // const Text(
              //   'Edit',
              //   style: TextStyle(fontSize: 12),
              // ),
              // const SizedBox(
              //   width: 12,
              // ),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsPage())),
                child: const Text(
                  'Settings',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MoreOptionsScreen())),
                child: const Text(
                  'More',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              // PopupMenuButton(
              //   color: Theme.of(context).scaffoldBackgroundColor,
              //   borderRadius: BorderRadius.circular(15),
              //   menuPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              //   position: PopupMenuPosition.under,
              //   itemBuilder: (context) => [
              //     PopupMenuItem(
              //       height: 25,
              //       onTap: () {
              //         if (Platform.isAndroid) {
              //           print('Check for android version');
              //         } else {
              //           print('Check for windows version');
              //         }
              //       },
              //       child: Text(
              //         'Check for updates',
              //         style: TextStyle(
              //             color: Theme.of(context).textTheme.bodyMedium?.color),
              //       ),
              //     ),
              //   ],
              //   child: const Text(
              //     'Help',
              //     style: TextStyle(fontSize: 12),
              //   ),
              // ),
              const SizedBox(
                width: 12,
              ),
              // Spacer to space between the window buttons and other buttons
              const Spacer(),
              // Minimize button
              MinimizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              // Maximize and restore button
              WindowButton(
                onPressed: () {
                  setState(() {
                    maximize = !maximize!;
                    appWindow.maximizeOrRestore();
                  });
                },
                iconBuilder: (contexts) {
                  return maximize == false
                      ? MaximizeIcon(
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color ??
                                  Colors.black)
                      : RestoreIcon(
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color ??
                                  Colors.black);
                },
              ),
              // Close button
              CloseWindowButton(
                colors: WindowButtonColors(
                  iconNormal: Theme.of(context).textTheme.bodyMedium?.color,
                  mouseOver: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
