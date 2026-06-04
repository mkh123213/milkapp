import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoggedOut) context.go('/login');
      },
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Text('settings_title'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(cubit.userDisplayName ?? 'user_default'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(cubit.userEmail, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ])),
                        CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.15), radius: 22, child: Image.asset(AssetPaths.iconUser, width: 24, height: 24)),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                _SectionHeader('section_app'.tr()),
                _SettingsGroup(children: [
                  _SettingsRow(icon: AssetPaths.iconCalendar, label: 'week_start'.tr(), value: 'saturday'.tr()),
                  _SettingsRow(icon: AssetPaths.iconScale, label: 'unit_label'.tr(), value: 'kilogram'.tr()),
                  _SettingsRow(icon: AssetPaths.iconGlobe, label: 'language_label'.tr(), value: 'arabic'.tr()),
                ]),
                const SizedBox(height: 8),
                _SectionHeader('section_sync'.tr()),
                _SettingsGroup(children: [
                  _SettingsRow(icon: AssetPaths.iconSync, label: 'auto_sync'.tr(), value: 'enabled'.tr()),
                  _SettingsRow(icon: AssetPaths.iconSave, label: 'cache_label'.tr(), value: 'cache_desc'.tr()),
                ]),
                const SizedBox(height: 8),
                _SectionHeader('section_about'.tr()),
                _SettingsGroup(children: [
                  _SettingsRow(icon: AssetPaths.logo, label: 'app_title'.tr(), value: 'version'.tr()),
                  _SettingsRow(icon: AssetPaths.iconClipboardGreen, label: 'track_daily'.tr(), value: ''),
                ]),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmLogout(context, cubit),
                      icon: const Icon(Icons.logout, color: AppColors.danger),
                      label: Text('logout'.tr(), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger.withValues(alpha: 0.08), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context, SettingsCubit cubit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('logout_title'.tr()),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), onPressed: () => Navigator.pop(context, true), child: Text('logout'.tr(), style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed == true) cubit.logout();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 6), child: Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)));
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
    child: Column(children: [for (int i = 0; i < children.length; i++) ...[children[i], if (i < children.length - 1) Divider(height: 1, indent: 56, color: AppColors.divider.withValues(alpha: 0.5))]]),
  );
}

class _SettingsRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _SettingsRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(children: [Image.asset(icon, width: 24, height: 24), const SizedBox(width: 12), Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), const Spacer(), if (value.isNotEmpty) Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))]),
  );
}
