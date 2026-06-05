import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/asset_paths.dart';
import '../widgets/nav_bar_item.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _NavTab('/dashboard', AssetPaths.iconHome, 'nav_home'),
    _NavTab('/today', AssetPaths.iconClipboard, 'nav_today'),
    _NavTab('/suppliers', AssetPaths.iconUser, 'nav_suppliers'),
    _NavTab('/reports', AssetPaths.iconChart, 'nav_reports'),
    _NavTab('/settings', AssetPaths.iconSettings, 'nav_settings'),
  ];

  int _indexForLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: Column(children: [const OfflineBanner(), Expanded(child: child)]),
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
                  onTap: () => context.go(tab.path),
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
  final String path;
  final String icon;
  final String labelKey;
  const _NavTab(this.path, this.icon, this.labelKey);
}
