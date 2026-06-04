import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/report_details_cubit.dart';
import '../refactor/report_details_body.dart';

class WeeklyReportDetailsScreen extends StatelessWidget {
  final String reportId;
  const WeeklyReportDetailsScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportDetailsCubit>()..load(reportId),
      child: ReportDetailsBody(reportId: reportId),
    );
  }
}
