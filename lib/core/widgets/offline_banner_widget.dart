import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// ✅ Connectivity Provider - İnternet durumunu izler
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// ✅ Offline Banner Widget - Test çözerken offline olunca banner gösterir
class OfflineBannerWidget extends ConsumerWidget {
  final Widget child;

  const OfflineBannerWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (results) {
        final isOffline = results.contains(ConnectivityResult.none);

        return Column(
          children: [
            // ✅ Offline banner (sadece offline ise göster)
            if (isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Colors.orange.shade700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Offline Mod - Cevaplarınız kaydediliyor",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

            // Ana içerik
            Expanded(child: child),
          ],
        );
      },
      loading: () => child, // Yükleniyor, banner gösterme
      error: (_, __) => child, // Hata varsa, banner gösterme
    );
  }
}
