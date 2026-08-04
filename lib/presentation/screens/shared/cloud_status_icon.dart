import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/presentation/providers/connectivity_provider.dart';

class CloudStatusIcon extends ConsumerWidget {
  const CloudStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    if (isOffline) {
      return const Tooltip(
        message: "Du bist offline. Daten werden lokal gespeichert.",
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.cloud_off, color: Colors.grey),
        ),
      );
    }

    // When online: show nothing for a clean UI
    return const SizedBox.shrink();
  }
}
