import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants.dart';
import '../../../../injection_container.dart';
import '../../../../shared/models/supplier.dart';
import '../cubit/weight_entry_cubit.dart';
import '../cubit/weight_entry_state.dart';

void showWeightEntrySheet(BuildContext context, Supplier supplier) {
  showModalBottomSheet(
    context: context, isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => BlocProvider(create: (_) => getIt<WeightEntryCubit>(), child: _Sheet(supplier: supplier)),
  );
}

class _Sheet extends StatefulWidget {
  final Supplier supplier;
  const _Sheet({required this.supplier});
  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  final _wCtrl = TextEditingController();
  final _nCtrl = TextEditingController();
  bool _dirty = false;

  @override
  void dispose() { _wCtrl.dispose(); _nCtrl.dispose(); super.dispose(); }

  double? get _w => double.tryParse(_wCtrl.text);
  bool get _valid => _w != null && _w! >= AppConstants.minWeightKg && _w! <= AppConstants.maxWeightKg;
  bool get _high => _w != null && _w! >= AppConstants.highWeightThreshold;

  void _save() {
    if (!_valid) return;
    context.read<WeightEntryCubit>().saveWeight(
      supplierId: widget.supplier.id, supplierName: widget.supplier.name,
      weight: _w!, notes: _nCtrl.text.trim().isEmpty ? null : _nCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
          title: Text('discard_changes_title'.tr()), content: Text('discard_changes_body'.tr()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('discard'.tr())),
          ],
        ));
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: BlocListener<WeightEntryCubit, WeightEntryState>(
        listener: (context, state) {
          if (state is WeightEntrySaved) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('weight_saved'.tr()))); }
          if (state is WeightEntryError) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorKey.tr()))); }
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Text(widget.supplier.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            if (widget.supplier.village != null) Text(widget.supplier.village!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: _wCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}'))],
              decoration: InputDecoration(labelText: 'weight_label'.tr(), suffixText: 'unit_kg'.tr()),
              onChanged: (_) => setState(() => _dirty = true),
            ),
            if (_high) ...[const SizedBox(height: 8), Row(children: [
              const Icon(Icons.warning_amber, size: 16, color: AppColors.edited), const SizedBox(width: 6),
              Expanded(child: Text('high_weight_warning'.tr(), style: const TextStyle(color: AppColors.edited, fontSize: 12))),
            ])],
            const SizedBox(height: 12),
            TextField(controller: _nCtrl, maxLength: AppConstants.maxNotesLength,
              decoration: InputDecoration(labelText: 'notes_label'.tr(), hintText: 'notes_hint'.tr()),
              onChanged: (_) => setState(() => _dirty = true)),
            const SizedBox(height: 16),
            BlocBuilder<WeightEntryCubit, WeightEntryState>(builder: (context, state) {
              final saving = state is WeightEntrySaving;
              return SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: saving || !_valid ? null : _save,
                child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('save'.tr()),
              ));
            }),
          ]),
        ),
      ),
    );
  }
}
