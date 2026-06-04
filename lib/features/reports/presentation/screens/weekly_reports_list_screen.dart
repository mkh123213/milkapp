import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/reports_list_cubit.dart';
import '../refactor/reports_list_body.dart';

class WeeklyReportsListScreen extends StatelessWidget {
  const WeeklyReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportsListCubit>()..load(),
      child: const ReportsListBody(),
    );
  }
}
