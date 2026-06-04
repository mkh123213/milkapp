import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/suppliers_list_cubit.dart';
import '../refactor/suppliers_list_body.dart';

class SuppliersListScreen extends StatelessWidget {
  const SuppliersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SuppliersListCubit>()..load(),
      child: const SuppliersListBody(),
    );
  }
}
