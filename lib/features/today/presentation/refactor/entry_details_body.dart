import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/milk_entry.dart';
import '../cubit/edit_weight_cubit.dart';
import '../cubit/edit_weight_state.dart';

class EntryDetailsBody extends StatelessWidget {
  final String entryId;
  const EntryDetailsBody({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('entry_details_title'.tr())),
      backgroundColor: AppColors.background,
      body: BlocBuilder<EditWeightCubit, EditWeightState>(builder: (context, state) {
        if (state is EditWeightLoading) return const Center(child: CircularProgressIndicator());
        if (state is EditWeightError) return Center(child: Text(state.errorKey.tr(), style: const TextStyle(color: AppColors.danger)));
        final entry = state is EditWeightLoaded ? state.entry : (state is EditWeightSaving ? state.entry : null);
        if (entry == null) return const SizedBox.shrink();
        return _body(context, entry);
      }),
    );
  }

  Widget _body(BuildContext context, MilkEntry entry) {
    final isNoMilk = entry.entryStatus == EntryStatus.noMilk;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _row('supplier_name'.tr(), entry.supplierName),
        const SizedBox(height: 10),
        _row('date'.tr(), MilkDateUtils.formatFullArabic(entry.date)),
        const SizedBox(height: 10),
        _row('time'.tr(), MilkDateUtils.formatTime(entry.createdAt)),
        const Divider(height: 28),
        if (isNoMilk) _noMilkBadge() else _weightBox(entry),
        if (entry.isEdited) ...[const SizedBox(height: 16), _editHistory(entry)],
        if (!entry.canEdit) ...[const SizedBox(height: 12), _hint('already_edited_hint'.tr(), AppColors.edited)],
        const SizedBox(height: 20),
        if (entry.canEdit && !isNoMilk)
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => context.push('/entry/${entry.id}/edit'),
            icon: const Icon(Icons.edit, size: 18), label: Text('edit_weight'.tr()),
          )),
      ]),
    );
  }

  Widget _row(String label, String value) => Row(children: [
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    const Spacer(),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  ]);

  Widget _weightBox(MilkEntry entry) {
    final kg = entry.currentWeightKg?.toStringAsFixed(1) ?? '0';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Icon(Icons.scale, color: AppColors.primary, size: 28), const SizedBox(width: 12),
        Text('${MilkDateUtils.toArabicNumeralsStr(kg)} ${'unit_kg'.tr()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ]),
    );
  }

  Widget _noMilkBadge() => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.noMilkBg, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      const Icon(Icons.block, color: AppColors.noMilk, size: 24), const SizedBox(width: 10),
      Text('no_milk'.tr(), style: const TextStyle(color: AppColors.noMilk, fontWeight: FontWeight.bold, fontSize: 16)),
    ]),
  );

  Widget _editHistory(MilkEntry entry) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.editedBg, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.history, size: 16, color: AppColors.edited), const SizedBox(width: 6),
        Text('edit_history'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.edited, fontSize: 13))]),
      const SizedBox(height: 6),
      Text('${'original_weight'.tr()}: ${MilkDateUtils.toArabicNumeralsStr(entry.originalWeightKg?.toStringAsFixed(1) ?? '0')} ${'unit_kg'.tr()}', style: const TextStyle(fontSize: 12)),
      if (entry.editReason != null) Text('${'edit_reason'.tr()}: ${entry.editReason}', style: const TextStyle(fontSize: 12)),
      if (entry.editedAt != null) Text('${'edited_at'.tr()}: ${MilkDateUtils.formatTime(entry.editedAt!)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]),
  );

  Widget _hint(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Icon(Icons.info_outline, size: 16, color: color), const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12))),
    ]),
  );
}
