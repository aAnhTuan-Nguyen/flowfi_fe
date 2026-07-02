import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class NetworkStatusService {
  Future<bool> hasNetwork();

  Stream<bool> get onlineChanges;
}

final class ConnectivityNetworkStatusService implements NetworkStatusService {
  ConnectivityNetworkStatusService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> hasNetwork() async {
    final result = await _connectivity.checkConnectivity();
    return _isOnline(result);
  }

  @override
  Stream<bool> get onlineChanges {
    return _connectivity.onConnectivityChanged.map(_isOnline).distinct();
  }

  bool _isOnline(List<ConnectivityResult> result) {
    return !result.contains(ConnectivityResult.none);
  }
}
