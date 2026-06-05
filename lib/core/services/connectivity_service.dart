import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<List<ConnectivityResult>> checkConnectivity() =>
      _connectivity.checkConnectivity();

  bool isOffline(List<ConnectivityResult> results) =>
      results.isEmpty ||
      results.every((r) => r == ConnectivityResult.none);
}
