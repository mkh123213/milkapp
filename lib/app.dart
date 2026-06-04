import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/cubits/connectivity/connectivity_cubit.dart';

class MilkApp extends StatelessWidget {
  const MilkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConnectivityCubit>(),
      child: MaterialApp.router(
        title: 'app_title'.tr(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: getIt<GoRouter>(),
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
      ),
    );
  }
}
