import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quvexai_mobile/core/sync/sync_service.dart';

/// ✅ Sync Status Widget - Profil sayfasında bekleyen testleri gösterir
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.read(syncServiceProvider);
    final queueSize = syncService.getQueueSize();

    // Kuyruk boşsa widget'ı gösterme
    if (queueSize == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bekleyen Testler",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$queueSize test senkronize edilmeyi bekliyor",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // ✅ Manuel sync tetikle
                  final report = await syncService.manualSync();

                  // Context kontrolü
                  if (!context.mounted) return;

                  // Kullanıcıya bilgi ver
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        report.allSuccess
                            ? "✅ ${report.success} test başarıyla gönderildi!"
                            : "⚠️ ${report.success} başarılı, ${report.failed} başarısız",
                      ),
                      backgroundColor: report.allSuccess
                          ? Colors.green
                          : Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.sync),
                label: const Text("Şimdi Senkronize Et"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
