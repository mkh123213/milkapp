import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../../shared/models/supplier.dart';
import '../cubit/weight_entry_cubit.dart';
import '../cubit/weight_entry_state.dart';

void showNoMilkDialog(BuildContext context, Supplier supplier) {
  showDialog(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => getIt<WeightEntryCubit>(),
      child: _NoMilkDialogContent(supplier: supplier),
    ),
  );
}

class _NoMilkDialogContent extends StatelessWidget {
  final Supplier supplier;
  const _NoMilkDialogContent({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeightEntryCubit, WeightEntryState>(
      listener: (context, state) {
        if (state is WeightEntrySaved) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('no_milk_saved'.tr()),
              action: SnackBarAction(
                label: 'undo'.tr(),
                onPressed: () {
                  getIt<WeightEntryCubit>().undoNoMilk(supplier.id);
                },
              ),
            ),
          );
        } else if (state is WeightEntryError) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorKey.tr())));
        }
      },
      child: BlocBuilder<WeightEntryCubit, WeightEntryState>(
        builder: (context, state) {
          final saving = state is WeightEntrySaving;
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(children: [
              const Icon(Icons.block, color: AppColors.noMilk, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text('no_milk_title'.tr(),
                  style: const TextStyle(fontSize: 17))),
            ]),
            content: Text(
              'no_milk_confirm_body'.tr(args: [supplier.name]),
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () => context.read<WeightEntryCubit>().saveNoMilk(
                          supplierId: supplier.id,
                          supplierName: supplier.name,
                        ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.noMilk),
                child: saving
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('confirm'.tr()),
              ),
            ],
          );
        },
      ),
    );
  }
}
