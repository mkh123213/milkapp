import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/add_edit_supplier_cubit.dart';
import '../refactor/add_edit_supplier_body.dart';

class AddEditSupplierScreen extends StatelessWidget {
  final String? supplierId;
  const AddEditSupplierScreen({super.key, this.supplierId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddEditSupplierCubit>(),
      child: AddEditSupplierBody(supplierId: supplierId),
    );
  }
}
