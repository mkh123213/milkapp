import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../../../../core/constants.dart';
import '../../../../shared/models/supplier.dart';
import '../../../../injection_container.dart';
import '../../../auth/data/repos/auth_repo.dart';
import '../../data/repos/suppliers_repo.dart';
import '../cubit/add_edit_supplier_cubit.dart';
import '../cubit/add_edit_supplier_state.dart';

class AddEditSupplierBody extends StatefulWidget {
  final String? supplierId;
  const AddEditSupplierBody({super.key, this.supplierId});

  bool get isEdit => supplierId != null;

  @override
  State<AddEditSupplierBody> createState() => _AddEditSupplierBodyState();
}

class _AddEditSupplierBodyState extends State<AddEditSupplierBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isActive = true;
  bool _isDirty = false;
  Supplier? _original;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) _loadSupplier();
  }

  void _loadSupplier() async {
    final uid = getIt<AuthRepo>().currentUserId;
    if (uid == null) {
      if (mounted) context.read<AddEditSupplierCubit>().emitError('auth_required');
      return;
    }
    final suppliers = await getIt<SuppliersRepo>().getActiveSuppliers(uid);
    if (!mounted) return;
    final cubit = context.read<AddEditSupplierCubit>();
    cubit.loadSupplier(suppliers, widget.supplierId!);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _phoneCtrl, _villageCtrl, _addressCtrl, _orderCtrl, _notesCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddEditSupplierCubit, AddEditSupplierState>(
      listener: (context, state) {
        if (state is AddEditSupplierLoaded) {
          final s = state.supplier;
          _original = s;
          _nameCtrl.text = s.name;
          _phoneCtrl.text = s.phone ?? '';
          _villageCtrl.text = s.village ?? '';
          _addressCtrl.text = s.address ?? '';
          _orderCtrl.text = s.routeOrder.toString();
          _notesCtrl.text = s.notes ?? '';
          _isActive = s.isActive;
        }
        if (state is AddEditSupplierSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isEdit ? 'changes_saved'.tr() : 'supplier_added'.tr(args: [state.name])), backgroundColor: AppColors.primary));
          if (state.newId != null) {
            context.go('/suppliers/details/${state.newId}');
          } else {
            context.pop();
          }
        }
      },
      builder: (context, state) {
        final isSaving = state is AddEditSupplierSaving;
        return PopScope(
          canPop: !_isDirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final can = await _confirmExit();
            if (can && context.mounted) Navigator.pop(context);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                Container(color: Colors.white, child: SafeArea(bottom: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 14), child: Row(children: [GestureDetector(onTap: () async { final can = await _confirmExit(); if (can && context.mounted) Navigator.pop(context); }, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20))), const SizedBox(width: 12), Text(widget.isEdit ? 'edit_supplier_title'.tr() : 'add_supplier_title'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])))),
                Expanded(child: Form(key: _formKey, onChanged: () => setState(() => _isDirty = true), child: ListView(padding: const EdgeInsets.all(16), children: [
                  _field(ctrl: _nameCtrl, label: 'name_required'.tr(), hint: 'name_full'.tr(), icon: AssetPaths.iconUser, validator: (v) { if (v == null || v.trim().isEmpty) return 'name_error_required'.tr(); if (v.trim().length < AppConstants.minSupplierNameLength) return 'name_error_short'.tr(); if (v.trim().length > AppConstants.maxSupplierNameLength) return 'name_error_long'.tr(); return null; }),
                  _field(ctrl: _phoneCtrl, label: 'phone_label'.tr(), hint: 'phone_hint'.tr(), icon: AssetPaths.iconPhone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) { if (v != null && v.trim().isNotEmpty && v.trim().length < 9) return 'phone_error_short'.tr(); return null; }),
                  _field(ctrl: _villageCtrl, label: 'village_label'.tr(), hint: 'village_input'.tr(), icon: AssetPaths.iconPin, maxLength: AppConstants.maxVillageLength),
                  _field(ctrl: _addressCtrl, label: 'address_label'.tr(), hint: 'address_hint'.tr(), icon: AssetPaths.iconPin, maxLength: AppConstants.maxAddressLength),
                  _field(ctrl: _orderCtrl, label: 'route_order_label'.tr(), hint: 'route_order_hint'.tr(), icon: AssetPaths.iconClipboard, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], helperText: 'route_order_helper'.tr()),
                  _field(ctrl: _notesCtrl, label: 'notes_label'.tr(), hint: 'notes_any'.tr(), icon: AssetPaths.iconDocument, maxLines: 3, maxLength: AppConstants.maxNotesLength),
                  if (widget.isEdit) ...[const SizedBox(height: 4), Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]), child: SwitchListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text('active_switch'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(_isActive ? 'active_on'.tr() : 'active_off'.tr(), style: const TextStyle(fontSize: 12)), value: _isActive, activeTrackColor: AppColors.primary, onChanged: (v) => setState(() { _isActive = v; _isDirty = true; })))],
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: isSaving ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2), child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check, color: Colors.white), const SizedBox(width: 8), Text(widget.isEdit ? 'save_changes'.tr() : 'add_supplier_btn'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]))),
                  const SizedBox(height: 32),
                ]))),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AddEditSupplierCubit>().save(supplierId: widget.supplierId, name: _nameCtrl.text, phone: _phoneCtrl.text, village: _villageCtrl.text, address: _addressCtrl.text, orderStr: _orderCtrl.text, notes: _notesCtrl.text, isActive: _isActive, original: _original);
  }

  Future<bool> _confirmExit() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Text('unsaved_changes'.tr()), content: Text('unsaved_changes_body'.tr()), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('cancel'.tr())), ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('exit'.tr(), style: const TextStyle(color: Colors.white)))]));
    return result ?? false;
  }

  Widget _field({required TextEditingController ctrl, required String label, String? hint, String? helperText, String? icon, String? Function(String?)? validator, TextInputType? keyboardType, TextDirection? textDirection, List<TextInputFormatter>? inputFormatters, int maxLines = 1, int? maxLength, TextInputAction? textInputAction}) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 8), TextFormField(controller: ctrl, keyboardType: keyboardType, textDirection: textDirection, inputFormatters: inputFormatters, maxLines: maxLines, maxLength: maxLength, textInputAction: textInputAction ?? (maxLines > 1 ? TextInputAction.newline : TextInputAction.next), decoration: InputDecoration(hintText: hint, helperText: helperText, prefixIcon: icon != null ? Padding(padding: const EdgeInsets.all(12), child: Image.asset(icon, width: 18, height: 18)) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), counterText: ''), validator: validator)]));
}
