import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../injection_container.dart';
import '../../../auth/data/repos/auth_repo.dart';
import '../../data/repos/suppliers_repo.dart';
import '../cubit/route_ordering_cubit.dart';
import '../cubit/route_ordering_state.dart';

class RouteOrderingBody extends StatefulWidget {
  const RouteOrderingBody({super.key});

  @override
  State<RouteOrderingBody> createState() => _RouteOrderingBodyState();
}

class _RouteOrderingBodyState extends State<RouteOrderingBody> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadSuppliers();
    }
  }

  Future<void> _loadSuppliers() async {
    final uid = getIt<AuthRepo>().currentUserId;
    if (uid == null) return;
    final suppliers = await getIt<SuppliersRepo>().getActiveSuppliers(uid);
    if (mounted) context.read<RouteOrderingCubit>().init(suppliers);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RouteOrderingCubit, RouteOrderingState>(
      listener: (context, state) {
        if (state.saved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('order_saved'.tr()), backgroundColor: AppColors.primary));
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final cubit = context.read<RouteOrderingCubit>();
        return PopScope(
          canPop: state.changeCount == 0,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await showDialog<bool>(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text('unsaved_changes'.tr()), content: Text('unsaved_changes_body'.tr()), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())), ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('exit'.tr(), style: const TextStyle(color: Colors.white)))]));
            if ((leave ?? false) && context.mounted) Navigator.pop(context);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                Container(color: Colors.white, child: SafeArea(bottom: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 14), child: Row(children: [GestureDetector(onTap: () { if (state.changeCount == 0) Navigator.pop(context); }, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20))), const SizedBox(width: 12), Expanded(child: Text('route_ordering_title'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), GestureDetector(onTap: cubit.autoSort, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text('auto_sort'.tr(), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))))])))),
                if (state.changeCount == 0) Container(width: double.infinity, padding: const EdgeInsets.all(10), color: AppColors.noMilkBg, child: Text('drag_to_reorder'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.noMilk, fontSize: 13))),
                Expanded(
                  child: state.ordered.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ReorderableListView.builder(
                          itemCount: state.ordered.length,
                          onReorder: cubit.reorder,
                          itemBuilder: (_, i) {
                            final s = state.ordered[i];
                            return Container(
                              key: ValueKey(s.id), margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
                              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [
                                Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(MilkDateUtils.toArabicNumerals(i + 1), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)), if (s.village != null) Row(children: [Image.asset(AssetPaths.iconPin, width: 10, height: 10), const SizedBox(width: 4), Text(s.village!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))])])),
                                const Icon(Icons.drag_handle, color: AppColors.textSecondary),
                              ])),
                            );
                          },
                        ),
                ),
                Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: state.saving ? null : cubit.save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2), child: state.saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(state.changeCount > 0 ? 'save_order_count'.tr(args: [MilkDateUtils.toArabicNumerals(state.changeCount)]) : 'save_order'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))))),
              ],
            ),
          ),
        );
      },
    );
  }
}
