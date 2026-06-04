import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import '../cubits/connectivity/connectivity_cubit.dart';
import '../cubits/connectivity/connectivity_state.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (state is! ConnectivityOffline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: AppColors.alert,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Flexible(child: Text('offline_banner'.tr(), style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center)),
            ],
          ),
        );
      },
    );
  }
}
