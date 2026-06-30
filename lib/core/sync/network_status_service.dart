import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class NetworkStatusService {
  Future<bool> hasNetwork();
}

final class ConnectivityNetworkStatusService implements NetworkStatusService {
  ConnectivityNetworkStatusService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> hasNetwork() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
