import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/asset_paths.dart';
import '../widgets/nav_bar_item.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    _NavTab(AssetPaths.iconHome, 'nav_home'),
    _NavTab(AssetPaths.iconClipboard, 'nav_today'),
    _NavTab(AssetPaths.iconUser, 'nav_suppliers'),
    _NavTab(AssetPaths.iconChart, 'nav_reports'),
    _NavTab(AssetPaths.iconSettings, 'nav_settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: Column(children: [const OfflineBanner(), Expanded(child: navigationShell)]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = i == currentIndex;
                return GestureDetector(
                  onTap: () => navigationShell.goBranch(i, initialLocation: i == currentIndex),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(width: 64, child: NavBarItem(icon: tab.icon, labelKey: tab.labelKey, isActive: isActive)),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final String icon;
  final String labelKey;
  const _NavTab(this.icon, this.labelKey);
}
