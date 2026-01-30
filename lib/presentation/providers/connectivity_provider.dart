import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
Stream<List<ConnectivityResult>> connectivityStatus(Ref ref) {
  // Gibt einen Stream zurück, der feuert, wenn sich WiFi/Mobile ändert
  return Connectivity().onConnectivityChanged;
}

// Kleiner Helper, um einfach zu prüfen "Sind wir offline?"
@riverpod
bool isOffline(Ref ref) {
  final statusAsync = ref.watch(connectivityStatusProvider);

  return statusAsync.when(
    data: (results) {
      // Wenn "none" in der Liste ist, haben wir gar keine Verbindung
      return results.contains(ConnectivityResult.none);
    },
    loading: () => false, // Annahme: Wir sind erst mal online
    error: (_, __) => true, // Im Fehlerfall lieber warnen
  );
}
