import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';

class setting extends StatefulWidget {
  const setting({super.key});

  @override
  State<setting> createState() => _settingState();
}

class _settingState extends State<setting> {
  late bool noti = false;
  late bool mode = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double header = width * (isPortrait ? 0.08 : 0.04);
    double subText = width * (isPortrait ? 0.045 : 0.03);
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.only(
            top: height * 0.05, left: width * 0.08, right: width * 0.08),
        child: SafeArea(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Settings',
                  style:
                      TextStyle(fontSize: header, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: height * 0.06,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: !themeProvider.isDark ? Colors.black : Colors.white,
                ),
                child: Column(
                  children: [
                    letstry(
                        width,
                        height,
                        'App Version',
                        Text(
                          '1.1.0',
                          style: TextStyle(
                              fontSize: subText,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey),
                        ),
                        true,
                        subText),
                    letstry(
                        width,
                        height,
                        'Notifications',
                        FlutterSwitch(
                          height: 26,
                          width: 45,
                          padding: 1.5,
                          value: noti,
                          onToggle: (val) => setState(
                            () {
                              noti = val;
                            },
                          ),
                        ),
                        true,
                        subText),
                    letstry(
                        width,
                        height,
                        'Dark Mode',
                        FlutterSwitch(
                          height: 26,
                          width: 45,
                          padding: 1.5,
                          value: !themeProvider.isDark,
                          onToggle: (val) => setState(
                            () {
                              final provider = Provider.of<ThemeProvider>(
                                  context,
                                  listen: false);
                              provider.toggleTheme(!val);
                            },
                          ),
                        ),
                        false,
                        subText),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.04),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: !themeProvider.isDark ? Colors.black : Colors.white),
                child: Column(
                  children: [
                    letstry(
                        width,
                        height,
                        'Privacy Policy',
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color.fromARGB(255, 131, 131, 131),
                        ),
                        true,
                        subText),
                    letstry(
                        width,
                        height,
                        'About Us',
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color.fromARGB(255, 131, 131, 131),
                        ),
                        true,
                        subText),
                    letstry(
                        width,
                        height,
                        'Contact Us',
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color.fromARGB(255, 131, 131, 131),
                        ),
                        false,
                        subText),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container letstry(double width, double height, String name, Widget last,
      bool check, double fontSize) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 2,
                  color: check
                      ? const Color.fromARGB(255, 224, 224, 224)
                      : Colors.transparent))),
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.04, vertical: height * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize),
          ),
          last
        ],
      ),
    );
  }
}
