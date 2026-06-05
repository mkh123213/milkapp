import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/route_ordering_cubit.dart';
import '../refactor/route_ordering_body.dart';

class RouteOrderingScreen extends StatelessWidget {
  const RouteOrderingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RouteOrderingCubit>(),
      child: const RouteOrderingBody(),
    );
  }
}
