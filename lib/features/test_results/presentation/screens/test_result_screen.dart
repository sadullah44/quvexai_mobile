import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/test_result_provider.dart';

class TestResultScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const TestResultScreen({super.key, required this.sessionId});

  @override
  ConsumerState<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends ConsumerState<TestResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔥 Sadece offline session'lar için sonuç getirme
      if (!widget.sessionId.startsWith('offline-')) {
        ref.read(testResultProvider.notifier).fetchResult(widget.sessionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testResultProvider);

    // 🔥 Offline session kontrolü
    final isOfflineSession = widget.sessionId.startsWith('offline-');

    return Scaffold(
      appBar: AppBar(title: const Text('Test Sonucu')),
      body: Builder(
        builder: (context) {
          // 🔥 Offline test için özel ekran
          if (isOfflineSession) {
            return _buildOfflineMessage(context);
          }

          // 🔥 Online test sonuçları
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Hata: ${state.errorMessage}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(testResultProvider.notifier)
                          .fetchResult(widget.sessionId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          } else if (state.result != null) {
            final result = state.result!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOPLAM PUAN KARTI
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 40,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              const Text(
                                'Toplam Puanınız',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                result.totalScore.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // RADAR GRAFİĞİ
                  const Text(
                    'Kategori Analizi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        tickCount: 5,
                        ticksTextStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.transparent,
                        ),
                        radarBorderData: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                        gridBorderData: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        tickBorderData: const BorderSide(
                          color: Colors.transparent,
                        ),
                        getTitle: (index, angle) {
                          final categories = result.categoryScores.keys
                              .toList();
                          if (index < categories.length) {
                            return RadarChartTitle(
                              text: categories[index],
                              angle: angle,
                            );
                          }
                          return const RadarChartTitle(text: '');
                        },
                        dataSets: [
                          RadarDataSet(
                            fillColor: Colors.blue.withValues(alpha: 0.3),
                            borderColor: Colors.blue,
                            borderWidth: 2,
                            dataEntries: result.categoryScores.values
                                .map(
                                  (score) =>
                                      RadarEntry(value: score.toDouble()),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // KATEGORİ KARTLARI
                  const Text(
                    'Detaylı Puanlar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...result.categoryScores.entries.map((entry) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForScore(entry.value),
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(entry.key),
                        subtitle: LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation(
                            _getColorForScore(entry.value),
                          ),
                        ),
                        trailing: Text('${entry.value}/100'),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // GELİŞİM ÖNERİSİ
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gelişim Önerisi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result.feedback,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // TEKRAR ÇÖZ BUTONU
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Testi Tekrar Çöz'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        context.go('/tests');
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Sonuç bulunamadı.'));
          }
        },
      ),
    );
  }

  /// 🔥 Offline test için bilgilendirme ekranı
  Widget _buildOfflineMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.orange.shade400),
            const SizedBox(height: 24),
            const Text(
              'Test Kuyruğa Eklendi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'İnternet bağlantısı olmadığı için testiniz kuyruğa eklendi.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'İnternet bağlantısı geldiğinde otomatik olarak gönderilecek ve sonuçlarınızı görebileceksiniz.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Testiniz cihazınızda güvenle saklanıyor.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Ana Sayfaya Dön'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  context.go('/dashboard');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Puana göre renk belirleme
  Color _getColorForScore(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
