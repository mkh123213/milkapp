import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/edit_weight_cubit.dart';
import '../refactor/edit_weight_body.dart';

class EditWeightScreen extends StatelessWidget {
  final String entryId;
  const EditWeightScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditWeightCubit>()..loadEntry(entryId),
      child: EditWeightBody(entryId: entryId),
    );
  }
}
