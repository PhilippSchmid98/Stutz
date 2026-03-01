import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
Stream<List<ConnectivityResult>> connectivityStatus(Ref ref) {
  // Returns a stream that triggers when WiFi/Mobile connectivity changes
  return Connectivity().onConnectivityChanged;
}

@riverpod
bool isOffline(Ref ref) {
  final statusAsync = ref.watch(connectivityStatusProvider);

  return statusAsync.when(
    data: (results) {
      // If "none" is in the list, there is no connection
      return results.contains(ConnectivityResult.none);
    },
    loading: () => false, // Assume: Initially online
    error: (_, __) => true, // In case of error, better to warn
  );
}
