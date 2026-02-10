import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'core/utils/app_colors.dart';
import 'features/clients/presentation/screens/clients_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/orders/presentation/screens/orders_screen.dart';
import 'features/settings/presentation/screens/setting_view.dart';
import 'l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Data structure for icons
  static final List<Map<String, dynamic>> _screensData = [
    {"icon": CupertinoIcons.house},
    {"icon": CupertinoIcons.list_bullet_below_rectangle},
    {"icon": CupertinoIcons.person_2_fill},
    {"icon": CupertinoIcons.settings_solid},
  ];

  // Data structure for titles (Localizations need context)
  static List<String> _getTabTitles(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      l10n!.home,
      l10n.orders,
      l10n.clients,
      l10n.profile,
    ];
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<PersistentBottomNavBarItem> _navBarsItems(Color activeColor) {
    final titles = MainScreen._getTabTitles(context);

    return List.generate(MainScreen._screensData.length, (index) {
      return PersistentBottomNavBarItem(
        iconSize: 25,
        icon: Icon(MainScreen._screensData[index]["icon"]),
        title: titles[index], // This adds the text below the icon
        activeColorPrimary: activeColor,
        inactiveColorPrimary: Colors.grey,
        // Optional: ensures the text color matches the icon color
        activeColorSecondary: activeColor,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final activeColor = isDark ? Colors.white : AppColors.primary;

    return PersistentTabView(
      context,
      controller: _controller,
      screens: const [
        HomeScreen(),
        OrdersScreen(),
        ClientsScreen(), // Replace with Clients Screen()
        SettingView(),
      ],
      items: _navBarsItems(activeColor),
      confineToSafeArea: true,
      backgroundColor: backgroundColor,
      handleAndroidBackButtonPress: true,

      resizeToAvoidBottomInset: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
      ),
      // Style 1, 3, or 6 are best for displaying titles clearly
      navBarStyle: NavBarStyle.style3,
    );
  }
}