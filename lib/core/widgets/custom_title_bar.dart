import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bloom/features/home/screens/moreoptions_screen.dart';
import 'package:bloom/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customtitlebar extends StatefulWidget {
  const Customtitlebar({super.key});

  @override
  State<Customtitlebar> createState() => _CustomtitlebarState();
}

class _CustomtitlebarState extends State<Customtitlebar> {
  bool? showSideBar;
  bool? maximize;

  @override
  void initState() {
    super.initState();
    getSideBarStatus();
    maximize = false;
  }

  void getSideBarStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final showSideBarPrefs = prefs.getBool('showSideBar');
    setState(() {
      showSideBar = showSideBarPrefs!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: MoveWindow(
        child: Container(
          color: Theme.of(context).primaryColorLight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  showSideBar = !showSideBar!;
                  Future.delayed(const Duration(seconds: 1), () async {
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
              const SizedBox(
                width: 12,
              ),
              const Spacer(),
              MinimizeWindowButton(
                colors: WindowButtonColors(
                  iconNormal: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
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
