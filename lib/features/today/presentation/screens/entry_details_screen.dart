import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/edit_weight_cubit.dart';
import '../refactor/entry_details_body.dart';

class EntryDetailsScreen extends StatelessWidget {
  final String entryId;
  const EntryDetailsScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditWeightCubit>()..loadEntry(entryId),
      child: EntryDetailsBody(entryId: entryId),
    );
  }
}
