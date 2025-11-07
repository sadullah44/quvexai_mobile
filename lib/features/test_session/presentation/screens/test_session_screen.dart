import 'package:flutter/material.dart';

class TestSessionScreen extends StatefulWidget {
  final String testId;
  final String testName;

  const TestSessionScreen({
    super.key,
    required this.testId,
    required this.testName,
  });

  @override
  State<TestSessionScreen> createState() => _TestSessionScreenState();
}

class _TestSessionScreenState extends State<TestSessionScreen> {
  int _currentQuestionIndex = 0;

  // answers: soruIndex -> seçilenOptionIndex
  final Map<int, int> _answers = {};

  late final List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();

    // Test türüne göre kişisel gelişim soruları
    if (widget.testName.toLowerCase().contains('travma') ||
        widget.testName.toLowerCase().contains('travma')) {
      _questions = [
        {
          'question':
              'Çocukluk döneminde kendinizi güvende hissetmediğiniz anlar oldu mu?',
          'options': ['Hiç olmadı', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman'],
        },
        {
          'question':
              'Ailenizden duygusal destek aldığınızı hisseder miydiniz?',
          'options': [
            'Kesinlikle evet',
            'Kısmen evet',
            'Emin değilim',
            'Çok az',
            'Hiç yoktu',
          ],
        },
        {
          'question':
              'Travmatik anıları düşündüğünüzde kendinizi nasıl hissedersiniz?',
          'options': [
            'Hiç etkilenmem',
            'Az etkilenirim',
            'Orta',
            'Çok',
            'Aşırı',
          ],
        },
        {
          'question': 'Kriz anlarında sakin kalabiliyor musunuz?',
          'options': ['Her zaman', 'Genellikle', 'Bazen', 'Nadiren', 'Asla'],
        },
      ];
    } else if (widget.testName.toLowerCase().contains('bağlanma') ||
        widget.testName.toLowerCase().contains('bağlanma stilleri')) {
      _questions = [
        {
          'question':
              'Yakın ilişkilerde partnerinize güvenmekte zorlanır mısınız?',
          'options': ['Asla', 'Nadiren', 'Bazen', 'Sık sık', 'Her zaman'],
        },
        {
          'question':
              'İlişkinin sonlanma ihtimali sizi sık sık endişelendirir mi?',
          'options': [
            'Hiç endişelenmem',
            'Nadiren',
            'Ara sıra',
            'Sık sık',
            'Her zaman',
          ],
        },
        {
          'question': 'Partnerinizin size yakınlığı yeterli mi?',
          'options': [
            'Hiç yeterli değil',
            'Yetersiz',
            'Orta',
            'Yeterli',
            'Çok yeterli',
          ],
        },
        {
          'question': 'Duygularınızı paylaşmakta zorlanır mısınız?',
          'options': ['Hiç zorlanmam', 'Az', 'Orta', 'Çok', 'Aşırı'],
        },
      ];
    } else if (widget.testName.toLowerCase().contains('stres') ||
        widget.testName.toLowerCase().contains('stres yönetimi')) {
      _questions = [
        {
          'question': 'Son ay içinde kendinizi sık sık gergin hissettiniz mi?',
          'options': [
            'Hiçbir zaman',
            'Nadiren',
            'Bazen',
            'Sık sık',
            'Her zaman',
          ],
        },
        {
          'question': 'Zor durumlar karşısında sakin kalabilir misiniz?',
          'options': ['Her zaman', 'Genellikle', 'Bazen', 'Nadiren', 'Asla'],
        },
        {
          'question': 'Yoğun iş veya okul temposu sizi nasıl etkiliyor?',
          'options': ['Hiç etkilenmem', 'Az', 'Orta', 'Çok', 'Aşırı'],
        },
        {
          'question':
              'Gevşeme teknikleri veya hobiler stresinizi azaltıyor mu?',
          'options': ['Hiç yardımcı değil', 'Az', 'Orta', 'Çok', 'Çok fazla'],
        },
      ];
    } else {
      // Default örnek
      _questions = [
        {
          'question': 'Bugün kendinizi nasıl hissediyorsunuz?',
          'options': ['Çok iyi', 'İyi', 'Orta', 'Kötü', 'Çok kötü'],
        },
        {
          'question': 'Bugün enerjiniz yüksek miydi?',
          'options': [
            'Hiç enerjik değilim',
            'Az',
            'Orta',
            'Yüksek',
            'Çok yüksek',
          ],
        },
        {
          'question': 'Bugün kendinize vakit ayırabildiniz mi?',
          'options': ['Hiç', 'Az', 'Orta', 'Çok', 'Çok fazla'],
        },
        {
          'question': 'Bugün kendinizi motive hissettiniz mi?',
          'options': ['Hiç', 'Az', 'Orta', 'Çok', 'Çok fazla'],
        },
      ];
    }
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = optionIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _finishAndSubmit() {
    // Örnek: Basit bir sonuç özetini toplayalım
    final answered = _answers.length;
    final total = _questions.length;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Testi Bitir & Gönder'),
        content: Text(
          'Toplam $total sorudan $answered tanesine cevap verdiniz.\nTesti göndermek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Burada API gönderimi yapılırsa eklenir. Şimdilik demo:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test başarıyla gönderildi!')),
              );
              // Test ekranından çık
              Navigator.of(context).pop();
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(String text, bool selected, VoidCallback onTap) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentQuestionIndex];
    final total = _questions.length;
    final selectedIndex = _answers[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.testName), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soru ${_currentQuestionIndex + 1} / $total',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / total,
              minHeight: 8,
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current['question'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate((current['options'] as List).length, (i) {
                      final opt = (current['options'] as List)[i] as String;
                      final isSelected = selectedIndex == i;
                      return _buildOptionRow(
                        opt,
                        isSelected,
                        () => _selectOption(i),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentQuestionIndex > 0
                        ? _previousQuestion
                        : null,
                    child: const Text('Geri'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _currentQuestionIndex < total - 1
                      ? ElevatedButton(
                          onPressed: selectedIndex == null
                              ? null
                              : _nextQuestion,
                          child: const Text('İleri'),
                        )
                      : ElevatedButton(
                          onPressed: selectedIndex == null
                              ? null
                              : _finishAndSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Bitir & Gönder'),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
