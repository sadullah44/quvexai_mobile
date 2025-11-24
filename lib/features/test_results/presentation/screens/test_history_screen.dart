import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// Beynimizi ve Enum'ları import ediyoruz
import 'package:quvexai_mobile/features/test_results/presentation/providers/test_history_provider.dart';

class TestHistoryScreen extends ConsumerStatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  ConsumerState<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends ConsumerState<TestHistoryScreen> {
  // Arama metnini kontrol etmek için controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz geçmişi yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testHistoryProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // "Gösterge Paneli"ni izle
    final state = ref.watch(testHistoryProvider);
    // "Beyin"e komut göndermek için kısayol
    final notifier = ref.read(testHistoryProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Geçmişim'), centerTitle: true),
      body: Column(
        children: [
          // --- 1. ARAMA ÇUBUĞU ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Testlerde ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                // Her harf girildiğinde aramayı tetikle
                notifier.search(value);
              },
            ),
          ),

          // --- 2. FİLTRELEME BUTONLARI (CHIPS) ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'En Yeni',
                  // SortOption enum'ı provider dosyasından geliyor
                  selected: state.currentSort == SortOption.dateNewest,
                  onSelected: () => notifier.sort(SortOption.dateNewest),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'En Eski',
                  selected: state.currentSort == SortOption.dateOldest,
                  onSelected: () => notifier.sort(SortOption.dateOldest),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Puan (Yüksek)',
                  selected: state.currentSort == SortOption.scoreHigh,
                  onSelected: () => notifier.sort(SortOption.scoreHigh),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Puan (Düşük)',
                  selected: state.currentSort == SortOption.scoreLow,
                  onSelected: () => notifier.sort(SortOption.scoreLow),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- 3. LİSTE (GÖVDE) ---
          Expanded(
            child: Builder(
              builder: (context) {
                // DURUM A: Yükleniyor mu?
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // DURUM B: Filtrelenmiş Liste Boş mu?
                if (state.filteredHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Henüz test çözmedin.'
                              : 'Sonuç bulunamadı.',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // DURUM C: Liste Dolu (Filtrelenmiş Listeyi Göster)
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.filteredHistory.length,
                  itemBuilder: (context, index) {
                    final result = state.filteredHistory[index];

                    // Tarihi formatla
                    final formattedDate = DateFormat(
                      'dd MMM yyyy, HH:mm',
                    ).format(result.completedAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Text(
                            result.totalScore.toInt().toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        // --- ÖNEMLİ: ARTIK GERÇEK İSMİ GÖSTERİYORUZ ---
                        title: Text(
                          result.testName, // Modeldeki yeni alan
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(formattedDate),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Detay sayfasına git
                          context.push('/test-results/${result.sessionId}');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Yardımcı Widget: Filtre Butonu Tasarımı
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
