import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/models/milk_entry.dart';
import '../cubit/edit_weight_cubit.dart';
import '../cubit/edit_weight_state.dart';

class EditWeightBody extends StatelessWidget {
  final String entryId;
  const EditWeightBody({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('edit_weight_title'.tr())),
      backgroundColor: AppColors.background,
      body: BlocBuilder<EditWeightCubit, EditWeightState>(builder: (context, state) {
        if (state is EditWeightLoading) return const Center(child: CircularProgressIndicator());
        if (state is EditWeightError) return Center(child: Text(state.errorKey.tr(), style: const TextStyle(color: AppColors.danger)));
        final entry = state is EditWeightLoaded ? state.entry : (state is EditWeightSaving ? state.entry : null);
        if (entry == null) return const SizedBox.shrink();
        return _Form(entry: entry);
      }),
    );
  }
}

class _Form extends StatefulWidget {
  final MilkEntry entry;
  const _Form({required this.entry});
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final _wCtrl = TextEditingController();
  final _rCtrl = TextEditingController();
  String? _reason;

  static const _reasons = ['edit_reason_wrong_weight', 'edit_reason_wrong_supplier', 'edit_reason_scale_error', 'edit_reason_other'];

  @override
  void dispose() { _wCtrl.dispose(); _rCtrl.dispose(); super.dispose(); }

  double? get _w => double.tryParse(_wCtrl.text);
  bool get _isOther => _reason == 'edit_reason_other';
  String get _reasonText => _isOther ? _rCtrl.text.trim() : (_reason?.tr() ?? '');
  bool get _canSave => _w != null && _w! >= AppConstants.minWeightKg && _w! <= AppConstants.maxWeightKg && _w != widget.entry.currentWeightKg && _reasonText.isNotEmpty;
  double get _diff => (_w ?? widget.entry.currentWeightKg ?? 0) - (widget.entry.currentWeightKg ?? 0);

  void _save() {
    if (!_canSave) return;
    context.read<EditWeightCubit>().save(widget.entry.id, _w!, _reasonText);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditWeightCubit, EditWeightState>(
      listener: (context, state) {
        if (state is EditWeightSaved) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('edit_saved'.tr()))); }
        if (state is EditWeightError) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorKey.tr()))); }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _warning(),
          const SizedBox(height: 16),
          _currentWeight(),
          const SizedBox(height: 16),
          TextField(
            controller: _wCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}'))],
            decoration: InputDecoration(labelText: 'new_weight_label'.tr(), suffixText: 'unit_kg'.tr()),
            onChanged: (_) => setState(() {}),
          ),
          if (_w != null) ...[const SizedBox(height: 8), _diffChip()],
          const SizedBox(height: 16),
          Text('edit_reason'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._reasons.map((r) => RadioListTile<String>(
            title: Text(r.tr(), style: const TextStyle(fontSize: 14)),
            value: r, groupValue: _reason, dense: true, contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _reason = v),
          )),
          if (_isOther) ...[const SizedBox(height: 4), TextField(
            controller: _rCtrl, maxLength: AppConstants.maxEditReasonLength,
            decoration: InputDecoration(hintText: 'custom_reason_hint'.tr()),
            onChanged: (_) => setState(() {}),
          )],
          const SizedBox(height: 20),
          BlocBuilder<EditWeightCubit, EditWeightState>(builder: (context, state) {
            final saving = state is EditWeightSaving;
            return SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: saving || !_canSave ? null : _save,
              child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('save'.tr()),
            ));
          }),
        ]),
      ),
    );
  }

  Widget _warning() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.editedBg, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const Icon(Icons.warning_amber, size: 20, color: AppColors.edited), const SizedBox(width: 10),
      Expanded(child: Text('edit_weight_warning'.tr(), style: const TextStyle(color: AppColors.edited, fontSize: 13))),
    ]),
  );

  Widget _currentWeight() {
    final kg = widget.entry.currentWeightKg?.toStringAsFixed(1) ?? '0';
    return Row(children: [
      Text('current_weight'.tr(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const SizedBox(width: 8),
      Text('${MilkDateUtils.toArabicNumeralsStr(kg)} ${'unit_kg'.tr()}', style: TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary,
        decoration: _w != null ? TextDecoration.lineThrough : null,
      )),
    ]);
  }

  Widget _diffChip() {
    final positive = _diff > 0;
    final c = positive ? AppColors.primary : AppColors.danger;
    final sign = positive ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text('$sign${MilkDateUtils.toArabicNumeralsStr(_diff.toStringAsFixed(1))} ${'unit_kg'.tr()}', style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
