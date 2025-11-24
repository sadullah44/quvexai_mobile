import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Giriş animasyonu için
import 'package:quvexai_mobile/features/tests/data/models/test_model.dart';

class TestCard extends StatefulWidget {
  final TestModel test;

  const TestCard({super.key, required this.test});

  @override
  State<TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> {
  // Tıklama durumunu takip etmek için state
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Renkleri zorluk seviyesine göre belirleyelim
    Color difficultyColor;
    switch (widget.test.difficulty.toLowerCase()) {
      case 'kolay':
        difficultyColor = Colors.green;
        break;
      case 'orta':
        difficultyColor = Colors.orange;
        break;
      case 'zor':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.blue;
    }

    // --- TIKLAMA ANİMASYONU (SCALE) ---
    // Kartı 'AnimatedScale' ile sarmalıyoruz.
    // Basılı tutulunca (%96) küçülüyor, bırakınca (1.0) eski haline dönüyor.
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child:
          Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  // Basma başladığında küçült
                  onHighlightChanged: (value) {
                    setState(() {
                      _isPressed = value;
                    });
                  },
                  onTap: () {
                    // Detay sayfasına yönlendir
                    context.push(
                      '/tests/${widget.test.id}',
                      extra: widget.test,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Sol İkon Kutusu
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.psychology,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Orta Bilgi Alanı
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.test.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Zorluk Rozeti
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: difficultyColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.test.difficulty,
                                      style: TextStyle(
                                        color: difficultyColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Süre
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${widget.test.estimatedTimeMins} dk",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Sağ Ok
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              )
              // --- GİRİŞ ANİMASYONU (SAĞDAN KAYMA) ---
              .animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
    );
  }
}
