import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/supplier_details_cubit.dart';
import '../refactor/supplier_details_body.dart';

class SupplierDetailsScreen extends StatelessWidget {
  final String supplierId;
  const SupplierDetailsScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SupplierDetailsCubit>()..load(supplierId),
      child: SupplierDetailsBody(supplierId: supplierId),
    );
  }
}
