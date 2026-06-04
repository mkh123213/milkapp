import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/connectivity_service.dart';
import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription? _sub;

  ConnectivityCubit(this._service) : super(const ConnectivityOnline()) {
    _sub = _service.onConnectivityChanged.listen((results) {
      if (_service.isOffline(results)) {
        emit(const ConnectivityOffline());
      } else {
        emit(const ConnectivityOnline());
      }
    });
  }

  bool get isOffline => state is ConnectivityOffline;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
