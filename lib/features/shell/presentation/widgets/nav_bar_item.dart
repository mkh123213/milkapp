import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';

class NavBarItem extends StatefulWidget {
  final String icon;
  final String labelKey;
  final bool isActive;
  const NavBarItem({super.key, required this.icon, required this.labelKey, required this.isActive});

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250), curve: Curves.easeInOut,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: widget.isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(widget.isActive ? AppColors.primary : AppColors.textHint, BlendMode.srcATop),
              child: AnimatedOpacity(duration: const Duration(milliseconds: 250), opacity: widget.isActive ? 1.0 : 0.5, child: Image.asset(widget.icon, width: 24, height: 24)),
            ),
          ),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(fontSize: 11, fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal, color: widget.isActive ? AppColors.primary : AppColors.textSecondary, fontFamily: 'Roboto'),
          child: Text(widget.labelKey.tr()),
        ),
      ],
    );
  }
}
