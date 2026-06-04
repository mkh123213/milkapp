import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/today_cubit.dart';
import '../refactor/today_receiving_body.dart';

class TodayReceivingScreen extends StatelessWidget {
  const TodayReceivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodayCubit>()..load(),
      child: const TodayReceivingBody(),
    );
  }
}
